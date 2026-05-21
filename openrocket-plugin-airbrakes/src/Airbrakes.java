
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

import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Random;

public class Airbrakes extends AbstractSimulationExtension {

    private boolean bypassFilter = false;

    public SerialPort comPort;

    public Airbrakes() {
        this.comPort = SerialPort.getCommPort("COM3");
        this.comPort.setBaudRate(921600);
        this.comPort.openPort();
    }

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

    public static native float RunControllerAndGetDeploymentPct(
            float accelerometerX_mps2,
            float accelerometerY_mps2,
            float accelerometerZ_mps2,
            float accelerometerHgX_mps2,
            float accelerometerHgY_mps2,
            float accelerometerHgZ_mps2,
            float gyroscopeX_radps,
            float gyroscopeY_radps,
            float gyroscopeZ_radps,
            float barometer_m,
            float dt
    );

    public static native float RunControllerRawAndGetDeploymentPct(
            float velocityX_mps,
            float velocityY_mps,
            float velocityZ_mps,
            float altitude_m
    );

    @Override
    public String getName() {
        return "BSLI IREC Airbrakes";
    }

    @Override
    public String getDescription() {
        return "Simple extension example for air-start";
    }

    private class AirbrakesListener extends AbstractSimulationListener {
        private static final FlightDataType fdtDeploymentPctCommanded = FlightDataType.getType("Airbrake deployment commanded", "%",
                UnitGroup.UNITS_NONE);
        private static final FlightDataType fdtDeploymentPctSimulatedDynamics = FlightDataType.getType("Airbrake deployment simulated dynamics", "%",
                UnitGroup.UNITS_NONE);
        private static final FlightDataType fdtDistortedAltitude = FlightDataType.getType("Altitude w/simulated baro errors", "m",
                UnitGroup.UNITS_LENGTH);

        private FlightConditions flightConditions = null;
        private float deploymentPctCalculated = 0;
        private float deploymentPctCommanded = 0;
        private float deploymentPctSimulatedDynamics = 0;
        private final float DEPLOYMENT_TIME_S = 1.28333333F;
        private final float DEPLOYMENT_PCT_PER_SEC = 100F / DEPLOYMENT_TIME_S;
        private Coordinate previousVelocity = null;
        private double previousTime = 0;
        Instant startInstant;

        @Override
        public void startSimulation(SimulationStatus status) throws SimulationException {
            InitController();
            previousVelocity = status.getRocketVelocity();
            previousTime = status.getSimulationTime();
            startInstant = Instant.now();
            airbrake_control_interval_timer = 0f;
            deploymentPctCalculated = 0;
            deploymentPctCommanded = 0;
            deploymentPctSimulatedDynamics = 0;

            /* Run filter a bunch of times on the rod to let the filter obtain launch rod angle via gravity vector */
            var q = status.getRocketOrientationQuaternion();
            var accel = q.invRotate(new Coordinate(0, 0, 1));
            for (int i = 0; i < 1000; i++) {
                RunControllerAndGetDeploymentPct(
                        (float)accel.x * G_CONST,
                        (float)accel.y * G_CONST,
                        (float)accel.z * G_CONST,
                        (float)accel.x * G_CONST,
                        (float)accel.y * G_CONST,
                        (float)accel.z * G_CONST,
                        0,
                        0,
                        0,
                        (float) status.getRocketPosition().z,
                        0.01f
                );
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

        final boolean HITL_AIRBRAKE_CONTROL = false;

        final float AIRBRAKE_CONTROL_INTERVAL_S = 2f; // 10 Hz, 100 ms period
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
                if (bypassFilter) {
                    deploymentPctCalculated = RunControllerRawAndGetDeploymentPct(
                            (float) vel.x,
                            (float) vel.y,
                            (float) vel.z,
                            distortedAltitude
                    );
                } else {
                    Quaternion q = status.getRocketOrientationQuaternion();
                    Coordinate rotVel = status.getRocketRotationVelocity();

                    // Specific force in world frame: kinematic accel + (0,0,g) since accelerometers don't sense gravity
                    double ax = (vel.x - previousVelocity.x) / dt;
                    double ay = (vel.y - previousVelocity.y) / dt;
                    double az = (vel.z - previousVelocity.z) / dt + G_CONST;
                    Coordinate sfBody = q.invRotate(new Coordinate(ax, ay, az));
                    Coordinate omegaBody = q.invRotate(rotVel);

                    deploymentPctCalculated = RunControllerAndGetDeploymentPct(
                            (float) sfBody.x,
                            (float) sfBody.y,
                            (float) sfBody.z,
                            (float) sfBody.x,
                            (float) sfBody.y,
                            (float) sfBody.z,
                            (float) omegaBody.x,
                            (float) omegaBody.y,
                            (float) omegaBody.z,
                            distortedAltitude,
                            (float) dt
                    );
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

                    deploymentPctCommanded = deploymentPctCalculated;

                    if (HITL_AIRBRAKE_CONTROL) {
                        var arr = (Integer.toString((int) (float) deploymentPctCommanded) + "\n").getBytes();
                        comPort.writeBytes(arr, arr.length);
                    }
                }
            }

            if (HITL_AIRBRAKE_CONTROL) {
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