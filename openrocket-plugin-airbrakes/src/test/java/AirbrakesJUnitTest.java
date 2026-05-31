import space.bsli.AirbrakesTestLib;
import space.bsli.AirbrakesExtension;

import info.openrocket.core.simulation.exception.SimulationException;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import static org.junit.jupiter.api.Assertions.*;

public class AirbrakesJUnitTest {
    static final float ACCEPTABLE_APOGEE_DEVIATION_M = 100;

    @BeforeAll
    static void beforeAll() {
        AirbrakesTestLib.initialize();
    }

    @ParameterizedTest(name = "Targeting {0}m, launch rod angle {1}deg")
    @CsvSource({
            "8000, 0",
            "8000, 10",
            "7500, 15",
            "7000, 20"
    })
    void apogee(float targetApogee, float launchRodAngleDeg) throws SimulationException {
        var s = AirbrakesTestLib.getSimulation();
        AirbrakesExtension.SetTargetApogee(targetApogee);
        s.getOptions().setLaunchRodAngle(Math.toRadians(launchRodAngleDeg));

        s.simulate();

        assertEquals(targetApogee, s.getSimulatedData().getMaxAltitude(), ACCEPTABLE_APOGEE_DEVIATION_M);
    }
}
