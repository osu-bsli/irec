//! This example test the RP Pico on board LED.
//!
//! It does not work with the RP Pico W board. See `blinky_wifi.rs`.

#![no_std]
#![no_main]

pub mod bmi323;

use defmt::*;
use defmt_rtt as _;
use embassy_executor::Spawner;
use embassy_rp::{bind_interrupts, gpio, i2c::{self, I2c}, peripherals, time::Hertz};
use embassy_time::{Duration, Timer};
use gpio::{Level, Output};
use panic_probe as _;

use crate::bmi323::Bmi323;

// Program metadata for `picotool info`.
// This isn't needed, but it's recommended to have these minimal entries.
#[unsafe(link_section = ".bi_entries")]
#[used]
pub static PICOTOOL_ENTRIES: [embassy_rp::binary_info::EntryAddr; 4] = [
    embassy_rp::binary_info::rp_program_name!(c"Blinky Example"),
    embassy_rp::binary_info::rp_program_description!(
        c"This example tests the RP Pico on board LED, connected to gpio 25"
    ),
    embassy_rp::binary_info::rp_cargo_version!(),
    embassy_rp::binary_info::rp_program_build_attribute!(),
];

bind_interrupts!(struct Irqs {
    I2C0_IRQ => i2c::InterruptHandler<peripherals::I2C0>;
});

#[embassy_executor::main(executor = "embassy_rp::executor::Executor", entry = "cortex_m_rt::entry")]
async fn main(_spawner: Spawner) {
    let p = embassy_rp::init(Default::default());
    let mut led = Output::new(p.PIN_25, Level::Low);

    let mut i2c_config = i2c::Config::default();
    i2c_config.frequency  = Hertz(100000);
    i2c_config.scl_pullup = true;
    i2c_config.sda_pullup = true;
    i2c_config.timeout = Duration::from_secs(1);

    let mut i2c = I2c::new(p.I2C0, p.PIN_21, p.PIN_20, Irqs, i2c_config);
    let mut bmi323 = Bmi323::init(i2c).await;

    if bmi323.is_some() {
        loop {
            info!("led on!");
            led.set_high();
            Timer::after_millis(500).await;

            info!("led off!");
            led.set_low();
            Timer::after_millis(500).await;
        }
    }
}