import info.openrocket.core.document.OpenRocketDocument;
import info.openrocket.core.document.Simulation;
import info.openrocket.core.file.DatabaseMotorFinder;
import info.openrocket.core.file.GeneralRocketLoader;
import info.openrocket.core.file.RocketLoadException;
import info.openrocket.core.file.motor.GeneralMotorLoader;
import info.openrocket.core.file.motor.MotorLoader;
import info.openrocket.core.motor.Motor;
import info.openrocket.core.motor.ThrustCurveMotor;
import info.openrocket.core.rocketcomponent.*;
import info.openrocket.core.simulation.*;
import info.openrocket.core.simulation.exception.SimulationException;
import info.openrocket.core.simulation.extension.SimulationExtension;
import info.openrocket.core.startup.Application;
import info.openrocket.core.startup.OpenRocketCore;
import info.openrocket.core.util.Config;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

public class RocketSimulationExample {
    static final String ORK_FILE_PATH = "IREC 4.22.26.ork";

    public static void main(String[] args) throws SimulationException, RocketLoadException {
        // Initialize OpenRocket
        OpenRocketCore.initialize();

        // tell OpenRocket where to load thrust curve files from
        Application.getPreferences().setUserThrustCurveFiles(List.of(
                new File(".")   // load from CWD
        ));

        GeneralRocketLoader loader = new GeneralRocketLoader(new File(ORK_FILE_PATH));
        OpenRocketDocument document = loader.load();
        Simulation s = document.getSimulation(0);

        Airbrakes.SetTargetApogee(9000);
        s.simulate();
        System.out.println("Apogee: " + s.getSimulatedData().getMaxAltitude() + " meters");


    }
}