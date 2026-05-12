#pragma once

#define CONFIG_AIRBRAKES_TARGET_APOGEE_METERS 9144 



/* All CONFIG_TEST_<> options direct the software to enter a testing mode upon startup. */
/* When a CONFIG_TEST_<> option is enabled, the normal functionality of the flight software DOES NOT RUN. */
// #define CONFIG_TEST_GPS
#ifdef CONFIG_TEST_GPS
    // #define CONFIG_TEST_GPS_PRINT_NMEA_TO_SERIAL
#endif

// #define CONFIG_TEST_SENSORS
// #define CONFIG_TEST_AIRBRAKES_WITH_PRERECORDED_DATA
#define CONFIG_TEST_AIRBRAKES_ALGO_PERFORMANCE
