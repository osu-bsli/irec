import info.openrocket.core.document.OpenRocketDocument;
import info.openrocket.core.document.Simulation;
import info.openrocket.core.file.GeneralRocketLoader;
import info.openrocket.core.file.RocketLoadException;
import info.openrocket.core.startup.Application;
import info.openrocket.core.startup.OpenRocketCore;

import java.io.File;
import java.util.List;

public class AirbrakesTestLib {
    static final String ORK_FILE_PATH = "IREC 4.22.26.ork";

    public static void initialize()
    {
        // Initialize OpenRocket
        OpenRocketCore.initialize();

        // tell OpenRocket where to load thrust curve files from
        Application.getPreferences().setUserThrustCurveFiles(List.of(
                new File(".")   // load from CWD
        ));
    }

    public static Simulation getSimulation() {
        GeneralRocketLoader loader = new GeneralRocketLoader(new File(ORK_FILE_PATH));
        OpenRocketDocument document = null;
        try {
            document = loader.load();
        } catch (RocketLoadException e) {
            throw new RuntimeException(e);
        }
        return document.getSimulation(0);
    }
}
