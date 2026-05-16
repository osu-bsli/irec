
import info.openrocket.core.simulation.SimulationConditions;
import info.openrocket.core.simulation.SimulationStatus;
import info.openrocket.core.simulation.exception.SimulationException;
import info.openrocket.core.simulation.extension.AbstractSimulationExtension;
import info.openrocket.core.simulation.listeners.AbstractSimulationListener;
import info.openrocket.core.util.Coordinate;

public class Airbrakes extends AbstractSimulationExtension {

    public void initialize(SimulationConditions conditions) throws SimulationException {
        conditions.getSimulationListenerList().add(new AirbrakesListener());
    }

    @Override
    public String getName() {
        return "BSLI IREC Airbrakes";
    }

    @Override
    public String getDescription() {
        return "Simple extension example for air-start";
    }

    private class AirbrakesListener extends AbstractSimulationListener {

        @Override
        public void startSimulation(SimulationStatus status) throws SimulationException {
            status.setRocketPosition(new Coordinate(0, 0, 1000.0));
        }
    }
}