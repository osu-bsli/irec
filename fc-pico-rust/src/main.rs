//! This example test the RP Pico on board LED.
//!
//! It does not work with the RP Pico W board. See `blinky_wifi.rs`.

#![no_std]
#![no_main]

pub mod bmi323;
pub mod buzzer;

use defmt::*;
use defmt_rtt as _;
use embassy_executor::Spawner;
use embassy_rp::{bind_interrupts, gpio, i2c::{self, I2c}, pac, peripherals, pwm::{self, Pwm, SetDutyCycle}, time::Hertz};
use embassy_time::{Duration, Timer};
use gpio::{Level, Output};
use panic_probe as _;

use crate::bmi323::Bmi323;
use crate::buzzer::Buzzer;

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

    let buzzer_pwm = Pwm::new_output_a(p.PWM_SLICE5, p.PIN_26, pwm::Config::default());
    let mut buzzer = Buzzer::init(buzzer_pwm);

    // If BMI323 successfully initialized, blink
    if bmi323.is_some() {
        // Play happy da-ding buzzer sound if BMI323 successfully initializes
        buzzer.buzz(880, Duration::from_millis(100)).await;
        buzzer.buzz(880*2, Duration::from_millis(300)).await;

        loop {
            info!("led on!");
            led.set_high();
            Timer::after_millis(500).await;

            info!("led off!");
            led.set_low();
            Timer::after_millis(500).await;
        }
    } else {
        // Play "wrong" buzzer sound (ER-ERHHHHH) if BMI323 fails to initialize
        buzzer.buzz(1000, Duration::from_millis(500)).await;
        buzzer.buzz(707, Duration::from_millis(500)).await;
    }
}