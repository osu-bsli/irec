package space.bsli;


import info.openrocket.core.simulation.exception.SimulationException;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Nominal flights and sensor-noise/dropout robustness, driven through the real
 * firmware running in-process as a deterministic SITL library. (8 simulations.)
 */
public class AirbrakesNominalTest extends AirbrakesSitlTestBase {

    // ---- Nominal: a range of targets and launch angles ----
    @ParameterizedTest(name = "nominal: target {0}m, rod {1}deg")
    @CsvSource({
            "8000, 0",
            "8000, 10",
            "7500, 15",
            "7000, 20"
    })
    void apogee(float targetApogee, float launchRodAngleDeg) throws SimulationException {
        assertEquals(targetApogee, runApogee(targetApogee, launchRodAngleDeg), NOMINAL_TOL_M);
    }

    // ---- Sensor fault / dropout scenarios (representative 8000 m, 5 deg flight) ----

    @Test
    void gpsDropoutMidFlight() throws SimulationException {
        AirbrakesExtension.fakeGps.dropoutAtS = 4.0; // lose GPS during boost/coast
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void accelerometerNoise() throws SimulationException {
        AirbrakesExtension.sensorNoise.accelNoiseStdG = 0.1; // realistic vibration/sensor noise
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void gyroscopeNoise() throws SimulationException {
        AirbrakesExtension.sensorNoise.gyroNoiseStdDps = 5.0; // realistic gyro noise
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void gpsNoise() throws SimulationException {
        AirbrakesExtension.fakeGps.horizNoiseM = 5.0; // ~consumer GPS horizontal noise
        AirbrakesExtension.fakeGps.altNoiseM = 10.0;
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }
}
