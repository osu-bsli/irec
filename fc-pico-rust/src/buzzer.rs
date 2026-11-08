use embassy_rp::pwm::{self, Pwm, SetDutyCycle};
use embassy_time::{Duration, Timer};

pub struct Buzzer<'a> {
    pwm: Pwm<'a>
}

impl<'a> Buzzer<'a> {
    pub fn init(pwm: Pwm<'a>) -> Self {
        Self {
            pwm
        }
    }

    pub async fn buzz(&mut self, freq: u32, duration: Duration) {
        // https://github.com/embassy-rs/embassy/blob/main/examples/rp235x/src/bin/pwm.rs
        // If we aim for a specific frequency, here is how we can calculate the top value.
        // The top value sets the period of the PWM cycle, so a counter goes from 0 to top and then wraps around to 0.
        // Every such wraparound is one PWM cycle. So here is how we get 25KHz:
        let desired_freq_hz = freq;
        let clock_freq_hz = embassy_rp::clocks::clk_sys_freq();
        let divider = 16u8;
        let period = (clock_freq_hz / (desired_freq_hz * divider as u32)) as u16 - 1;
        
        let mut pwm_config = pwm::Config::default();
        pwm_config.top = period;
        pwm_config.divider_x16 = (divider as u16) * 16;
        self.pwm.set_config(&pwm_config);

        self.pwm.set_duty_cycle_percent(50).unwrap();
        Timer::after(duration).await;
        self.pwm.set_duty_cycle_fully_off().unwrap();
    }
}