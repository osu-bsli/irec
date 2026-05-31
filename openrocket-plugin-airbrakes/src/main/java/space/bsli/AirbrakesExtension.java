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

            InitController();
            previousVelocity = status.getRocketVelocity();
            previousTime = status.getSimulationTime();
            startInstant = Instant.now();
            airbrake_control_interval_timer = 0f;
            deploymentPctCommanded = 0;
            deploymentPctSimulatedDynamics = 0;
            hitlTimeS = 0;

            /* Run filter on the rod for 2 simulated seconds so it can converge on the launch rod angle
               via the gravity vector before the rocket moves. */
            Quaternion q = status.getRocketOrientationQuaternion();
            float altitude = (float) status.getRocketPosition().z;

            if (mode == AirbrakesMode.FULL_HITL) {
                /* Send on-rod sensor packets to the FC in real time so its filter converges before launch. */
                Coordinate sfBody = q.invRotate(new Coordinate(0, 0, G_CONST));
                for (int i = 0; i < 200; i++) {
                    hitlTimeS += 0.010;
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
                            (float) (sfBody.z / G_CONST));
                    comPort.writeBytes(packet, packet.length);
                    byte[] buffer = new byte[1];
                    comPort.readBytes(buffer, 1, 0);
                    try { Thread.sleep(10); } catch (InterruptedException e) { throw new RuntimeException(e); }
                }
            } else {
                Coordinate accel = q.invRotate(new Coordinate(0, 0, 1));
                for (int i = 0; i < 200; i++) {
                    RunControllerAndGetDeploymentPct((float) accel.x * G_CONST, (float) accel.y * G_CONST, (float) accel.z * G_CONST, (float) accel.x * G_CONST, (float) accel.y * G_CONST, (float) accel.z * G_CONST, 0, 0, 0, altitude, 0.01f);
                }
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

                if (mode == AirbrakesMode.FULL_HITL) {
                    hitlTimeS += dt;
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
                            (float) (sfBody.z / G_CONST));
                    comPort.writeBytes(packet, packet.length);

                    byte[] buffer = new byte[1];
                    if (1 != comPort.readBytes(buffer, 1, 0)) {
                        throw new RuntimeException();
                    }
                    deploymentPctCommanded = buffer[0];
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