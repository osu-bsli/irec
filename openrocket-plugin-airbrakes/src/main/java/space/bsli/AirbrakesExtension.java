package space.bsli;

import info.openrocket.core.aerodynamics.AerodynamicForces;
import info.openrocket.core.aerodynamics.FlightConditions;
import info.openrocket.core.simulation.FlightDataType;
import info.openrocket.core.simulation.SimulationConditions;
import info.openrocket.core.simulation.SimulationStatus;
import info.openrocket.core.simulation.exception.SimulationException;
import info.openrocket.core.simulation.extension.AbstractSimulationExtension;
import info.openrocket.core.simulation.listeners.AbstractSimulationListener;
import info.openrocket.core.unit.UnitGroup;
import info.openrocket.core.util.Coordinate;
import info.openrocket.core.util.Quaternion;
import com.fazecast.jSerialComm.*;

import static space.bsli.AirbrakesConfig.AIRBRAKE_CONTROL_INTERVAL_S;
import static space.bsli.AirbrakesConfig.MODE;

import space.bsli.AirbrakesConfig.AirbrakesMode;
import space.bsli.sim.SensorNoiseModel;
import space.bsli.sim.FakeGpsModel;
import space.bsli.sim.AirbrakeDeploymentModel;

import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Random;

public class AirbrakesExtension extends AbstractSimulationExtension {
    private boolean bypassFilter = false;

    public SerialPort comPort;

    public AirbrakesExtension() {

    }
    public static AirbrakesMode mode = AirbrakesConfig.MODE;

    /* Unique id per FULL_SITL instance so concurrent/sequential runs in one JVM
     * don't collide on the firmware's emulated-radio Unix socket path. */
    private static int sitlInstanceCounter = 0;

    public boolean isBypassFilter() {
        return bypassFilter;
    }

    public void setBypassFilter(boolean bypassFilter) {
        this.bypassFilter = bypassFilter;
    }


    public void initialize(SimulationConditions conditions) throws SimulationException {
        conditions.getSimulationListenerList().add(new AirbrakesListener());
        SetRocketMass(31.740f);
    }

    final float G_CONST = 9.80665f;

    public static native void SetRocketMass(float mass_kg);

    public static native void SetTargetApogee(float meters);

    public static native float DragForce(float deployment_pct, float vTotal_mps, float altitude_m);

    public static native void InitController();

    public static native float RunControllerAndGetDeploymentPct(float accelerometerX_mps2, float accelerometerY_mps2, float accelerometerZ_mps2, float accelerometerHgX_mps2, float accelerometerHgY_mps2, float accelerometerHgZ_mps2, float gyroscopeX_radps, float gyroscopeY_radps, float gyroscopeZ_radps, float barometer_m, float dt);

    public static native float RunControllerRawAndGetDeploymentPct(float velocityX_mps, float velocityY_mps, float velocityZ_mps, float altitude_m);

    /* ---- FULL_SITL: the real firmware running in-process as a library ----
     * SitlCreate loads libflight-firmware-sitl.so into a fresh dlmopen namespace
     * and starts its FreeRTOS task graph. SitlFeedPacket feeds one LogPacketV3
     * sensor frame (the same bytes FULL_HITL sends over serial) and returns the
     * commanded deployment percentage. SitlDestroy tears the instance down. */
    public static native void SitlCreate(int instanceId);

    /* Set the firmware's GNC target apogee (metres) for the current instance. */
    public static native void SitlSetTargetApogee(float meters);

    /* Read back the target apogee previously set via SetRocketMass/SetTargetApogee
     * so it can be forwarded into the firmware. */
    public static native float GetTargetApogee();

    /* SITL model-error injection: override the firmware's assumed rocket mass
     * (kg) and the scale of its modeled airbrake drag (1.0 = nominal). */
    public static native void SitlSetMass(float kg);

    public static native void SitlSetDragScale(float scale);

    public static native int SitlFeedPacket(byte[] logPacketV3);

    public static native void SitlDestroy();

    /* ---- SITL scenario perturbations (for robustness tests) ----
     * All default to "no perturbation"; reset between tests via resetScenario().
     * The simulated phenomena (sensor noise/bias, fake GPS, airbrake actuator
     * dynamics) live in their own model classes; the firmware model errors
     * below are pushed into the firmware after SitlCreate. */
    public static final SensorNoiseModel sensorNoise = new SensorNoiseModel();
    public static final FakeGpsModel fakeGps = new FakeGpsModel();
    public static final AirbrakeDeploymentModel airbrakeDeployment = new AirbrakeDeploymentModel();

    public static double firmwareMassKg = 0.0;     // 0 = leave firmware default; else override
    public static double firmwareDragScale = 1.0;  // firmware modeled-drag scale
    public static long noiseSeed = 12345L;         // fixed seed -> deterministic noise

