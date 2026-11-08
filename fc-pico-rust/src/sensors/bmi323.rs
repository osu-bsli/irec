/**
 * bmi323.rs
 *
 * ADXL375 accelerometer driver.
 * 
 * Rewritten in Rust for IREC 2027.
 *
 * @authors
 * - Dawn Goorskey
 * - Hana Winchester
 * - Brian Jia
 * - Gwendolyn Noria
 */


/* sensor configuration
 * - Accelerometer range: +/- 4 g       (max).
 * - Gyroscope range:     +/- 180 deg/s (min, we only care about off-axis rotation which is slow).
 * - Temperature range is fixed.
 * - Power mode: normal (datasheet pg. 22).
 * Ranges are +/-, see datasheet pg. 1.
 */

/* TODO:
 * - Check saturation flags for each axis of each sensor during sensor read.
 */

/* i2c constants */
const I2C_ADDRESS: u8 = 0x68; /* depends on how "SDO" pin is wired (datasheet pg. 217) */

/* register constants (datasheet pg. 62) */
const REGISTER_CHIP_ID: u8 = 0x00;
const REGISTER_ERR_REG: u8 = 0x01;
const REGISTER_STATUS: u8 = 0x02;
const REGISTER_ACC_DATA_X: u8 = 0x03;
const REGISTER_ACC_DATA_Y: u8 = 0x04;
const REGISTER_ACC_DATA_Z: u8 = 0x05;
const REGISTER_GYR_DATA_X: u8 = 0x06;
const REGISTER_GYR_DATA_Y: u8 = 0x07;
const REGISTER_GYR_DATA_Z: u8 = 0x08;
const REGISTER_TEMP_DATA: u8 = 0x09;
const REGISTER_SENSOR_TIME_0: u8 = 0x0A;
const REGISTER_SENSOR_TIME_1: u8 = 0x0B;
const REGISTER_SAT_FLAGS: u8 = 0x0C;

const REGISTER_INT_STATUS_INT1: u8 = 0x0D;
const REGISTER_INT_STATUS_INT1_TEMP_DRDY: u16 = 1u16 << 11;
const REGISTER_INT_STATUS_INT1_GYR_DRDY: u16 = 1u16 << 12;
const REGISTER_INT_STATUS_INT1_ACC_DRDY: u16 = 1u16 << 13;

const REGISTER_INT_STATUS_INT2: u8 = 0x0E;
const REGISTER_INT_STATUS_IBI: u8 = 0x0F;
const REGISTER_FEATURE_IO0: u8 = 0x10;
const REGISTER_FEATURE_IO1: u8 = 0x11;
const REGISTER_FEATURE_IO2: u8 = 0x12;
const REGISTER_FEATURE_IO3: u8 = 0x13;
const REGISTER_FEATURE_IO_STATUS: u8 = 0x14;
const REGISTER_FIFO_FILL_LEVEL: u8 = 0x15;
const REGISTER_FIFO_DATA: u8 = 0x16;
const REGISTER_ACC_CONF: u8 = 0x20;
const REGISTER_GYR_CONF: u8 = 0x21;
const REGISTER_ALT_ACC_CONF: u8 = 0x28;
const REGISTER_ALT_GYR_CONF: u8 = 0x29;
const REGISTER_ALT_CONF: u8 = 0x2A;
/* (datasheet pg. 63) */
const REGISTER_ALT_STATUS: u8 = 0x2B;
const REGISTER_FIFO_WATERMARK: u8 = 0x35;
const REGISTER_FIFO_CONF: u8 = 0x36;
const REGISTER_FIFO_CTRL: u8 = 0x37;
const REGISTER_IO_INT_CTRL: u8 = 0x38;
const REGISTER_INT_CONF: u8 = 0x39;
const REGISTER_INT_MAP1: u8 = 0x3A;
const REGISTER_INT_MAP2: u8 = 0x3B;
const REGISTER_FEATURE_CTRL: u8 = 0x40;
const REGISTER_FEATURE_DATA_ADDR: u8 = 0x41;
const REGISTER_FEATURE_DATA_TX: u8 = 0x42;
const REGISTER_FEATURE_DATA_STATUS: u8 = 0x43;
const REGISTER_FEATURE_ENGINE_STATUS: u8 = 0x45;
const REGISTER_FEATURE_EVENT_EXT: u8 = 0x47;
const REGISTER_IO_PDN_CTRL: u8 = 0x4F;
const REGISTER_IO_SPI_IF: u8 = 0x50;
const REGISTER_IO_PAD_STRENGTH: u8 = 0x51;
const REGISTER_IO_I2C_IF: u8 = 0x52;
const REGISTER_IO_ODR_DEVIATION: u8 = 0x53;
const REGISTER_ACC_DP_OFF_X: u8 = 0x60;
const REGISTER_ACC_DP_DGAIN_X: u8 = 0x61;
const REGISTER_ACC_DP_OFF_Y: u8 = 0x62;
const REGISTER_ACC_DP_DGAIN_Y: u8 = 0x63;
const REGISTER_ACC_DP_OFF_Z: u8 = 0x64;
const REGISTER_ACC_DP_DGAIN_Z: u8 = 0x65;
const REGISTER_GYR_DP_OFF_X: u8 = 0x66;
const REGISTER_GYR_DP_DGAIN_X: u8 = 0x67;
const REGISTER_GYR_DP_OFF_Y: u8 = 0x68;
const REGISTER_GYR_DP_DGAIN_Y: u8 = 0x69;
const REGISTER_GYR_DP_OFF_Z: u8 = 0x6A;
/* (datasheet pg. 64) */
const REGISTER_GYR_DP_DGAIN_Z: u8 = 0x6B;
const REGISTER_I3C_TC_SYNC_TPH: u8 = 0x70;
const REGISTER_I3C_TC_SYNC_TU: u8 = 0x71;
const REGISTER_I3C_TC_SYNC_ODR: u8 = 0x72;
const REGISTER_CMD: u8 = 0x7E;
const REGISTER_CFG_RES: u8 = 0x7F;

