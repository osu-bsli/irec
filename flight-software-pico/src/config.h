#pragma once

#define CONFIG_AIRBRAKES_TARGET_APOGEE_METERS 9144
#define CONFIG_RUNTIME_INTERVAL_MS 10
#define CONFIG_ROCKET_MASS_KG 30

/* Check IREC Student Band Plan for allowed frequencies */
#define CONFIG_LORA_FREQUENCY_HZ 905 * 1000000


/* All CONFIG_TEST_<> options direct the software to enter a testing mode upon startup. */
/* When a CONFIG_TEST_<> option is enabled, the normal functionality of the flight software DOES NOT RUN. */

// #define CONFIG_TEST_GPS
#ifdef CONFIG_TEST_GPS
// #define CONFIG_TEST_GPS_PRINT_NMEA_TO_SERIAL
#endif

// #define CONFIG_TEST_SENSORS
// #define CONFIG_TEST_FULL_STACK_WITH_PRERECORDED_DATA
// #define CONFIG_TEST_AIRBRAKES_ALGO_PERFORMANCE
// #define CONFIG_TEST_AIRBRAKES_EXTEND_AND_RETRACT
// #define CONFIG_TEST_AIRBRAKES_HITL_CONTROL_ONLY
// #define CONFIG_TEST_AIRBRAKES_HITL_FULL
#define CONFIG_TEST_NO_PRE_OPERATIONAL_MODE

#ifdef CONFIG_TEST_AIRBRAKES_HITL_FULL
    #undef CONFIG_AIRBRAKES_TARGET_APOGEE_METERS
    #define CONFIG_AIRBRAKES_TARGET_APOGEE_METERS 8000
    #undef CONFIG_ROCKET_MASS_KG
    #define CONFIG_ROCKET_MASS_KG 31.740
#endif

/* CONFIG_TEST_ACTIVE is defined if any test configuration is enabled */
#if defined(CONFIG_TEST_GPS) ||                              \
    defined(CONFIG_TEST_GPS_PRINT_NMEA_TO_SERIAL) ||         \
    defined(CONFIG_TEST_SENSORS) ||                          \
    defined(CONFIG_TEST_FULL_STACK_WITH_PRERECORDED_DATA) || \
    defined(CONFIG_TEST_AIRBRAKES_ALGO_PERFORMANCE) || \
    defined(CONFIG_TEST_AIRBRAKES_EXTEND_AND_RETRACT) || \
    defined(CONFIG_TEST_AIRBRAKES_HITL_CONTROL_ONLY) || \
    defined(CONFIG_TEST_AIRBRAKES_HITL_FULL) || \
    defined(CONFIG_TEST_NO_PRE_OPERATIONAL_MODE)
#define CONFIG_TEST_ACTIVE
#endif
