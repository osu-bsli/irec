package space.bsli;


public class AirbrakesConfig
{
    public enum AirbrakesMode {
        /* Closed-loop simulation with no hardware in the loop. */
        CLOSED_LOOP_SIM, /* The real-world airbrakes will move based on the deployment percentage the closed-loop simulation commands. */
        HITL_CONTROL, /* The airbrakes algorithm runs on the flight computer instead of on the PC. */
        FULL_HITL, /* Real flight-computer hardware over serial runs the full firmware. */
        FULL_SITL /* The full firmware runs in-process as a library (no hardware); deterministic. */
    }

    public static final float AIRBRAKE_CONTROL_INTERVAL_S = 0.1f; // 10 Hz, 100 ms period
    public static final float DEPLOYMENT_TIME_S = 1.28333333F;
    public static final float DEPLOYMENT_PCT_PER_SEC = 100F / DEPLOYMENT_TIME_S;
    public static final AirbrakesMode MODE = AirbrakesMode.CLOSED_LOOP_SIM;

    /* ---- Fake GPS injection (FULL_HITL only) ----
     * When enabled, the HITL harness derives GPS lat/lng/alt/speed/course from
     * the OpenRocket simulation and injects them into the log packets sent to
     * the flight computer, exercising the FC's GPS->ENU and navigation-filter
     * GPS update paths. When disabled, GPS fields are sent as NaN ("no fix")
     * and the FC ignores them. */
    public static final boolean FAKE_GPS_IN_HITL = true;
    /* GPS fix rate. Basic receivers report at 1 Hz, far below the 100 Hz sensor
     * rate. Between updates the previous fix is re-sent unchanged, which the FC's
     * change-detection treats as "no new GPS" (matching real behaviour). */
    public static final float GPS_UPDATE_INTERVAL_S = 1.0f; // 1 Hz
    /* Below this ground speed, no course is reported (sentinel), like a real
     * GPS that cannot determine heading while stationary. */
    public static final float GPS_MIN_SPEED_FOR_COURSE_MPS = 0.5f;
    /* Optional Gaussian noise (standard deviation). Set to 0 for deterministic
     * runs. Applied to the injected horizontal position and altitude. */
    public static final double GPS_HORIZONTAL_NOISE_M = 0.0;
    public static final double GPS_ALTITUDE_NOISE_M = 0.0;
    /* Number of satellites to report in the fake fix. */
    public static final int GPS_NUM_SATS = 12;
}