    public static void resetScenario() {
        sensorNoise.reset();
        fakeGps.resetConfig();
        airbrakeDeployment.resetConfig();
        firmwareMassKg = 0.0;
        firmwareDragScale = 1.0;
        noiseSeed = 12345L;
    }

    /* Send one sensor frame to the flight computer and return its commanded
     * deployment percentage. FULL_HITL goes over serial to real hardware;
     * FULL_SITL goes to the in-process firmware library. */
    private int sendFrameGetDeployment(byte[] packet) {
        if (mode == AirbrakesMode.FULL_SITL) {
            return SitlFeedPacket(packet) & 0xFF;
        }
        comPort.writeBytes(packet, packet.length);
        byte[] buffer = new byte[1];
        if (1 != comPort.readBytes(buffer, 1, 0)) {
            throw new RuntimeException();
        }
        return buffer[0] & 0xFF;
    }

    @Override
    public String getName() {
        return "BSLI IREC Airbrakes";
    }

    @Override
    public String getDescription() {
        return "Simple extension example for air-start";
    }

    private class AirbrakesListener extends AbstractSimulationListener {
        private static final FlightDataType fdtDeploymentPctCommanded = FlightDataType.getType("Airbrake deployment commanded", "%", UnitGroup.UNITS_NONE);
        private static final FlightDataType fdtDeploymentPctSimulatedDynamics = FlightDataType.getType("Airbrake deployment simulated dynamics", "%", UnitGroup.UNITS_NONE);
        private static final FlightDataType fdtDistortedAltitude = FlightDataType.getType("Altitude w/simulated baro errors", "m", UnitGroup.UNITS_LENGTH);

        private FlightConditions flightConditions = null;
        private float deploymentPctCommanded = 0;
        private Coordinate previousVelocity = null;
        private double previousTime = 0;
        /* Monotonic clock for HITL packet timestamps. Spans on-rod and postStep phases so the FC's
           delta computation gives a sensible dt at the transition. */
        private double hitlTimeS = 0;
        Instant startInstant;

        /* Builds a LogPacketV3 from the given (already body->sensor mapped) sensor
         * values and the current fake-GPS fix, applying the configured sensor
         * noise/bias. Noise is drawn from the seeded Random so runs are
         * deterministic; the draw order here must stay stable for that. */
        private byte[] buildPerturbedPacket(long timeMs, float altitudeM,
                float bmiAccelXg, float bmiAccelYg, float bmiAccelZg,
                float gyroXdps, float gyroYdps, float gyroZdps,
                float adxlXg, float adxlYg, float adxlZg) {
            float altBaro = sensorNoise.distortBaroAltitudeM(altitudeM, r);
            float pressMbar = LogPacketV3.altitudeToPressMbar(altBaro);
            float tempC = sensorNoise.biasTempC(LogPacketV3.altitudeToTempC(altitudeM));

            bmiAccelXg = sensorNoise.perturbAccelG(bmiAccelXg, r);
            bmiAccelYg = sensorNoise.perturbAccelG(bmiAccelYg, r);
            bmiAccelZg = sensorNoise.perturbAccelG(bmiAccelZg, r);
            adxlXg = sensorNoise.perturbAccelG(adxlXg, r);
            adxlYg = sensorNoise.perturbAccelG(adxlYg, r);
            adxlZg = sensorNoise.perturbAccelG(adxlZg, r);

            gyroXdps = sensorNoise.perturbGyroDps(gyroXdps, r);
            gyroYdps = sensorNoise.perturbGyroDps(gyroYdps, r);
            gyroZdps = sensorNoise.perturbGyroDps(gyroZdps, r);

            return LogPacketV3.build(0, timeMs, pressMbar, tempC,
                    bmiAccelXg, bmiAccelYg, bmiAccelZg,
                    gyroXdps, gyroYdps, gyroZdps,
                    adxlXg, adxlYg, adxlZg,
                    fakeGps.latDeg(), fakeGps.lngDeg(), fakeGps.altM(),
                    fakeGps.speedMps(), fakeGps.course(), fakeGps.numSats());
        }

