package space.bsli.sim;

import static space.bsli.AirbrakesConfig.DEPLOYMENT_PCT_PER_SEC;

/**
 * Simulates the physical airbrake actuator and the barometric disturbance the
 * open brakes cause. The deployment percentage the firmware commands cannot be
 * reached instantly, so the actual ("simulated dynamics") deployment slews
 * toward the commanded value at a fixed rate.
 *
 * Open brakes also create an aerodynamic static-pressure drop (suction) in the
 * avionics bay: airflow disturbed by the deployed brakes lowers the pressure
 * the barometer sees, so it reads a higher-than-true altitude. The drop grows
 * with airspeed for a given deployment angle. The resulting altitude error is
 * exposed via {@link #altitudeDistortionM()} so the harness can corrupt the
 * baro frames it feeds the flight computer.
 */
public final class AirbrakeDeploymentModel {
    /* Avionics-bay barometric error from open-brake aerodynamics: metres of
       (positive) altitude error per m/s of airspeed at full deployment. Scaled
       linearly by the deployment fraction. 0 = no aerodynamic baro error.
       (Sign is positive because a pressure drop reads as a higher altitude.) */
    public double baroPressureDropMPerMps = 0.0;

    private float deploymentPct = 0f;
    private float altitudeDistortionM = 0f;

    /** Restores the (test-configured) aerodynamic baro error to "off". */
    public void resetConfig() {
        baroPressureDropMPerMps = 0.0;
    }

    /** Resets the actuator to fully stowed at the start of a simulation run. */
    public void start() {
        deploymentPct = 0f;
        altitudeDistortionM = 0f;
    }

    /**
     * Advances the simulated actuator one step toward {@code commandedPct} and
     * recomputes the avionics-bay barometric altitude error for the current
     * deployment and {@code airspeedMps}.
     */
    public void step(float commandedPct, double dt, double airspeedMps) {
        final float marginPct = (float) (dt * DEPLOYMENT_PCT_PER_SEC);

        // The airbrakes take time to physically reach the commanded deployment.
        if (deploymentPct < commandedPct - marginPct) {
            deploymentPct += (float) (dt * DEPLOYMENT_PCT_PER_SEC);
        } else if (deploymentPct > commandedPct + marginPct) {
            deploymentPct -= (float) (dt * DEPLOYMENT_PCT_PER_SEC);
        }

        if (deploymentPct < 0) deploymentPct = 0;
        if (deploymentPct > 100) deploymentPct = 100;

        /* Aerodynamic pressure drop in the avionics bay while the brakes are
           open: proportional to airspeed for a given deployment angle, and to
           the deployment fraction. Reads as a positive altitude error. */
        altitudeDistortionM = (float) (baroPressureDropMPerMps
                * (deploymentPct / 100.0) * airspeedMps);
    }

    /** The current simulated (physically achieved) deployment percentage. */
    public float deploymentPct() {
        return deploymentPct;
    }

    /** Barometer altitude error (m) from open-brake aerodynamics this step. */
    public float altitudeDistortionM() {
        return altitudeDistortionM;
    }
}
