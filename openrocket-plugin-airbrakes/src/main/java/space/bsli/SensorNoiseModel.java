package space.bsli;

import java.util.Random;

/**
 * Simulates accelerometer/gyroscope/barometer sensor imperfections — Gaussian
 * noise and constant biases — applied to the clean sensor values produced by
 * the OpenRocket simulation before they are packed into a {@link LogPacketV3}
 * for the flight computer.
 *
 * All perturbations default to "none"; {@link #reset()} restores that state
 * between robustness-test scenarios. Noise is drawn from a caller-supplied
 * {@link Random} so an entire run stays deterministic for a given seed.
 */
public final class SensorNoiseModel {
    public double accelNoiseStdG = 0.0;  // gaussian, per accelerometer axis (g)
    public double gyroNoiseStdDps = 0.0; // gaussian, per gyro axis (deg/s)
    public double baroBiasM = 0.0;       // constant altitude offset in the baro
    public double baroNoiseStdM = 0.0;   // gaussian altitude noise in the baro
    public double tempBiasC = 0.0;       // temperature offset (degrees C)

    public void reset() {
        accelNoiseStdG = 0.0;
        gyroNoiseStdDps = 0.0;
        baroBiasM = 0.0;
        baroNoiseStdM = 0.0;
        tempBiasC = 0.0;
    }

    /** Clean altitude (m) -> barometric altitude with constant bias + noise. */
    public float distortBaroAltitudeM(float altitudeM, Random r) {
        float altBaro = altitudeM + (float) baroBiasM;
        if (baroNoiseStdM > 0) altBaro += (float) (r.nextGaussian() * baroNoiseStdM);
        return altBaro;
    }

    /** Adds one axis of Gaussian accelerometer noise (g). */
    public float perturbAccelG(float accelG, Random r) {
        if (accelNoiseStdG > 0) accelG += (float) (r.nextGaussian() * accelNoiseStdG);
        return accelG;
    }

    /** Adds one axis of Gaussian gyroscope noise (deg/s). */
    public float perturbGyroDps(float gyroDps, Random r) {
        if (gyroNoiseStdDps > 0) gyroDps += (float) (r.nextGaussian() * gyroNoiseStdDps);
        return gyroDps;
    }

    /** Applies the constant barometer temperature bias (deg C). */
    public float biasTempC(float tempC) {
        return tempC + (float) tempBiasC;
    }
}
