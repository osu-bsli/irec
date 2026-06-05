package space.bsli.sim;

import space.bsli.AirbrakesConfig;
import space.bsli.LogPacketV3;

import info.openrocket.core.simulation.SimulationStatus;
import info.openrocket.core.util.WorldCoordinate;

import java.util.Random;

/**
 * Simulates a low-rate GPS receiver for the HITL/SITL harness. The most
 * recently emitted fix is derived from the OpenRocket simulation and cached;
 * it is re-sent unchanged between updates so the flight computer sees a
 * realistic GPS rate, with optional Gaussian position noise and a configurable
 * mid-flight dropout.
 *
 * Configuration ({@link #horizNoiseM}, {@link #altNoiseM}, {@link #dropoutAtS},
 * {@link #recoverAtS}) persists across a run and is restored between scenarios
 * by {@link #resetConfig()}; per-run fix state is cleared by {@link #start()}.
 */
public final class FakeGpsModel {
    private static final double R_EARTH_M = 6371000.0; // matches the FC's gps_compute_enu

    // ---- scenario configuration ----
    public double horizNoiseM = AirbrakesConfig.GPS_HORIZONTAL_NOISE_M;
    public double altNoiseM = AirbrakesConfig.GPS_ALTITUDE_NOISE_M;
    /* GPS reports no fix while dropoutAtS <= simTime < recoverAtS, modelling a
     * mid-flight outage that may (recoverAtS finite) or may not (infinite) end. */
    public double dropoutAtS = Double.POSITIVE_INFINITY;
    public double recoverAtS = Double.POSITIVE_INFINITY;

    // ---- most recently emitted fix ----
    private float latDeg = Float.NaN, lngDeg = Float.NaN, altM = Float.NaN;
    private float speedMps = 0f;
    private int course = LogPacketV3.GPS_COURSE_NONE;
    private int numSats = 0;

    // ---- internal state ----
    private float updateTimer = 0f;
    private boolean haveFix = false;
    private double prevLatDeg = 0, prevLngDeg = 0, prevTimeS = 0;

    public void resetConfig() {
        horizNoiseM = AirbrakesConfig.GPS_HORIZONTAL_NOISE_M;
        altNoiseM = AirbrakesConfig.GPS_ALTITUDE_NOISE_M;
        dropoutAtS = Double.POSITIVE_INFINITY;
        recoverAtS = Double.POSITIVE_INFINITY;
    }

    /** Clears the cached fix and timers at the start of a simulation run. */
    public void start() {
        latDeg = lngDeg = altM = Float.NaN;
        speedMps = 0f;
        course = LogPacketV3.GPS_COURSE_NONE;
        numSats = 0;
        updateTimer = 0f;
        haveFix = false;
        prevLatDeg = prevLngDeg = prevTimeS = 0;
    }

    public float latDeg()   { return latDeg; }
    public float lngDeg()   { return lngDeg; }
    public float altM()     { return altM; }
    public float speedMps() { return speedMps; }
    public int   course()   { return course; }
    public int   numSats()  { return numSats; }

    /**
     * Recomputes the cached fix from the simulation at most once per
     * GPS_UPDATE_INTERVAL_S. Speed/course are derived from the lat/lng delta
     * since the previous fix so they stay self-consistent with position
     * regardless of OpenRocket's axis conventions. Position noise is drawn from
     * the supplied {@link Random} for determinism.
     */
    public void update(SimulationStatus status, double dt, Random r) {
        // No GPS if fake GPS is disabled, or during a configured outage window.
        double now = status.getSimulationTime();
        boolean inOutage = now >= dropoutAtS && now < recoverAtS;
        if (!AirbrakesConfig.FAKE_GPS_IN_HITL || inOutage) {
            latDeg = Float.NaN;
            lngDeg = Float.NaN;
            altM = Float.NaN;
            speedMps = 0f;
            course = LogPacketV3.GPS_COURSE_NONE;
            numSats = 0;
            haveFix = false; // a re-acquired fix after dropout must re-init velocity baseline
            return;
        }

        updateTimer += dt;
        if (haveFix && updateTimer < AirbrakesConfig.GPS_UPDATE_INTERVAL_S) {
            return; // hold previous fix; FC sees "no new GPS"
        }
        updateTimer = 0f;

        WorldCoordinate wc = status.getRocketWorldPosition();
        double cleanLat = wc.getLatitudeDeg();
        double cleanLng = wc.getLongitudeDeg();
        double cleanAlt = wc.getAltitude();

        double tNow = status.getSimulationTime();

        /* Speed/course are derived from CLEAN positions and reported like a
         * receiver's Doppler velocity, which is independent of position
         * noise. (Differentiating the noisy reported position instead would
         * amplify a few metres of position noise into tens of m/s of bogus
         * velocity.) */
        if (haveFix) {
            double dtGps = tNow - prevTimeS;
            if (dtGps > 1e-3) {
                double latRad = Math.toRadians(cleanLat);
                double dNorth = Math.toRadians(cleanLat - prevLatDeg) * R_EARTH_M;
                double dEast = Math.toRadians(cleanLng - prevLngDeg) * R_EARTH_M * Math.cos(latRad);
                double speed = Math.hypot(dEast, dNorth) / dtGps;
                if (speed >= AirbrakesConfig.GPS_MIN_SPEED_FOR_COURSE_MPS) {
                    double courseDeg = Math.toDegrees(Math.atan2(dEast, dNorth));
                    if (courseDeg < 0) courseDeg += 360.0;
                    course = (int) Math.round(courseDeg * 100.0);
                } else {
                    course = LogPacketV3.GPS_COURSE_NONE;
                }
                speedMps = (float) speed;
            }
        } else {
            speedMps = 0f;
            course = LogPacketV3.GPS_COURSE_NONE;
        }

        /* Reported position carries the position noise. */
        double lat = cleanLat, lng = cleanLng, alt = cleanAlt;
        if (horizNoiseM > 0) {
            double latRad = Math.toRadians(cleanLat);
            lat += (r.nextGaussian() * horizNoiseM) / R_EARTH_M * (180.0 / Math.PI);
            lng += (r.nextGaussian() * horizNoiseM) / (R_EARTH_M * Math.cos(latRad)) * (180.0 / Math.PI);
        }
        if (altNoiseM > 0) {
            alt += r.nextGaussian() * altNoiseM;
        }

        latDeg = (float) lat;
        lngDeg = (float) lng;
        altM = (float) alt;
        numSats = AirbrakesConfig.GPS_NUM_SATS;

        prevLatDeg = cleanLat;
        prevLngDeg = cleanLng;
        prevTimeS = tNow;
        haveFix = true;
    }
}
