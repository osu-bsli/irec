import info.openrocket.core.document.OpenRocketDocument;
import info.openrocket.core.document.Simulation;
import info.openrocket.core.file.GeneralRocketLoader;
import info.openrocket.core.file.RocketLoadException;
import info.openrocket.core.simulation.exception.SimulationException;
import info.openrocket.core.startup.Application;
import info.openrocket.core.startup.OpenRocketCore;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.io.File;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class AirbrakesTest {
    static final String ORK_FILE_PATH = "IREC 4.22.26.ork";
    static final float ACCEPTABLE_APOGEE_DEVIATION_M = 20;

    @BeforeAll
    static void beforeAll() {
        // Initialize OpenRocket
        OpenRocketCore.initialize();

        // tell OpenRocket where to load thrust curve files from
        Application.getPreferences().setUserThrustCurveFiles(List.of(
                new File(".")   // load from CWD
        ));
    }

    Simulation getSimulation() {
        GeneralRocketLoader loader = new GeneralRocketLoader(new File(ORK_FILE_PATH));
        OpenRocketDocument document = null;
        try {
            document = loader.load();
        } catch (RocketLoadException e) {
            throw new RuntimeException(e);
        }
        return document.getSimulation(0);
    }

    @ParameterizedTest(name = "Targeting {0}m, launch rod angle {1}deg")
    @CsvSource({
            "8000, 0",
            "8000, 10",
            "7500, 15",
            "7000, 20"
    })
    void apogee(float targetApogee, float launchRodAngleDeg) throws SimulationException {
        var s = getSimulation();
        Airbrakes.SetTargetApogee(targetApogee);
        s.getOptions().setLaunchRodAngle(Math.toRadians(launchRodAngleDeg));

        s.simulate();

        assertEquals(targetApogee, s.getSimulatedData().getMaxAltitude(), ACCEPTABLE_APOGEE_DEVIATION_M);
    }
}