        @Override
        public void startSimulation(SimulationStatus status) throws SimulationException {
            if (mode == AirbrakesMode.FULL_HITL || mode == AirbrakesMode.HITL_CONTROL) {
                /* Open serial port for HITL */
                comPort = SerialPort.getCommPort("COM3");
                // Set full blocking mode
                comPort.setComPortTimeouts(SerialPort.TIMEOUT_READ_BLOCKING | SerialPort.TIMEOUT_WRITE_BLOCKING, 0, 0);
                comPort.setBaudRate(921600);
                comPort.openPort();
                comPort.flushIOBuffers();
            }

            if (mode == AirbrakesMode.FULL_SITL) {
                /* Boot the in-process firmware library for this simulation run.
                 * A unique instance id keeps each run's emulated-radio socket
                 * distinct when several simulations run in one JVM. */
                SitlCreate(sitlInstanceCounter++);
                /* Forward the test's target apogee into the firmware (the flight
                 * build otherwise uses its compiled-in config.h target). */
                SitlSetTargetApogee(GetTargetApogee());
                /* Inject any configured model errors. */
                if (firmwareMassKg > 0) SitlSetMass((float) firmwareMassKg);
                if (firmwareDragScale != 1.0) SitlSetDragScale((float) firmwareDragScale);
            }

            InitController();
            /* Deterministic noise for repeatable scenario tests. */
            r = new Random(noiseSeed);
            previousVelocity = status.getRocketVelocity();
            previousTime = status.getSimulationTime();
            startInstant = Instant.now();
            airbrake_control_interval_timer = 0f;
            deploymentPctCommanded = 0;
            airbrakeDeployment.start();
            hitlTimeS = 0;
            fakeGps.start();

            /* Run filter on the rod for 2 simulated seconds so it can converge on the launch rod angle
               via the gravity vector before the rocket moves. */
            Quaternion q = status.getRocketOrientationQuaternion();
            float altitude = (float) status.getRocketPosition().z;

            if (mode == AirbrakesMode.FULL_HITL || mode == AirbrakesMode.FULL_SITL) {
                /* Send on-rod sensor packets to the FC so its filter converges before launch.
                   (Real time for HITL hardware; as-fast-as-possible for in-process SITL.) */
                Coordinate sfBody = q.invRotate(new Coordinate(0, 0, G_CONST));
                for (int i = 0; i < 200; i++) {
                    hitlTimeS += 0.010;
                    /* Rocket is stationary on the rod: this locks the FC's GPS
                       pad reference to the launch site before any motion. */
                    fakeGps.update(status, 0.010, r);
                    byte[] packet = buildPerturbedPacket(
                            (long) (hitlTimeS * 1000), altitude,
                            (float) (sfBody.y / G_CONST),
                            (float) (sfBody.x / G_CONST),
                            (float) (sfBody.z / G_CONST),
                            0f, 0f, 0f,
                            (float) (-sfBody.x / G_CONST),
                            (float) (-sfBody.y / G_CONST),
                            (float) (sfBody.z / G_CONST));
                    sendFrameGetDeployment(packet); /* reply ignored during convergence */
                    if (mode == AirbrakesMode.FULL_HITL) {
                        try { Thread.sleep(10); } catch (InterruptedException e) { throw new RuntimeException(e); }
                    }
                }
            } else {
                Coordinate accel = q.invRotate(new Coordinate(0, 0, 1));
                for (int i = 0; i < 200; i++) {
                    RunControllerAndGetDeploymentPct((float) accel.x * G_CONST, (float) accel.y * G_CONST, (float) accel.z * G_CONST, (float) accel.x * G_CONST, (float) accel.y * G_CONST, (float) accel.z * G_CONST, 0, 0, 0, altitude, 0.01f);
                }
            }
        }

        @Override
        public void endSimulation(SimulationStatus status, SimulationException exception) {
            if (mode == AirbrakesMode.FULL_SITL) {
                SitlDestroy();
            }
        }

        // We can't look at status.getFlightData() for anything except extension instead because it would
        // apply to the last timestep
        @Override
        public FlightConditions postFlightConditions(SimulationStatus status, FlightConditions flightConditions) throws SimulationException {
            this.flightConditions = flightConditions;

            return flightConditions;
        }

        Random r = new Random();

        float airbrake_control_interval_timer = 0;

