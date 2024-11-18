#![feature(thread_sleep_until)]

use ground_control::mavlink_generated::bsli2025::{MavMessage, BSLI2025_COMPOSITE_DATA};

use std::collections::VecDeque;
use std::f64::consts::TAU;
use std::time::{Duration, Instant};
use std::{env, io, thread};

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
    gps_sat_count: f64,
    gps_lat: f64,
    gps_lon: f64,
    gps_ascent: f64,
    gps_ground_speed: f64,
    telemetrum_board_arm_status: f64,
    telemetrum_board_current: f64,
    telemetrum_board_voltage: f64,
    stratologger_board_arm_status: f64,
    stratologger_board_current: f64,
    stratologger_board_voltage: f64,
    camera_board_arm_status: f64,
    camera_board_current: f64,
    camera_board_voltage: f64,
    rail_voltage_3v: f64,
    rail_voltage_5v: f64,
    main_battery_voltage: f64,
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
    let args: Vec<_> = env::args().collect();

    if args.len() != 2 {
        eprintln!("Usage: mavlink-simulator <serial port name>");

        let ports = serialport::available_ports().expect("No serial ports found!");
        eprintln!("Available serial ports:");
        for p in ports {
            eprintln!("{}", p.port_name);
        }

        return Ok(());
    }

    let mut reader = csv::Reader::from_path("./simulator_data_flight_data_2.csv")?;
    let iter = reader.deserialize();

    let mut rows: VecDeque<Row> = VecDeque::new();

    for result in iter {
        let record: Row = result?;
        rows.push_back(record);
    }

    let mut port = serialport::new(args[1].clone(), 115_200)
        .timeout(Duration::from_millis(10))
        .open()
        .expect("Failed to open port");

    let t_start = Instant::now();

    loop {
        if let Some(row) = rows.pop_front() {
            let t_packet = Duration::from_secs_f64(row.time);
            let t_sleep_until = t_start + t_packet;
            thread::sleep_until(t_sleep_until);

            let data = MavMessage::BSLI2025_COMPOSITE(BSLI2025_COMPOSITE_DATA {
                time_boot_ms: scale_time(row.time),
                xacc: scale_acc(row.bmx_x_accel),
                yacc: scale_acc(row.bmx_y_accel),
                zacc: scale_acc(row.bmx_z_accel),
                xgyro: scale_gyro(row.bmx_x_gyro),
                ygyro: scale_gyro(row.bmx_y_gyro),
                zgyro: scale_gyro(row.bmx_z_gyro),
                xmag: scale_gyro(row.bmx_x_magn),
                ymag: scale_gyro(row.bmx_y_magn),
                zmag: scale_gyro(row.bmx_z_magn),
            });

            println!("Time: {}", row.time);

            mavlink_core::write_v2_msg(&mut port, mavlink_header(), &data).unwrap();
        }
    }
}

fn mavlink_header() -> mavlink_core::MavHeader {
    mavlink_core::MavHeader {
        system_id: 1,
        component_id: 1,
        sequence: 42,
    }
}
