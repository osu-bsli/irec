#![no_std]

use embassy_time::Instant;
use embassy_sync::blocking_mutex::raw::CriticalSectionRawMutex;
use embassy_sync::{blocking_mutex, mutex};

pub struct Data {
    processed: Processed,
    unprocessed: Unprocessed,
}

pub struct Processed {
    px1125r: [PX1125R_Packet; 2],
    bmi323: [BMI323_Packet; 5],
    adxl375: [ADXL375_Packet; 5],
    ms5607: [MS5607_Packet; 5],
    bm1422: [BM1422_Packet; 5],
}

pub struct Unprocessed {
    px1125r: [PX1125R_NMEA_Packet; 3],
    bmi323: [BMI323_Packet; 10],
    adxl375: [ADXL375_Packet; 10],
    ms5607: [MS5607_Packet; 10],
    bm1422: [BM1422_Packet; 10],
}

pub struct PX1125R_NMEA_Packet {
    message: [u8; 256],
}

pub struct PX1125R_Packet {
    latitude: f32,
    longitude: f32,
    altitude: f32,
    vel_east: f32,
    vel_north: f32,
    vel_up: f32,
    time_recieved: Instant,
}

pub struct BMI323_Packet {
    acc_X: f32,
    acc_Y: f32,
    acc_Z: f32,
    gyro_X: f32,
    gyro_Y: f32,
    gyro_Z: f32,
    time_recieved: Instant,
}

pub struct ADXL375_Packet {
    acc_X: f32,
    acc_Y: f32,
    acc_Z: f32,
    time_recieved: Instant,
}

pub struct MS5607_Packet {
    pressure: f32,
    time_recieved: Instant,
}

pub struct BM1422_Packet {
    mag_X: f32,
    mag_Y: f32,
    mag_Z: f32,
    time_recieved: Instant,
}