import space.bsli.AirbrakesTestLib;
import space.bsli.AirbrakesExtension;
import space.bsli.AirbrakesConfig.AirbrakesMode;

import info.openrocket.core.document.Simulation;
import info.openrocket.core.simulation.exception.SimulationException;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Drives OpenRocket simulations through the real flight firmware running
 * in-process as a deterministic SITL library (sensor acquire -> GNC filter ->
 * deploy task), and checks that the commanded airbrakes keep the apogee close
 * to target under nominal conditions and a range of sensor/model faults.
 *
 * Switch back to the PC-side algorithm with -Dairbrakes.mode=CLOSED_LOOP_SIM.
 */
public class AirbrakesJUnitTest {
    /* Tolerances reflect what the full firmware achieves, not the idealized
     * algorithm. Nominal full-firmware control (with fused GPS) lands within a
     * few hundred metres; fault scenarios are allowed to degrade further but
     * must still demonstrate the airbrakes are meaningfully controlling apogee. */
    static final float NOMINAL_TOL_M = 200;
    static final float SENSOR_FAULT_TOL_M = 300;
    static final float MODEL_ERROR_TOL_M = 400;

    @BeforeAll
    static void beforeAll() {
        AirbrakesTestLib.initialize();
        AirbrakesExtension.mode = AirbrakesMode.valueOf(
                System.getProperty("airbrakes.mode", "FULL_SITL"));
        System.out.println("[test] Airbrakes mode: " + AirbrakesExtension.mode);
    }

    @BeforeEach
    void beforeEach() {
        AirbrakesExtension.resetScenario();
    }

    /** Runs one simulation to apogee and returns the achieved max altitude (m). */
    private float runApogee(float targetApogee, float launchRodAngleDeg) throws SimulationException {
        Simulation s = AirbrakesTestLib.getSimulation();
        AirbrakesExtension.SetTargetApogee(targetApogee);
        s.getOptions().setLaunchRodAngle(Math.toRadians(launchRodAngleDeg));
        s.simulate();
        float achieved = (float) s.getSimulatedData().getMaxAltitude();
        System.out.printf("[apogee] target=%.0f rod=%.0fdeg -> achieved=%.1f (err %+.1f)%n",
                targetApogee, launchRodAngleDeg, achieved, achieved - targetApogee);
        return achieved;
    }

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

    // ---- Fault / robustness scenarios (representative 8000 m, 5 deg flight) ----

    @Test
    void gpsDropoutMidFlight() throws SimulationException {
        AirbrakesExtension.gpsDropoutAtS = 4.0; // lose GPS during boost/coast
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void accelerometerNoise() throws SimulationException {
        AirbrakesExtension.accelNoiseStdG = 0.1; // realistic vibration/sensor noise
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void gyroscopeNoise() throws SimulationException {
        AirbrakesExtension.gyroNoiseStdDps = 5.0; // realistic gyro noise
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void gpsNoise() throws SimulationException {
        AirbrakesExtension.gpsHorizNoiseM = 5.0; // ~consumer GPS horizontal noise
        AirbrakesExtension.gpsAltNoiseM = 10.0;
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void temperatureBias() throws SimulationException {
        AirbrakesExtension.tempBiasC = 30.0; // baro temperature reading way off
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void altitudeBias() throws SimulationException {
        // A constant baro offset should cancel via the pad-altitude reference.
        AirbrakesExtension.baroBiasM = 100.0;
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void rocketMassWrongInFirmware() throws SimulationException {
        // Firmware believes the rocket is ~20% lighter than it really is.
        AirbrakesExtension.firmwareMassKg = 25.0; // true mass ~31.7 kg
        assertEquals(8000, runApogee(8000, 5), MODEL_ERROR_TOL_M);
    }

    @Test
    void dragModelWrongInFirmware() throws SimulationException {
        // Firmware's modeled airbrake drag is 30% low.
        AirbrakesExtension.firmwareDragScale = 0.7;
        assertEquals(8000, runApogee(8000, 5), MODEL_ERROR_TOL_M);
    }
}
