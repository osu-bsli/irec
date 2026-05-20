import info.openrocket.core.plugin.Plugin;
import info.openrocket.core.simulation.extension.AbstractSimulationExtensionProvider;

@Plugin
public class AirbrakesProvider extends AbstractSimulationExtensionProvider {
    public AirbrakesProvider() {
        super(Airbrakes.class, "Active controls", "BSLI IREC Airbrakes");
        System.loadLibrary("cmake-build/Release/airbrakes");
    }
}