const ACC_INVALID: u16 = 0x8000;  /* invalid value for acceleration data (datasheet pg. 22) */
const GYR_INVALID: u16 = 0x8000;  /* invalid value for gyroscope data (datasheet pg. 24) */
const TEMP_INVALID: u16 = 0x8000; /* invalid value for temperature data (datasheet pg. 25) */

pub enum Bmi323Error {
    ChipIdReadFailure,
    ChipIdMismatch,
    ErrorRegisterReadFailure,
    ErrorRegisterFailure,
    StatusReadFailure,
    StatusFailure,
    ConfigurationFailure,
    AccConfReadFailure,
    AccConfWriteFailure,
    GyroConfReadFailure,
    GyroConfWriteFailure,
    IntMapWriteFailure,
    DataxReadFailure,
}

use core::fmt::Display;

use bitfields::bitfield;
use embassy_rp::{
    i2c::{self, I2c}, mode::{Async, Mode},
};


#[bitfield(u16, order = msb)]
struct AccConfReg {
    #[bits(1)] _unused0: u8, 
    #[bits(3)] pub acc_mode: u8,
    #[bits(1)] _unused1: u8,
    #[bits(3)] pub acc_avg_num: u8,
    #[bits(1)] pub acc_bw: u8,
    #[bits(3)] pub acc_range: u8,
    #[bits(4)] pub acc_odr: u8,
}

#[bitfield(u16, order = msb)]
struct GyrConfReg {
    #[bits(1)] _unused0: u8, 
    #[bits(3)] pub gyr_mode: u8,
    #[bits(1)] _unused1: u8,
    #[bits(3)] pub gyr_avg_num: u8,
    #[bits(1)] pub gyr_bw: u8,
    #[bits(3)] pub gyr_range: u8,
    #[bits(4)] pub gyr_odr: u8,
}

pub struct Bmi323Data {
    /* datasheet pg. 22 */

    /* Acceleration - in Gs */
    pub accel_x_g: f32,
    pub accel_y_g: f32,
    pub accel_z_g: f32,
    // TODO: accel_x_saturated: f32,
    // TODO: accel_y_saturated: f32,
    // TODO: accel_z_saturated: f32,

    /* Gyroscope - in degrees/second */
    pub gyro_x_deg1s: f32,
    pub gyro_y_deg1s: f32,
    pub gyro_z_deg1s: f32,
    // TODO: gyro_x_saturated: f32,
    // TODO: gyro_y_saturated: f32,
    // TODO: gyro_z_saturated: f32,

    /* Temperature - in Celcius */
    pub temp: f32,

    // TODO: time: f32, /* sensor keeps timestamps for measurements (datasheet pg. 25) */
    pub embassy_timestamp: embassy_time::Instant, /* in kernel ticks */
}

pub struct Bmi323<'a> {
    i2c: I2c<'a, Async>,
}

impl<'a> Bmi323<'a> {
    // pub async fn init(mut i2c: I2c<'_, Async>) -> Option<Bmi323<'_>> {
    //     let reg_addr = [Self::REG_ADDR_ID];
    //     if i2c.write(Self::I2C_ADDR, &reg_addr).await.is_err() {
    //         return None;
    //     }
        
    //     let mut buf = [0u8; 4]; // 2 dummy bytes, 
    //     if i2c.read(Self::I2C_ADDR, &mut buf).await.is_err() {
    //         return None;
    //     }
    //     if buf[2] != Self::CHIP_ID {
    //         return None;
    //     }

    //     Some(Bmi323 { i2c })
    // }

