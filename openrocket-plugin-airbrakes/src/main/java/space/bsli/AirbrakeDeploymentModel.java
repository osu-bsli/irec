package space.bsli;

import static space.bsli.AirbrakesConfig.DEPLOYMENT_PCT_PER_SEC;

/**
 * Simulates the physical airbrake actuator. The deployment percentage the
 * firmware commands cannot be reached instantly, so the actual ("simulated
 * dynamics") deployment slews toward the commanded value at a fixed rate. The
 * moving brakes also cause a small barometer pressure disturbance (piston
 * suction/compression), exposed as an altitude offset.
 */
public final class AirbrakeDeploymentModel {
    /* Suction/compression effect numbers sloppily empirically determined from
       Nomad 4/11/26 test flight. */
    private static final float ALTITUDE_DISTORTION_M = 0; // TODO

    private float deploymentPct = 0f;
    private float altitudeDistortionM = 0f;

    /** Resets the actuator to fully stowed at the start of a simulation run. */
    public void start() {
        deploymentPct = 0f;
        altitudeDistortionM = 0f;
    }

    /**
     * Advances the simulated actuator one step toward {@code commandedPct} and
     * records the resulting barometer altitude disturbance for this step.
     */
    public void step(float commandedPct, double dt) {
        final float marginPct = (float) (dt * DEPLOYMENT_PCT_PER_SEC);
        altitudeDistortionM = 0f;

        // Simulate the fact that the airbrakes actually take time to move
        if (deploymentPct < commandedPct - marginPct) {
            deploymentPct += (float) (dt * DEPLOYMENT_PCT_PER_SEC);
            // Simulate piston suction effect of airbrakes outward motion on barometer
            altitudeDistortionM = ALTITUDE_DISTORTION_M;
        } else if (deploymentPct > commandedPct + marginPct) {
            deploymentPct -= (float) (dt * DEPLOYMENT_PCT_PER_SEC);
            // Simulate piston compression effect of airbrakes inward motion on barometer
            altitudeDistortionM = -ALTITUDE_DISTORTION_M;
        }

        if (deploymentPct < 0) deploymentPct = 0;
        if (deploymentPct > 100) deploymentPct = 100;
    }

    /** The current simulated (physically achieved) deployment percentage. */
    public float deploymentPct() {
        return deploymentPct;
    }

    /** Barometer altitude disturbance (m) caused by actuator motion this step. */
    public float altitudeDistortionM() {
        return altitudeDistortionM;
    }
}
