package space.bsli.sim;

import static space.bsli.AirbrakesConfig.DEPLOYMENT_PCT_PER_SEC;

/**
 * Simulates the physical airbrake actuator and the barometric disturbance the
 * open brakes cause. The deployment percentage the firmware commands cannot be
 * reached instantly, so the actual ("simulated dynamics") deployment slews
 * toward the commanded value at a fixed rate.
 *
 * The open brakes disturb the avionics-bay barometer two ways, both exposed via
 * {@link #altitudeDistortionM()} so the harness can corrupt the baro frames it
 * feeds the flight computer:
 *
 *  - A steady aerodynamic static-pressure drop (suction) while the brakes are
 *    open: airflow disturbed by the deployed brakes lowers the pressure the
 *    barometer sees, so it reads high. Grows with airspeed and deployment.
 *
 *  - A transient "piston" effect while the brakes are physically moving: the
 *    actuator pumps the bay, suction as it drives outward (reads high) and
 *    compression as it retracts inward (reads low), proportional to the
 *    actuator's speed and vanishing once the brakes settle. This is the
 *    control-correlated disturbance the firmware's baro logic worries about.
 */
public final class AirbrakeDeploymentModel {
    /* Avionics-bay barometric error from open-brake aerodynamics: metres of
       (positive) altitude error per m/s of airspeed at full deployment. Scaled
       linearly by the deployment fraction. 0 = no aerodynamic baro error.
       (Sign is positive because a pressure drop reads as a higher altitude.) */
    public double baroPressureDropMPerMps = 0.0;

    /* Transient piston-effect baro error: metres of altitude error per (%/s) of
       actuator motion. Positive while deploying (outward suction -> reads high),
       negative while retracting (inward compression -> reads low), zero once the
       brakes are settled. 0 = no piston effect. */
    public double pistonEffectMPerPctPerSec = 0.0;

    private float deploymentPct = 0f;
    private float altitudeDistortionM = 0f;

    /** Restores the (test-configured) baro-error terms to "off". */
    public void resetConfig() {
        baroPressureDropMPerMps = 0.0;
        pistonEffectMPerPctPerSec = 0.0;
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
        // Track the signed actuator velocity (%/s) for the piston effect.
        float deploymentRatePctPerSec = 0f;
        if (deploymentPct < commandedPct - marginPct) {
            deploymentPct += (float) (dt * DEPLOYMENT_PCT_PER_SEC);
            deploymentRatePctPerSec = (float) DEPLOYMENT_PCT_PER_SEC;   // deploying (outward)
        } else if (deploymentPct > commandedPct + marginPct) {
            deploymentPct -= (float) (dt * DEPLOYMENT_PCT_PER_SEC);
            deploymentRatePctPerSec = -(float) DEPLOYMENT_PCT_PER_SEC;  // retracting (inward)
        }

        if (deploymentPct < 0) deploymentPct = 0;
        if (deploymentPct > 100) deploymentPct = 100;

        /* Steady aerodynamic pressure drop while the brakes are open: proportional
           to airspeed for a given deployment angle, and to the deployment
           fraction. Reads as a positive altitude error. */
        double aeroM = baroPressureDropMPerMps * (deploymentPct / 100.0) * airspeedMps;

        /* Transient piston effect while the actuator moves: positive (suction)
           deploying outward, negative (compression) retracting inward, zero once
           settled. */
        double pistonM = pistonEffectMPerPctPerSec * deploymentRatePctPerSec;

        altitudeDistortionM = (float) (aeroM + pistonM);
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
