idf_component_register(
SRCS 
    sensors/adxl375.cpp
    sensors/bm1422.cpp
    sensors/bmi323.cpp
    sensors/ms5607.cpp

    airbrakes/AltimeterFilter.cpp
    airbrakes/airbrakes.cpp

    common.cpp
    main.cpp
    
    arduino-LoRa/LoRa.cpp
    SCServo/SCS.cpp
    SCServo/SCSCL.cpp
    SCServo/SCSerial.cpp
    SCServo/SMS_STS.cpp
    
INCLUDE_DIRS
    .
    SCServo
    arduino-LoRa
)