    /// Read BMI323 register (16 bits).
    /// Table 53: I2C Single-Word Read Operation (p. 204)
    async fn read_reg(i2c: &mut I2c<'_, Async>, i2c_addr: u8, reg_addr: u8) -> Result<u16, i2c::Error> {
        let reg_addr = [reg_addr];
        i2c.write(i2c_addr, &reg_addr).await?;
        
        let mut buf = [0u8; 4]; // 2 dummy bytes, 
        i2c.read(i2c_addr, &mut buf).await?; 

        Ok((buf[3] as u16) << 8 | (buf[2] as u16))
    }

    /// Write BMI323 register (16 bits).
    /// Table 51: I2C Single-Word Write Operation (p. 203)
    async fn write_reg(i2c: &mut I2c<'_, Async>, i2c_addr: u8, reg_addr: u8, val: u16) -> Result<(), i2c::Error> {
        let reg_addr = [reg_addr, val as u8, (val >> 8) as u8];
        i2c.write(i2c_addr, &reg_addr).await?;
        Ok(())
    }

    /// Read multiple BMI323 registers
    /// Table 55: I2C Multi-Word Write Operation (p. 205)
    /// First entry of `out` is dummy.
    async fn read_regs(i2c: &mut I2c<'_, Async>, i2c_addr: u8, reg_addr: u8, out: &mut [u16]) -> Result<(), i2c::Error> {
        let reg_addr = [reg_addr];
        i2c.write(i2c_addr, &reg_addr).await?;
        
        let mut out: &mut [u8] = bytemuck::cast_slice_mut(out);
        i2c.read(i2c_addr, &mut out).await?;

        Ok(())
    }

