#![feature(thread_sleep_until)]

use ground_control::mavlink_generated;
use ground_control::mavlink_generated::bsli2025::{MavMessage, BSLI2025_COMPOSITE_DATA};
use mavlink_core::write_v2_msg;
use serde::Serialize;

use std::collections::VecDeque;
use std::f64::consts::TAU;
use std::time::{Duration, Instant};
use std::{env, io, thread};


fn main() -> Result<(), io::Error> {
    let args: Vec<_> = env::args().collect();

    if args.len() != 2 {
        eprintln!("Usage: mavlink-receive-test <serial port name>");

        let ports = serialport::available_ports().expect("No serial ports found!");
        eprintln!("Available serial ports:");
        for p in ports {
            eprintln!("{}", p.port_name);
        }

        return Ok(());
    }

    let mut port = serialport::new(args[1].clone(), 115_200)
        .timeout(Duration::from_millis(10))
        .open()
        .expect("Failed to open port");

    let mut buf = [0u8; 1024];
    port.set_timeout(Duration::from_secs(60)).unwrap();
    loop {
        if let Ok(data_size) = port.read(buf.as_mut_slice()) {
            println!("Received {data_size} bytes.");
        } 
    }
}
