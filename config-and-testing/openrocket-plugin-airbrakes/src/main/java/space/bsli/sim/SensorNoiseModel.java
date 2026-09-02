package space.bsli.sim;

import space.bsli.AirbrakesConfig;

import java.util.Random;

/**
 * Simulates accelerometer/gyroscope/barometer sensor imperfections — Gaussian
 * noise and constant biases — applied to the clean sensor values produced by
 * the OpenRocket simulation before they are packed into a {@link space.bsli.LogPacketV3}
 * for the flight computer.
 *
 * Accelerometer noise is modeled per sensor (the BMI323 low-g and ADXL375
 * high-g have very different noise), defaulting to the datasheet-derived
 * standard deviations so every SITL flight carries realistic accelerometer
 * noise. The bias terms default to "none". {@link #reset()} restores those
 * defaults between robustness-test scenarios. Noise is drawn from a
 * caller-supplied {@link Random} so an entire run stays deterministic.
 */
public final class SensorNoiseModel {
    public double bmiAccelNoiseStdG = AirbrakesConfig.BMI323_ACCEL_NOISE_STD_G;  // BMI323 low-g, per axis (g)
    public double adxlAccelNoiseStdG = AirbrakesConfig.ADXL375_ACCEL_NOISE_STD_G; // ADXL375 high-g, per axis (g)
    public double gyroNoiseStdDps = 0.0; // gaussian, per gyro axis (deg/s)
    public double baroBiasM = 0.0;       // constant altitude offset in the baro
    public double baroNoiseStdM = 0.0;   // gaussian altitude noise in the baro
    public double tempBiasC = 0.0;       // temperature offset (degrees C)

    public void reset() {
        bmiAccelNoiseStdG = AirbrakesConfig.BMI323_ACCEL_NOISE_STD_G;
        adxlAccelNoiseStdG = AirbrakesConfig.ADXL375_ACCEL_NOISE_STD_G;
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

    /** Adds one axis of Gaussian BMI323 (low-g) accelerometer noise (g). */
    public float perturbBmiAccelG(float accelG, Random r) {
        if (bmiAccelNoiseStdG > 0) accelG += (float) (r.nextGaussian() * bmiAccelNoiseStdG);
        return accelG;
    }

    /** Adds one axis of Gaussian ADXL375 (high-g) accelerometer noise (g). */
    public float perturbAdxlAccelG(float accelG, Random r) {
        if (adxlAccelNoiseStdG > 0) accelG += (float) (r.nextGaussian() * adxlAccelNoiseStdG);
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
