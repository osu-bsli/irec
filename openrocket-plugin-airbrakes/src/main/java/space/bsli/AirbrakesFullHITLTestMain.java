package space.bsli;

import space.bsli.AirbrakesExtension;
import space.bsli.AirbrakesConfig.AirbrakesMode;

import info.openrocket.core.simulation.exception.SimulationException;

public class AirbrakesFullHITLTestMain {
    public static void main(String[] args) throws SimulationException {
        AirbrakesTestLib.initialize();
        var s = AirbrakesTestLib.getSimulation();
        AirbrakesExtension.mode = AirbrakesMode.FULL_HITL;
        s.getOptions().setLaunchRodAngle(Math.toRadians(0));
        s.simulate();
        System.out.println("Apogee (m): " + s.getSimulatedData().getMaxAltitude());
    }
}
