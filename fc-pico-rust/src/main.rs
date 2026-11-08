#![no_std]
#![no_main]

pub mod sensors;
pub mod buzzer;

use defmt::*;
use defmt_rtt as _;
use embassy_executor::Spawner;
use embassy_rp::{bind_interrupts, gpio, i2c::{self, I2c}, pac, peripherals, pwm::{self, Pwm, SetDutyCycle}, time::Hertz};
use embassy_time::{Duration, Timer};
use gpio::{Level, Output};
use panic_probe as _;

use crate::sensors::*;
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
    let mut bmi323_res = Bmi323::init(i2c).await;

    let buzzer_pwm = Pwm::new_output_a(p.PWM_SLICE5, p.PIN_26, pwm::Config::default());
    let mut buzzer = Buzzer::init(buzzer_pwm);

    // If BMI323 successfully initialized, blink
    if let Ok(mut bmi323) = bmi323_res {
        // Play happy da-ding buzzer sound if BMI323 successfully initializes
        buzzer.buzz(880, Duration::from_millis(100)).await;
        buzzer.buzz(880*2, Duration::from_millis(300)).await;

        // loop {
        //     info!("led on!");
        //     led.set_high();
        //     Timer::after_millis(500).await;

        //     info!("led off!");
        //     led.set_low();
        //     Timer::after_millis(500).await;
        // }

        // Beep at rate according to how tilted it is
        // loop {
        //     let start_time = embassy_time::Instant::now();
        //     loop {
        //         let process_res = bmi323.process().await;
        //         if let Ok(bmi323_data) = process_res {
        //             let abs_z_g = bmi323_data.accel_z_g.abs();
        //             let delay_proportion = (abs_z_g / 1.0).clamp(0.0, 1.0);
        //             let delay_ms = (10.0 + delay_proportion * 900.0) as u64;
                    
        //             if start_time.elapsed().as_millis() > delay_ms {
        //                 break;
        //             }
                    
        //             Timer::after_millis(10).await;
        //             println!("{}", abs_z_g);
        //         } 
        //     }
        //     buzzer.buzz(1000, Duration::from_millis(25)).await;
        // }

        // Beep according to rotation speed
        loop {
            let start_time = embassy_time::Instant::now();
            loop {
                let process_res = bmi323.process().await;
                if let Ok(bmi323_data) = process_res {
                    let gyro_rate = libm::sqrtf(
                        libm::powf(bmi323_data.gyro_x_deg1s, 2.) + 
                        libm::powf(bmi323_data.gyro_y_deg1s, 2.) + 
                        libm::powf(bmi323_data.gyro_z_deg1s, 2.));
                    let delay_proportion = (1.0 - gyro_rate / 1000.0).clamp(0.0, 1.0);
                    let delay_ms = (10.0 + delay_proportion * 900.0) as u64;
                    
                    if start_time.elapsed().as_millis() > delay_ms {
                        break;
                    }
                    
                    Timer::after_millis(10).await;
                } 
            }
            buzzer.buzz(1000, Duration::from_millis(25)).await;
        }
    } else {
        // Play "wrong" buzzer sound (ER-ERHHHHH) if BMI323 fails to initialize
        buzzer.buzz(1000, Duration::from_millis(500)).await;
        buzzer.buzz(707, Duration::from_millis(500)).await;
    }
}