        @Override
        public void postStep(SimulationStatus status) throws SimulationException {
            double currentTime = status.getSimulationTime();
            double dt = currentTime - previousTime;
            Coordinate vel = status.getRocketVelocity();

            /* Simulate the airbrake actuator dynamics: the brakes take time to
               reach the commanded deployment, and the open brakes drop the
               avionics-bay pressure (airspeed-dependent), distorting the baro. */
            airbrakeDeployment.step(deploymentPctCommanded, dt, vel.length());
            float distortedAltitude = (float) status.getRocketPosition().z + airbrakeDeployment.altitudeDistortionM();

            if (dt > 0 && previousVelocity != null) {
                Quaternion q = status.getRocketOrientationQuaternion();
                Coordinate rotVel = status.getRocketRotationVelocity();

                // Specific force in world frame: kinematic accel + (0,0,g) since accelerometers don't sense gravity
                double ax = (vel.x - previousVelocity.x) / dt;
                double ay = (vel.y - previousVelocity.y) / dt;
                double az = (vel.z - previousVelocity.z) / dt + G_CONST;
                Coordinate sfBody = q.invRotate(new Coordinate(ax, ay, az));
                Coordinate omegaBody = q.invRotate(rotVel);

                if (mode == AirbrakesMode.FULL_HITL || mode == AirbrakesMode.FULL_SITL) {
                    hitlTimeS += dt;
                    fakeGps.update(status, dt, r);
                    /* The swapped and flipped acceleration axes are to transform the accelerations
                       into sensor frame. The FC code then transforms them back into body frame. */
                    byte[] packet = buildPerturbedPacket(
                            (long) (hitlTimeS * 1000), distortedAltitude,
                            (float) (sfBody.y / G_CONST),
                            (float) (sfBody.x / G_CONST),
                            (float) (sfBody.z / G_CONST),
                            (float) (omegaBody.x * LogPacketV3.DEG_PER_RAD),
                            (float) (omegaBody.y * LogPacketV3.DEG_PER_RAD),
                            (float) (omegaBody.z * LogPacketV3.DEG_PER_RAD),
                            (float) (-sfBody.x / G_CONST),
                            (float) (-sfBody.y / G_CONST),
                            (float) (sfBody.z / G_CONST));
                    deploymentPctCommanded = sendFrameGetDeployment(packet);
                } else if (bypassFilter) {
                    deploymentPctCommanded = RunControllerRawAndGetDeploymentPct((float) vel.x, (float) vel.y, (float) vel.z, distortedAltitude);
                } else {
                    deploymentPctCommanded = RunControllerAndGetDeploymentPct((float) sfBody.x, (float) sfBody.y, (float) sfBody.z, (float) sfBody.x, (float) sfBody.y, (float) sfBody.z, (float) omegaBody.x, (float) omegaBody.y, (float) omegaBody.z, distortedAltitude, (float) dt);
                }
            }

            status.getFlightDataBranch().setValue(fdtDeploymentPctCommanded, deploymentPctCommanded);
            status.getFlightDataBranch().setValue(fdtDistortedAltitude, distortedAltitude);

            double velocityTotal_mps = status.getRocketVelocity().length();
            double mach = velocityTotal_mps / MACH1_MPS;
            final boolean DISABLE_AIRBRAKES = false;

            /* Only deploy the airbrakes if we're under Mach 0.8 */
            if (!DISABLE_AIRBRAKES && mach < 0.8) {
                airbrake_control_interval_timer += dt;
                if (airbrake_control_interval_timer >= AIRBRAKE_CONTROL_INTERVAL_S) {
                    airbrake_control_interval_timer -= AIRBRAKE_CONTROL_INTERVAL_S;

                    deploymentPctCommanded = deploymentPctCommanded;

                    if (mode == AirbrakesMode.HITL_CONTROL) {
                        var arr = (Integer.toString((int) (float) deploymentPctCommanded) + "\n").getBytes();
                        comPort.writeBytes(arr, arr.length);
                    }
                }
            }

            if (mode == AirbrakesMode.HITL_CONTROL) {
                // sleep so the simulation runs in realtime instead of faster than realtime
                double timeSinceStart = Duration.between(startInstant, Instant.now()).get(ChronoUnit.SECONDS);
                double simulationTimeAhead = status.getSimulationTime() - timeSinceStart;
                if (simulationTimeAhead > 0) {
                    try {
                        Thread.sleep((int) (simulationTimeAhead * 1000));
                    } catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    }
                }
            }

            status.getFlightDataBranch().setValue(fdtDeploymentPctSimulatedDynamics, airbrakeDeployment.deploymentPct());

            previousVelocity = vel;
            previousTime = currentTime;
        }

        final double MACH1_MPS = 343;

        @Override
        public AerodynamicForces postAerodynamicCalculation(SimulationStatus status, AerodynamicForces forces) throws SimulationException {
            if (forces.getComponent() != null) System.out.println(forces.getComponent().getComponentName());

            double velocityTotal_mps = status.getRocketVelocity().length();
            double mach = velocityTotal_mps / MACH1_MPS;

            /* Only use the aerodynamics team's drag model if we're under Mach 0.8 */
            if (mach < 0.8) {
                double altitude_m = status.getRocketWorldPosition().getAltitude();
                double density = flightConditions.getAtmosphericConditions().getDensity();

                double dragForce = DragForce(airbrakeDeployment.deploymentPct(), (float) velocityTotal_mps, (float) altitude_m);

                if (velocityTotal_mps > 0.1) {
                    double refArea = flightConditions.getRefArea();
                    double cDAxial = (2 * dragForce) / (density * (velocityTotal_mps * velocityTotal_mps) * refArea);

                    // Note: this calculation isn't actually CDAxial, but it's necessary to override CDAxial
                    // since OR uses CDAxial for its proceeding calculations. Experiments showed the diff between our
                    // "CDAxial" and actual CDAxial (which accounts for AOA) is insignificant so this is fine.
                    forces.setCDaxial(cDAxial);
                }
            }

            return forces;
        }
    }
}