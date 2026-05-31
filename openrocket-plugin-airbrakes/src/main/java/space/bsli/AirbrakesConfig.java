package space.bsli;


public class AirbrakesConfig
{
    public enum AirbrakesMode {
        /* Closed-loop simulation with no hardware in the loop. */
        CLOSED_LOOP_SIM, /* The real-world airbrakes will move based on the deployment percentage the closed-loop simulation commands. */
        HITL_CONTROL, /* The airbrakes algorithm runs on the flight computer instead of on the PC. */
        FULL_HITL
    }

    public static final float AIRBRAKE_CONTROL_INTERVAL_S = 0.1f; // 10 Hz, 100 ms period
    public static final float DEPLOYMENT_TIME_S = 1.28333333F;
    public static final float DEPLOYMENT_PCT_PER_SEC = 100F / DEPLOYMENT_TIME_S;
    public static final AirbrakesMode MODE = AirbrakesMode.CLOSED_LOOP_SIM;
}