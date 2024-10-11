#![feature(thread_sleep_until)]

use std::collections::VecDeque;
use std::error::Error;
use std::f64::consts::{PI, TAU};
use std::sync::Arc;
use std::time::{Duration, Instant};
use std::{env, io, thread};

use mavlink::error::MessageReadError;

#[derive(Debug, serde::Deserialize)]
struct Row {
    time: f64,
    high_g_x: f64,
    high_g_y: f64,
    high_g_z: f64,
    bmx_x_magn: f64,
    bmx_y_magn: f64,
    bmx_z_magn: f64,
    bmx_x_gyro: f64,
    bmx_y_gyro: f64,
    bmx_z_gyro: f64,
    bmx_x_accel: f64,
    bmx_y_accel: f64,
    bmx_z_accel: f64,
    cpu_temp: f64,
    real_temp: f64,
    baro_height: f64,
    gps_height: f64,
    #[serde(rename = "gps_satCount")]
    gps_sat_count: u32,
    gps_lat: f64,
    gps_lon: f64,
    gps_ascent: f64,
    #[serde(rename = "gps_groundSpeed")]
    gps_ground_speed: f64,
    #[serde(rename = "telemetrum_board.arm_status")]
    telemetrum_board_arm_status: u64,
    #[serde(rename = "telemetrum_board.current")]
    telemetrum_board_current: f64,
    #[serde(rename = "telemetrum_board.voltage")]
    telemetrum_board_voltage: f64,
    #[serde(rename = "stratologger_board.arm_status")]
    stratologger_board_arm_status: u64,
    #[serde(rename = "stratologger_board.current")]
    stratologger_board_current: f64,
    #[serde(rename = "stratologger_board.voltage")]
    stratologger_board_voltage: f64,
    #[serde(rename = "camera_board.arm_status")]
    camera_board_arm_status: u64,
    #[serde(rename = "camera_board.current")]
    camera_board_current: f64,
    #[serde(rename = "camera_board.voltage")]
    camera_board_voltage: f64,
    v3_rail_voltage: f64,
    v5_rail_voltage: f64,
    #[serde(rename = "mainBatteryVoltage")]
    main_battery_voltage: f64,
    #[serde(rename = "mainBatteryTemperature")]
    main_battery_temperature: f64,
}

// degrees to degreesE7
fn scale_gps_lat_lon(val: f64) -> i32 {
    (val * 10000000.0) as i32
}

// m/s to cm/s
fn scale_gps_ground_speed(val: f64) -> i16 {
    (val * 100.0) as i16
}

// m to mm
fn scale_gps_altitude(val: f64) -> i32 {
    (val * 1000.0) as i32
}

// s to ms
fn scale_time(val: f64) -> u32 {
    (val * 1000.0) as u32
}

// m/s^2 to mG
fn scale_acc(val: f64) -> i16 {
    const G: f64 = 9.81;
    (val / G * 1000.0) as i16
}

// Revolutions per second to mrad/s
fn scale_gyro(val: f64) -> i16 {
    (val * TAU * 1000.0) as i16
}

// gauss to mgauss
fn scale_mag(val: f64) -> i16 {
    (val * 1000.0) as i16
}

// degC to cdegC
fn scale_temp(val: f64) -> i16 {
    (val * 100.0) as i16
}

fn main() -> Result<(), io::Error> {
    println!("Hello, world!");

    let args: Vec<_> = env::args().collect();

    let mut mavconn = mavlink::connect::<mavlink::common::MavMessage>(&args[1]).unwrap();

    let mut reader = csv::Reader::from_path("./simulator_data_flight_data_2.csv")?;
    let mut iter = reader.deserialize();

    let mut rows: VecDeque<Row> = VecDeque::new();

    for result in iter {
        let record: Row = result?;
        rows.push_back(record);
    }

    let vehicle = Arc::new(mavconn);
    vehicle
        .send(&mavlink::MavHeader::default(), &request_parameters())
        .unwrap();
    vehicle
        .send(&mavlink::MavHeader::default(), &request_stream())
        .unwrap();

    thread::spawn({
        let t_start = Instant::now();
        let vehicle = vehicle.clone();
        move || loop {
            let row = rows.pop_front();

            if let Some(row) = row {
                let t_packet = Duration::from_secs_f64(row.time);
                let t_sleep_until = t_start + t_packet;
                thread::sleep_until(t_sleep_until);

                let imu =
                    mavlink::common::MavMessage::SCALED_IMU(mavlink::common::SCALED_IMU_DATA {
                        time_boot_ms: scale_time(row.time),
                        xacc: scale_acc(row.bmx_x_accel),
                        yacc: scale_acc(row.bmx_y_accel),
                        zacc: scale_acc(row.bmx_z_accel),
                        xgyro: scale_gyro(row.bmx_x_gyro),
                        ygyro: scale_gyro(row.bmx_y_gyro),
                        zgyro: scale_gyro(row.bmx_z_gyro),
                        xmag: scale_mag(row.bmx_x_magn),
                        ymag: scale_mag(row.bmx_y_magn),
                        zmag: scale_mag(row.bmx_z_magn),
                    });

                let gps = mavlink::common::MavMessage::GLOBAL_POSITION_INT(
                    mavlink::common::GLOBAL_POSITION_INT_DATA {
                        time_boot_ms: scale_time(row.time),
                        lat: scale_gps_lat_lon(row.gps_lat),
                        lon: scale_gps_lat_lon(row.gps_lon),
                        alt: scale_gps_altitude(row.gps_height),
                        relative_alt: 0, // altitude above ground
                        vx: scale_gps_ground_speed(row.gps_ground_speed),
                        vy: 0,         // ground speed Y
                        vz: 0,         // ground speed Z
                        hdg: u16::MAX, // heading, set to UINT16_MAX if unknown
                    },
                );

                println!("Sending packets at T+{:?}", t_packet);
                //
                vehicle.send_default(&imu).unwrap();
                vehicle.send_default(&gps).unwrap();
            } else {
                println!("We are out of rows");
                thread::park();
            }
        }
    });

    loop {
        match vehicle.recv() {
            Ok((_header, msg)) => {
                println!("received: {msg:?}");
            }
            Err(MessageReadError::Io(e)) => {
                if e.kind() == std::io::ErrorKind::WouldBlock {
                    //no messages currently available to receive -- wait a while
                    println!("sleeping");
                    thread::sleep(Duration::from_secs(1));
                    continue;
                } else {
                    println!("recv error: {e:?}");
                    break Ok(());
                }
            }
            // messages that didn't get through due to parser errors are ignored
            _ => {
                eprintln!("Parser error")
            }
        }
    }
}

/// Create a message requesting the parameters list
pub fn request_parameters() -> mavlink::common::MavMessage {
    mavlink::common::MavMessage::PARAM_REQUEST_LIST(
        mavlink::common::PARAM_REQUEST_LIST_DATA {
            target_system: 0,
            target_component: 0,
        },
    )
}

/// Create a message enabling data streaming
pub fn request_stream() -> mavlink::common::MavMessage {
    mavlink::common::MavMessage::REQUEST_DATA_STREAM(
        mavlink::common::REQUEST_DATA_STREAM_DATA {
            target_system: 0,
            target_component: 0,
            req_stream_id: 0,
            req_message_rate: 10,
            start_stop: 1,
        },
    )
}
