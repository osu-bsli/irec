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
import info.openrocket.core.util.WorldCoordinate;
import com.fazecast.jSerialComm.*;

import static space.bsli.AirbrakesConfig.AIRBRAKE_CONTROL_INTERVAL_S;
import static space.bsli.AirbrakesConfig.DEPLOYMENT_TIME_S;
import static space.bsli.AirbrakesConfig.DEPLOYMENT_PCT_PER_SEC;
import static space.bsli.AirbrakesConfig.MODE;

import space.bsli.AirbrakesConfig.AirbrakesMode;

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

    public static native int SitlFeedPacket(byte[] logPacketV3);

    public static native void SitlDestroy();

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
        private float deploymentPctSimulatedDynamics = 0;
        private Coordinate previousVelocity = null;
        private double previousTime = 0;
        /* Monotonic clock for HITL packet timestamps. Spans on-rod and postStep phases so the FC's
           delta computation gives a sensible dt at the transition. */
        private double hitlTimeS = 0;
        Instant startInstant;

        /* ---- Fake GPS state (FULL_HITL only) ----
         * The most recently emitted fix is cached and re-sent unchanged between
         * GPS updates so the flight computer sees a realistic low-rate GPS. */
        private static final double R_EARTH_M = 6371000.0; // matches the FC's gps_compute_enu
        private float gpsLatDeg = Float.NaN, gpsLngDeg = Float.NaN, gpsAltM = Float.NaN;
        private float gpsSpeedMps = 0f;
        private int gpsCourse = LogPacketV3.GPS_COURSE_NONE;
        private int gpsNumSats = 0;
        private float gpsUpdateTimer = 0f;
        private boolean haveGpsFix = false;
        private double prevGpsLatDeg = 0, prevGpsLngDeg = 0, prevGpsTimeS = 0;

        /* Recomputes the cached fake GPS fix from the simulation at most once per
         * GPS_UPDATE_INTERVAL_S. Speed/course are derived from the lat/lng delta
         * since the previous fix so they stay self-consistent with position
         * regardless of OpenRocket's axis conventions. */
        private void updateFakeGps(SimulationStatus status, double dt) {
            if (!AirbrakesConfig.FAKE_GPS_IN_HITL) {
                gpsLatDeg = Float.NaN;
                gpsLngDeg = Float.NaN;
                gpsAltM = Float.NaN;
                gpsSpeedMps = 0f;
                gpsCourse = LogPacketV3.GPS_COURSE_NONE;
                gpsNumSats = 0;
                return;
            }

            gpsUpdateTimer += dt;
            if (haveGpsFix && gpsUpdateTimer < AirbrakesConfig.GPS_UPDATE_INTERVAL_S) {
                return; // hold previous fix; FC sees "no new GPS"
            }
            gpsUpdateTimer = 0f;

            WorldCoordinate wc = status.getRocketWorldPosition();
            double lat = wc.getLatitudeDeg();
            double lng = wc.getLongitudeDeg();
            double alt = wc.getAltitude();

            if (AirbrakesConfig.GPS_HORIZONTAL_NOISE_M > 0) {
                double latRad = Math.toRadians(lat);
                lat += (r.nextGaussian() * AirbrakesConfig.GPS_HORIZONTAL_NOISE_M) / R_EARTH_M * (180.0 / Math.PI);
                lng += (r.nextGaussian() * AirbrakesConfig.GPS_HORIZONTAL_NOISE_M) / (R_EARTH_M * Math.cos(latRad)) * (180.0 / Math.PI);
            }
            if (AirbrakesConfig.GPS_ALTITUDE_NOISE_M > 0) {
                alt += r.nextGaussian() * AirbrakesConfig.GPS_ALTITUDE_NOISE_M;
            }

            double tNow = status.getSimulationTime();
            if (haveGpsFix) {
                double dtGps = tNow - prevGpsTimeS;
                if (dtGps > 1e-3) {
                    double latRad = Math.toRadians(lat);
                    double dNorth = Math.toRadians(lat - prevGpsLatDeg) * R_EARTH_M;
                    double dEast = Math.toRadians(lng - prevGpsLngDeg) * R_EARTH_M * Math.cos(latRad);
                    double speed = Math.hypot(dEast, dNorth) / dtGps;
                    if (speed >= AirbrakesConfig.GPS_MIN_SPEED_FOR_COURSE_MPS) {
                        double courseDeg = Math.toDegrees(Math.atan2(dEast, dNorth));
                        if (courseDeg < 0) courseDeg += 360.0;
                        gpsCourse = (int) Math.round(courseDeg * 100.0);
                    } else {
                        gpsCourse = LogPacketV3.GPS_COURSE_NONE;
                    }
                    gpsSpeedMps = (float) speed;
                }
            } else {
                gpsSpeedMps = 0f;
                gpsCourse = LogPacketV3.GPS_COURSE_NONE;
            }

            gpsLatDeg = (float) lat;
            gpsLngDeg = (float) lng;
            gpsAltM = (float) alt;
            gpsNumSats = AirbrakesConfig.GPS_NUM_SATS;

            prevGpsLatDeg = lat;
            prevGpsLngDeg = lng;
            prevGpsTimeS = tNow;
            haveGpsFix = true;
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
            }

            InitController();
            previousVelocity = status.getRocketVelocity();
            previousTime = status.getSimulationTime();
            startInstant = Instant.now();
            airbrake_control_interval_timer = 0f;
            deploymentPctCommanded = 0;
            deploymentPctSimulatedDynamics = 0;
            hitlTimeS = 0;
            haveGpsFix = false;
            gpsUpdateTimer = 0f;

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
                    updateFakeGps(status, 0.010);
                    byte[] packet = LogPacketV3.build(
                            0, (long) (hitlTimeS * 1000),
                            LogPacketV3.altitudeToPressMbar(altitude),
                            LogPacketV3.altitudeToTempC(altitude),
                            (float) (sfBody.y / G_CONST),
                            (float) (sfBody.x / G_CONST),
                            (float) (sfBody.z / G_CONST),
                            0f, 0f, 0f,
                            (float) (-sfBody.x / G_CONST),
                            (float) (-sfBody.y / G_CONST),
                            (float) (sfBody.z / G_CONST),
                            gpsLatDeg, gpsLngDeg, gpsAltM, gpsSpeedMps,
                            gpsCourse, gpsNumSats);
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

            float distortedAltitude = (float) status.getRocketPosition().z;

            /* Simulate dynamics of airbrakes deployment */

            final float MARGIN_PCT = (float) (dt * DEPLOYMENT_PCT_PER_SEC);
            final float ALTITUDE_DISTORTION_M = 0; // TODO

            // Simulate the fact that the airbrakes actually take time to move
            if (deploymentPctSimulatedDynamics < deploymentPctCommanded - MARGIN_PCT) {
                deploymentPctSimulatedDynamics += (float) (dt * DEPLOYMENT_PCT_PER_SEC);
                // Simulate piston suction effect of airbrakes outward motion on barometer
                distortedAltitude += ALTITUDE_DISTORTION_M;
            } else if (deploymentPctSimulatedDynamics > deploymentPctCommanded + MARGIN_PCT) {
                deploymentPctSimulatedDynamics -= (float) (dt * DEPLOYMENT_PCT_PER_SEC);
                // Simulate piston compression effect of airbrakes inward motion on barometer
                distortedAltitude -= ALTITUDE_DISTORTION_M;
            }

            if (deploymentPctSimulatedDynamics < 0) deploymentPctSimulatedDynamics = 0;
            if (deploymentPctSimulatedDynamics > 100) deploymentPctSimulatedDynamics = 100;

            // Suction/compression effect numbers sloppily empirically determined from Nomad 4/11/26 test flight

            /* End dynamics simulation */

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
                    updateFakeGps(status, dt);
                    /* The swapped and flipped acceleration axes are to transform the accelerations
                       into sensor frame. The FC code then transforms them back into body frame. */
                    byte[] packet = LogPacketV3.build(
                            0,
                            (long) (hitlTimeS * 1000),
                            LogPacketV3.altitudeToPressMbar(distortedAltitude),
                            LogPacketV3.altitudeToTempC(distortedAltitude),
                            (float) (sfBody.y / G_CONST),
                            (float) (sfBody.x / G_CONST),
                            (float) (sfBody.z / G_CONST),
                            (float) (omegaBody.x * LogPacketV3.DEG_PER_RAD),
                            (float) (omegaBody.y * LogPacketV3.DEG_PER_RAD),
                            (float) (omegaBody.z * LogPacketV3.DEG_PER_RAD),
                            (float) (-sfBody.x / G_CONST),
                            (float) (-sfBody.y / G_CONST),
                            (float) (sfBody.z / G_CONST),
                            gpsLatDeg, gpsLngDeg, gpsAltM, gpsSpeedMps,
                            gpsCourse, gpsNumSats);
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

            status.getFlightDataBranch().setValue(fdtDeploymentPctSimulatedDynamics, deploymentPctSimulatedDynamics);

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

                double dragForce = DragForce(deploymentPctSimulatedDynamics, (float) velocityTotal_mps, (float) altitude_m);

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