    pub async fn init(mut i2c: I2c<'a, Async>) -> Result<Bmi323<'a>, Bmi323Error> {
        /* when writing to registers with reserved bits, must read, update, then write (datasheet pg. 62) */
        /* write calibration values to registers (datasheet pg. 55) */

        /*
        * THE FIRST 2 BYTES OF ANY I2C REGISTER READ FROM THE BMI323 ARE 0 DUMMY BYTES.
        */

        /* check chip id (datasheet pg. 66) */
        let chip_id_res = Self::read_reg(&mut i2c, I2C_ADDRESS, REGISTER_CHIP_ID).await;
        if let Ok(chip_id) = chip_id_res {
            if (chip_id & 0xFF) != 0x43 {
                return Err(Bmi323Error::ChipIdMismatch);
            }
        } else {
            return Err(Bmi323Error::ChipIdReadFailure);
        }

        /* check ERR_REG before enabling sensors (datasheet pg. 67) */
        let err_value_res = Self::read_reg(&mut i2c, I2C_ADDRESS, REGISTER_ERR_REG).await;
        if let Ok(err_value) = err_value_res {
            // if the received value for the error is not 0 then something is wrong
            if err_value != 0x0 {
                return Err(Bmi323Error::ErrorRegisterFailure);
            }
        } else {
            return Err(Bmi323Error::ErrorRegisterReadFailure);
        }

        /* check STATUS */
        let status_value_res = Self::read_reg(&mut i2c, I2C_ADDRESS, REGISTER_STATUS).await;
        if let Err(_) = status_value_res {
            return Err(Bmi323Error::StatusReadFailure);
        }

        // if (status_value[1] != 0)
        // {
        //     bmi323->is_in_degraded_state = true;
        //     return BMI323_STATUS_FAILURE;
        // }

        // The BMI323 doesn't reset when the STM32 does, so the powerup flag may not always be set
        //    if ((status_value[1] & 1) == 0) BKPT_ERROR;

        // Interrupt configuration doesn't actually matter in our case
        let int_conf_val = 0x0001;
        let int_conf_write_res = Self::write_reg(&mut i2c, I2C_ADDRESS, REGISTER_INT_CONF, int_conf_val).await;
        if let Err(_) = int_conf_write_res
        {
            return Err(Bmi323Error::ConfigurationFailure);
        }

        /* =================================================================================== */
        /* configure ACC_CONF register (acc_mode, acc_range, acc_bw, acc_avg_num, and acc_odr) */
        /* =================================================================================== */
        
        /* ACC_CONF.acc_mode =   0b111   for normal power mode (datasheet pg. 22)
        * ACC_CONF.acc_avg_num = 0b000   for no averaging
        * ACC_CONF.acc_bw =      0b1     for most accurate filtering (?)
        * ACC_CONF.acc_range =   0b001   for +/- 4 g range (datasheet pg. 92)
        * ACC_CONF.acc_odr =     0b1000  for 100 Hz sample rate
        * format: [x:1][acc_mode:3][x:1][acc_avg_num:3]_[acc_bw:1][acc_range:3][acc_odr:4]
        * binary: [x]  [111]       [x]  [000]           [1]       [001]        [1000]
        * hex:    0x70                                  0x98
        */

        let acc_conf_val = {
            let mut reg = AccConfReg::new();
            reg.set_acc_mode(0b111);
            reg.set_acc_avg_num(0b000);
            reg.set_acc_bw(0b1);
            reg.set_acc_range(0b001);
            reg.set_acc_odr(0b1000);
            reg.into_bits()
        };

        let acc_conf_res = Self::write_reg(&mut i2c,
            I2C_ADDRESS,
            REGISTER_ACC_CONF,
            acc_conf_val).await;

        if let Err(_) = acc_conf_res {
            return Err(Bmi323Error::AccConfWriteFailure);
        }

        /* =================================================================================== */
        /* configure GYR_CONF register (gyr_mode, gyr_range, gyr_bw, gyr_avg_num, and gyr_odr) */
        /* =================================================================================== */

        /* 
        * GYR_CONF.gyr_mode =    0b111  for normal power mode (datasheet pg. 22)
        * GYR_CONF.gyr_avg_num = 0b000  for no averaging
        * GYR_CONF.gyr_bw =      0b1    for most accurate filtering (?)
        * GYR_CONF.gyr_range =   0b100  for +/- 2000 deg/s range (datasheet pg. 94)
        * GYR_CONF.gyr_odr =     0b1000 for 100 Hz sample rate
        * format: [x:1][gyr_mode:3][x:1][gyr_avg_num:3]_[gyr_bw:1][gyr_range:3][gyr_odr:4]
        * binary: [x]  [111]       [x]  [000]           [1]       [100]        [1000]
        * hex:    0x70                                  0xC8
        */

        let gyr_conf_read_res = Self::read_reg(&mut i2c, I2C_ADDRESS, REGISTER_GYR_CONF).await;
        if let Ok(gyr_conf_val) = gyr_conf_read_res {
            let mut reg = GyrConfReg::from_bits(gyr_conf_val);
            reg.set_gyr_mode(0b111);
            reg.set_gyr_avg_num(0b000);
            reg.set_gyr_bw(0b1);
            reg.set_gyr_range(0b100);
            reg.set_gyr_odr(0b1000);

            let gyr_conf_write_res = Self::write_reg(&mut i2c,
                I2C_ADDRESS,
                REGISTER_GYR_CONF,
                reg.into_bits()
            ).await;

            if let Err(_) = gyr_conf_write_res {
                return Err(Bmi323Error::GyroConfWriteFailure);
            }
        } else {
            return Err(Bmi323Error::GyroConfReadFailure);
        }

        // TODO: Double check these
        let int_map2_val = 0x0540;
        let int_map2_write_res = Self::write_reg(&mut i2c,
            I2C_ADDRESS,
            REGISTER_INT_MAP2,
            int_map2_val,
        ).await;

        if let Err(_) = int_map2_write_res {
            return Err(Bmi323Error::IntMapWriteFailure);
        }

        Ok(Self {
            i2c
        })
    }

    pub async fn process(&mut self) -> Result<Bmi323Data, Bmi323Error> {
        // TODO: Check if we even need to bother waiting for the data ready flag.
        //       The sensor might be ready before we read it for the first time.
        //       Plus, we can configure the sensor to give new data faster than we could
        //       ever possibly read it. From a signal processing standpoint, we can also
        //       enable the sensor's internal filtering to reduce aliasing.
        //
        // TODO: Also think about using actual GPIO interrupts to handle data ready.

        let mut sensor_data = [0u16; 8]; // dummy, 3-axis accel, 3-axis gyro, temp
        let read_res = Self::read_regs(
            &mut self.i2c,
            I2C_ADDRESS,
            REGISTER_ACC_DATA_X,
            &mut sensor_data,
        ).await;

        if let Ok(()) = read_res {
            return Ok(Bmi323Data {
                // multiplier to convert an i16 to the sensor range
                accel_x_g: (sensor_data[1] as i16 as f32) / 8.19 / 1000.0, // +/-4g, 8.19 LSB/mg
                accel_y_g: (sensor_data[2] as i16 as f32) / 8.19 / 1000.0,
                accel_z_g: (sensor_data[3] as i16 as f32) / 8.19 / 1000.0,

                gyro_x_deg1s: (sensor_data[4] as i16 as f32) / 16.4, // +/-2000deg, 16.4 LSB/deg/s
                gyro_y_deg1s: (sensor_data[5] as i16 as f32) / 16.4,
                gyro_z_deg1s: (sensor_data[6] as i16 as f32) / 16.4,

                temp: (sensor_data[7] as f32) / 512.0 + 23.0,

                embassy_timestamp: embassy_time::Instant::now(),
            });
        } else {
            return Err(Bmi323Error::DataxReadFailure);
        }
    }
}
