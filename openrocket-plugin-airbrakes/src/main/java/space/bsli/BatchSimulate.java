package space.bsli;

import info.openrocket.core.document.OpenRocketDocument;
import info.openrocket.core.document.Simulation;
import info.openrocket.core.file.GeneralRocketLoader;
import info.openrocket.core.file.RocketLoadException;
import info.openrocket.core.simulation.exception.SimulationException;
import info.openrocket.core.startup.Application;
import info.openrocket.core.startup.OpenRocketCore;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Scanner;
import java.util.concurrent.atomic.AtomicInteger;

public class BatchSimulate {
    static final String ORK_FILE_PATH = "IREC 4.22.26.ork";
    static final String CSV_OUTPUT_PATH = "apogee_sweep.csv";

    // Sweep ranges
    static final double TARGET_APOGEE_START_M = 7000;
    static final double TARGET_APOGEE_END_M   = 10000;
    static final double TARGET_APOGEE_STEP_M  = 250;

    static final double LAUNCH_ANGLE_START_DEG = 0;
    static final double LAUNCH_ANGLE_END_DEG   = 10;
    static final double LAUNCH_ANGLE_STEP_DEG  = 1;

    public static void main(String[] args) throws Exception {
        if (args.length > 0 && args[0].equals("--worker")) {
            runWorker();
        } else {
            runMain();
        }
    }

    // -------------------------------------------------------------------------
    // Worker: reads "targetApogee,angleDeg" lines from stdin, writes CSV rows
    // to stdout. One worker process per CPU core, spawned by runMain().
    // Separate processes (not threads) because the native library uses global
    // state (SetTargetApogee, InitController, etc.) and is not thread-safe.
    // -------------------------------------------------------------------------
    private static void runWorker() throws SimulationException, RocketLoadException {
        OpenRocketCore.initialize();
        Application.getPreferences().setUserThrustCurveFiles(List.of(new File(".")));

        GeneralRocketLoader loader = new GeneralRocketLoader(new File(ORK_FILE_PATH));
        OpenRocketDocument document = loader.load();
        Simulation s = document.getSimulation(0);

        Scanner scanner = new Scanner(System.in);
        while (scanner.hasNextLine()) {
            String line = scanner.nextLine().trim();
            if (line.isEmpty()) continue;
            String[] parts = line.split(",");
            double targetApogee = Double.parseDouble(parts[0]);
            double angleDeg     = Double.parseDouble(parts[1]);

            AirbrakesExtension.SetTargetApogee((float) targetApogee);
            s.getOptions().setLaunchRodAngle(Math.toRadians(angleDeg));
            s.simulate();
            double achieved = s.getSimulatedData().getMaxAltitude();

            System.out.printf("%.1f,%.1f,%.4f%n", targetApogee, angleDeg, achieved);
            System.out.flush();
        }
    }

    // -------------------------------------------------------------------------
    // Orchestrator: builds the full pair list, chunks it across CPU cores,
    // spawns worker processes, collects results, writes the CSV.
    // -------------------------------------------------------------------------
    private static void runMain() throws InterruptedException, IOException {
        List<double[]> allPairs = new ArrayList<>();
        for (double t = TARGET_APOGEE_START_M; t <= TARGET_APOGEE_END_M + 1e-9; t += TARGET_APOGEE_STEP_M) {
            for (double a = LAUNCH_ANGLE_START_DEG; a <= LAUNCH_ANGLE_END_DEG + 1e-9; a += LAUNCH_ANGLE_STEP_DEG) {
                allPairs.add(new double[]{t, a});
            }
        }

        int totalRuns = allPairs.size();
        int nWorkers  = Math.min(Runtime.getRuntime().availableProcessors(), totalRuns);
        nWorkers = 10; // TODO
        System.out.printf("Dispatching %d runs across %d worker processes%n", totalRuns, nWorkers);

        // Round-robin distribute pairs into chunks
        List<List<double[]>> chunks = new ArrayList<>();
        for (int i = 0; i < nWorkers; i++) chunks.add(new ArrayList<>());
        for (int i = 0; i < allPairs.size(); i++) chunks.get(i % nWorkers).add(allPairs.get(i));

        List<String> csvRows       = Collections.synchronizedList(new ArrayList<>());
        AtomicInteger completedRuns = new AtomicInteger(0);

        String javaExe    = ProcessHandle.current().info().command().orElse("java");
        String classpath  = System.getProperty("java.class.path");
        String libPath    = System.getProperty("java.library.path");

        List<Thread> threads = new ArrayList<>();
        for (int w = 0; w < nWorkers; w++) {
            final List<double[]> chunk    = chunks.get(w);
            final int            workerId = w;
            Thread thread = new Thread(() -> {
                try {
                    List<String> cmd = new ArrayList<>(List.of(javaExe, "-cp", classpath));
                    if (libPath != null && !libPath.isEmpty())
                        cmd.add("-Djava.library.path=" + libPath);
                    cmd.add("RocketSimulationExample");
                    cmd.add("--worker");

                    ProcessBuilder pb = new ProcessBuilder(cmd);
                    pb.redirectError(ProcessBuilder.Redirect.INHERIT); // worker stderr goes to our terminal
                    Process proc = pb.start();

                    // Feed pairs to worker via stdin
                    try (PrintWriter stdin = new PrintWriter(proc.getOutputStream())) {
                        for (double[] pair : chunk)
                            stdin.printf("%.1f,%.1f%n", pair[0], pair[1]);
                    }

                    // Collect CSV rows from worker stdout
                    try (BufferedReader out = new BufferedReader(new InputStreamReader(proc.getInputStream()))) {
                        String line;
                        while ((line = out.readLine()) != null) {
                            csvRows.add(line);
                            int done = completedRuns.incrementAndGet();
                            System.out.printf("[%d/%d] %s%n", done, totalRuns, line);
                        }
                    }

                    int exit = proc.waitFor();
                    if (exit != 0)
                        System.err.printf("Worker %d exited with code %d%n", workerId, exit);

                } catch (Exception e) {
                    System.err.printf("Worker %d failed: %s%n", workerId, e.getMessage());
                    e.printStackTrace(System.err);
                }
            });
            threads.add(thread);
            thread.start();
        }

        for (Thread t : threads) t.join();

        // Sort rows deterministically: by target apogee, then by launch angle
        csvRows.sort((a, b) -> {
            String[] pa = a.split(","), pb = b.split(",");
            int cmp = Double.compare(Double.parseDouble(pa[0]), Double.parseDouble(pb[0]));
            return cmp != 0 ? cmp : Double.compare(Double.parseDouble(pa[1]), Double.parseDouble(pb[1]));
        });

        try (PrintWriter csv = new PrintWriter(new FileWriter(CSV_OUTPUT_PATH))) {
            csv.println("target_apogee_m,launch_rod_angle_deg,achieved_apogee_m");
            for (String row : csvRows) csv.println(row);
        }

        System.out.printf("Wrote %d rows to %s%n", csvRows.size(), CSV_OUTPUT_PATH);
    }
}
