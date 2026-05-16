
import info.openrocket.core.simulation.SimulationConditions;
import info.openrocket.core.simulation.SimulationStatus;
import info.openrocket.core.simulation.exception.SimulationException;
import info.openrocket.core.simulation.extension.AbstractSimulationExtension;
import info.openrocket.core.simulation.listeners.AbstractSimulationListener;
import info.openrocket.core.util.Coordinate;

/**
 * Simulation extension that launches a rocket from a specific altitude.
 */
public class AirStartExample extends AbstractSimulationExtension {

    public void initialize(SimulationConditions conditions) throws SimulationException {
        conditions.getSimulationListenerList().add(new AirStartListener());
    }

    @Override
    public String getName() {
        return "Air-Start Example";
    }

    @Override
    public String getDescription() {
        return "Simple extension example for air-start";
    }

    private class AirStartListener extends AbstractSimulationListener {

        @Override
        public void startSimulation(SimulationStatus status) throws SimulationException {
            status.setRocketPosition(new Coordinate(0, 0, 1000.0));
        }
    }
}