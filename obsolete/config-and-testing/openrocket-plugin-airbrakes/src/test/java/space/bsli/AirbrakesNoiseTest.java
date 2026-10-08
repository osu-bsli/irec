package space.bsli;

import info.openrocket.core.simulation.exception.SimulationException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Verifies the sensor-noise injection itself: that it actually perturbs the
 * flight (so it is wired up correctly), that it is reproducible for a fixed
 * seed, and that it degrades targeting only as much as expected — negligibly for
 * the realistic datasheet level, gracefully for a heavy stress level.
 * (5 simulations.)
 */
public class AirbrakesNoiseTest extends AirbrakesSitlTestBase {

    /** Clears every sensor-noise channel (the model otherwise defaults to the
     *  datasheet-derived accelerometer noise). */
    private static void zeroAllSensorNoise() {
        AirbrakesExtension.sensorNoise.bmiAccelNoiseStdG = 0;
        AirbrakesExtension.sensorNoise.adxlAccelNoiseStdG = 0;
        AirbrakesExtension.sensorNoise.gyroNoiseStdDps = 0;
        AirbrakesExtension.sensorNoise.baroNoiseStdM = 0;
    }

    private static void setHeavySensorNoise() {
        AirbrakesExtension.sensorNoise.bmiAccelNoiseStdG = 0.3;
        AirbrakesExtension.sensorNoise.adxlAccelNoiseStdG = 0.3;
        AirbrakesExtension.sensorNoise.gyroNoiseStdDps = 20.0;
        AirbrakesExtension.sensorNoise.baroNoiseStdM = 5.0;
    }

    /**
     * Heavy sensor noise must (a) actually change the achieved apogee — proving
     * the noise reaches the flight computer rather than being silently dropped —
     * (b) be bit-for-bit reproducible for the fixed seed, and (c) still leave the
     * airbrakes controlling apogee within the sensor-fault tolerance.
     */
    @Test
    void sensorNoiseIsInjectedDeterministicAndControlled() throws SimulationException {
        final float target = 8000, rod = 5;

        AirbrakesExtension.resetScenario();
        zeroAllSensorNoise();
        float clean = runApogee(target, rod);

        AirbrakesExtension.resetScenario();
        setHeavySensorNoise();
        float noisy1 = runApogee(target, rod);

        AirbrakesExtension.resetScenario();
        setHeavySensorNoise();
        float noisy2 = runApogee(target, rod);

        System.out.printf("[noise-inject] clean=%.2f noisy1=%.2f noisy2=%.2f%n", clean, noisy1, noisy2);

        // (a) noise is actually injected: it perturbs the achieved apogee well
        //     beyond the SITL's ~0.01 m run-to-run floating-point jitter.
        assertNotEquals(clean, noisy1, 1.0,
                "sensor noise should perturb the achieved apogee (is it being injected?)");
        // (b) the seeded noise is reproducible: two identical runs agree to within
        //     that inherent SITL jitter (the noise draws add no extra randomness).
        assertEquals(noisy1, noisy2, 0.5,
                "seeded sensor noise should be reproducible across runs");
        // (c) control still holds under heavy noise.
        assertEquals(target, noisy1, SENSOR_FAULT_TOL_M,
                "airbrakes should still control apogee under heavy sensor noise");
    }

    /**
     * The realistic datasheet sensor noise (the default on every flight) should
     * barely degrade targeting versus a perfectly clean run — confirming the
     * noise level is sane and the control is robust to it.
     */
    @Test
    void realisticNoiseBarelyDegradesTargeting() throws SimulationException {
        final float target = 8000, rod = 5;

        AirbrakesExtension.resetScenario();
        zeroAllSensorNoise();
        float errClean = Math.abs(runApogee(target, rod) - target);

        AirbrakesExtension.resetScenario(); // realistic datasheet noise is the default
        float errRealistic = Math.abs(runApogee(target, rod) - target);

        System.out.printf("[noise-degrade] apogee err: clean=%.1f m, realistic=%.1f m (delta %+.1f)%n",
                errClean, errRealistic, errRealistic - errClean);

        assertTrue(errRealistic - errClean < 50f,
                String.format("realistic sensor noise should barely degrade targeting "
                        + "(clean err=%.1f m, realistic err=%.1f m)", errClean, errRealistic));
        assertTrue(errRealistic < NOMINAL_TOL_M,
                "targeting under realistic noise should stay within the nominal tolerance");
    }
}
