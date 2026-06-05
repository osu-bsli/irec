import space.bsli.AirbrakesExtension;

import info.openrocket.core.simulation.exception.SimulationException;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Firmware model-error robustness and the baro-pressure-drop / GPS scenarios.
 * (8 simulations: 4 single-run model-error tests + 2 two-run GPS comparisons.)
 */
public class AirbrakesFaultTest extends AirbrakesSitlTestBase {

    // ---- Model-error scenarios (representative 8000 m, 5 deg flight) ----

    @Test
    void temperatureBias() throws SimulationException {
        AirbrakesExtension.sensorNoise.tempBiasC = 30.0; // baro temperature reading way off
        assertEquals(8000, runApogee(8000, 5), SENSOR_FAULT_TOL_M);
    }

    @Test
    void altitudeBias() throws SimulationException {
        // A constant baro offset should cancel via the pad-altitude reference.
        AirbrakesExtension.sensorNoise.baroBiasM = 100.0;
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

    // ---- Baro-pressure-drop scenarios: GPS as an independent altitude reference ----

    /**
     * With the brakes' aerodynamic pressure drop corrupting the barometer in
     * proportion to airspeed, GPS supplies an independent altitude/position
     * reference the GNC filter can fuse. Targeting should therefore be more
     * accurate with GPS available than with GPS absent for the whole flight.
     */
    @Test
    void gpsImprovesTargetingUnderBaroPressureDrop() throws SimulationException {
        final float target = 8000, rod = 5;

        AirbrakesExtension.resetScenario();
        AirbrakesExtension.airbrakeDeployment.baroPressureDropMPerMps = BARO_PRESSURE_DROP_M_PER_MPS;
        float errWithGps = Math.abs(runApogee(target, rod) - target);

        // Same baro corruption, but GPS never available (drops at t=0, never recovers).
        AirbrakesExtension.resetScenario();
        AirbrakesExtension.airbrakeDeployment.baroPressureDropMPerMps = BARO_PRESSURE_DROP_M_PER_MPS;
        AirbrakesExtension.fakeGps.dropoutAtS = 0.0;
        float errWithoutGps = Math.abs(runApogee(target, rod) - target);

        System.out.printf("[baro-drop] apogee err: with GPS=%.1f m, without GPS=%.1f m%n",
                errWithGps, errWithoutGps);
        assertTrue(errWithGps < errWithoutGps,
                String.format("GPS should improve targeting under baro pressure drop "
                        + "(with GPS err=%.1f m, without GPS err=%.1f m)", errWithGps, errWithoutGps));
    }

    /**
     * Under the same baro pressure-drop error, a GPS outage that ends mid-flight
     * (the receiver re-acquires before apogee) should leave the filter better
     * corrected at apogee than an outage that lasts the rest of the flight, so
     * recovering GPS beats permanently losing it.
     */
    @Test
    void gpsRecoveryBeatsPermanentLossUnderBaroError() throws SimulationException {
        final float target = 8000, rod = 5;
        final double dropAt = 4.0, recoverAt = 20.0;

        // GPS drops mid-flight but comes back well before apogee.
        AirbrakesExtension.resetScenario();
        AirbrakesExtension.airbrakeDeployment.baroPressureDropMPerMps = BARO_PRESSURE_DROP_M_PER_MPS;
        AirbrakesExtension.fakeGps.dropoutAtS = dropAt;
        AirbrakesExtension.fakeGps.recoverAtS = recoverAt;
        float errRecover = Math.abs(runApogee(target, rod) - target);

        // Same drop, but GPS never returns.
        AirbrakesExtension.resetScenario();
        AirbrakesExtension.airbrakeDeployment.baroPressureDropMPerMps = BARO_PRESSURE_DROP_M_PER_MPS;
        AirbrakesExtension.fakeGps.dropoutAtS = dropAt;
        float errNever = Math.abs(runApogee(target, rod) - target);

        System.out.printf("[gps-recover] apogee err: recover@%.0fs=%.1f m, never=%.1f m%n",
                recoverAt, errRecover, errNever);
        assertTrue(errRecover < errNever,
                String.format("GPS recovery should beat permanent loss under baro error "
                        + "(recover err=%.1f m, never err=%.1f m)", errRecover, errNever));
    }
}
