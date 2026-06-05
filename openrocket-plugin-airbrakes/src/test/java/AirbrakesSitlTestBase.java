import space.bsli.AirbrakesTestLib;
import space.bsli.AirbrakesExtension;
import space.bsli.AirbrakesConfig.AirbrakesMode;

import info.openrocket.core.document.Simulation;
import info.openrocket.core.simulation.exception.SimulationException;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;

/**
 * Shared setup for the SITL airbrakes tests.
 *
 * Each simulation boots the real firmware in a fresh dlmopen namespace, and
 * glibc caps a process at ~15 dlmopen namespaces (DL_NNS) and never reclaims a
 * slot on dlclose. So the tests are split across two concrete classes
 * ({@link AirbrakesNominalTest} and {@link AirbrakesFaultTest}), each running
 * well under that cap, and Gradle's {@code forkEvery = 1} gives every test
 * class its own JVM so the namespace budget resets between them.
 *
 * Switch back to the PC-side algorithm with -Dairbrakes.mode=CLOSED_LOOP_SIM.
 */
abstract class AirbrakesSitlTestBase {
    /* Tolerances reflect what the full firmware achieves, not the idealized
     * algorithm. Nominal full-firmware control (with fused GPS) lands within a
     * few hundred metres; fault scenarios are allowed to degrade further but
     * must still demonstrate the airbrakes are meaningfully controlling apogee. */
    static final float NOMINAL_TOL_M = 200;
    static final float SENSOR_FAULT_TOL_M = 300;
    static final float MODEL_ERROR_TOL_M = 400;

    /* Avionics-bay aerodynamic pressure drop (positive baro altitude error per
     * m/s of airspeed at full deployment). Large enough that the airspeed- and
     * deployment-correlated baro error meaningfully degrades baro-only control. */
    static final double BARO_PRESSURE_DROP_M_PER_MPS = 0.5;

    @BeforeAll
    static void beforeAll() {
        AirbrakesTestLib.initialize();
        AirbrakesExtension.mode = AirbrakesMode.valueOf(
                System.getProperty("airbrakes.mode", "FULL_SITL"));
        System.out.println("[test] Airbrakes mode: " + AirbrakesExtension.mode);
    }

    @BeforeEach
    void beforeEach() {
        AirbrakesExtension.resetScenario();
    }

    /** Runs one simulation to apogee and returns the achieved max altitude (m). */
    float runApogee(float targetApogee, float launchRodAngleDeg) throws SimulationException {
        Simulation s = AirbrakesTestLib.getSimulation();
        AirbrakesExtension.SetTargetApogee(targetApogee);
        s.getOptions().setLaunchRodAngle(Math.toRadians(launchRodAngleDeg));
        s.simulate();
        float achieved = (float) s.getSimulatedData().getMaxAltitude();
        System.out.printf("[apogee] target=%.0f rod=%.0fdeg -> achieved=%.1f (err %+.1f)%n",
                targetApogee, launchRodAngleDeg, achieved, achieved - targetApogee);
        return achieved;
    }
}
