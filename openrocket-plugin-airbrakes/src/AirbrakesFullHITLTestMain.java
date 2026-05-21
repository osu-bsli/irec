import info.openrocket.core.simulation.exception.SimulationException;

public class AirbrakesFullHITLTestMain {
    public static void main(String[] args) throws SimulationException {
        AirbrakesTestLib.initialize();
        var s = AirbrakesTestLib.getSimulation();
        AirbrakesExtension.mode = AirbrakesExtension.AirbrakesMode.FULL_HITL;
        s.getOptions().setLaunchRodAngle(Math.toRadians(0));
        s.simulate();
        System.out.println("Apogee (m): " + s.getSimulatedData().getMaxAltitude());
    }
}
