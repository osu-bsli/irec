import info.openrocket.core.plugin.Plugin;
import info.openrocket.core.simulation.extension.AbstractSimulationExtensionProvider;

@Plugin
public class AirbrakesExtensionProvider extends AbstractSimulationExtensionProvider {
    public AirbrakesExtensionProvider() {
        super(AirbrakesExtension.class, "Active controls", "BSLI IREC Airbrakes");
        System.loadLibrary("cmake-build/Release/airbrakes");
    }
}