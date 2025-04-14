use std::{
    fs::File,
    io::{BufReader, Read},
    mem::MaybeUninit,
    num,
    path::PathBuf,
};

use egui::RichText;
use ground_control::{
    FusionAhrs, FusionAhrsGetGravity, FusionAhrsGetLinearAcceleration, FusionAhrsGetQuaternion,
    FusionAhrsInitialise, FusionAhrsSetSettings, FusionAhrsSettings, FusionAhrsUpdate,
    FusionAhrsUpdateNoMagnetometer, FusionConvention_FusionConventionNwu, FusionOffset,
    FusionOffsetInitialise, FusionOffsetUpdate, FusionQuaternionToEuler, FusionVector,
    FusionVectorMagnitude,
};
use num_traits::{ops::bytes, Float, Pow};

use crate::{
    telemetry::{LogPacketV1, TelemetryDecoder},
    G_to_mps2, GroundControlApp,
};

use crate::telemetry::TelemetryDecoderResult::{CRCMismatch, NoPacket, Packet};

pub struct DataLogV1Entry {
    pub packet: LogPacketV1,
    pub euler_a: f32,                        // deg
    pub euler_b: f32,                        // deg
    pub euler_y: f32,                        // deg
    pub fused_accel_rel_earth: FusionVector, // G
}

pub struct DataLogV1 {
    pub entries: Vec<DataLogV1Entry>,
    pub num_packets_crc_mismatch: u32,
}

pub fn load_zstd_data_log_v1(path: PathBuf) -> Result<DataLogV1, std::io::Error> {
    let file = File::open(path).unwrap();
    let buf_reader = BufReader::new(file);
    let mut zstd_reader = zstd::Decoder::new(buf_reader)?;
    let mut packet_decoder = TelemetryDecoder::<LogPacketV1>::new();

    let mut entries = Vec::new();
    let mut num_packets_crc_mismatch: u32 = 0;

    /* Sensor fusion */
    unsafe {
        let mut offset = MaybeUninit::<FusionOffset>::uninit();
        let mut ahrs = MaybeUninit::<FusionAhrs>::uninit();
        const INTERVAL_MS: u32 = 10;

        let sample_rate = (1000.0 / INTERVAL_MS as f32) as u32;
        FusionOffsetInitialise(offset.as_mut_ptr(), sample_rate);
        FusionAhrsInitialise(ahrs.as_mut_ptr());
        // Set AHRS algorithm settings
        let mut settings = FusionAhrsSettings {
            convention: FusionConvention_FusionConventionNwu,
            gain: 0.1,
            gyroscopeRange: 245.0, /* replace this with actual gyroscope range in degrees/s */
            accelerationRejection: 1.0,
            magneticRejection: 10.0,
            recoveryTriggerPeriod: (5 * sample_rate) as u32, /* 5 seconds */
        };
        let mut offset = offset.assume_init();
        let mut ahrs = ahrs.assume_init();

        let mut last_time_ms = 0;
        let mut buf = vec![0; 1048576];
        loop {
            let bytes_read = zstd_reader.read(&mut *buf)?;
            for b in &buf[0..bytes_read] {
                match packet_decoder.decode(*b) {
                    Packet(p) => {
                        let time_elapsed_ms = p.time_boot_ms - last_time_ms;
                        last_time_ms = p.time_boot_ms;
                        /* Sensor fusion */
                        /* Flip signs and rearrange things as necessary to make sensor axes match FC axes */
                        /* FC axes are oriented with +X being from the STM32 to the SD card slot, and +Y being from the STM32 to the SWD port */

                        // TODO: THE MANY REASONS THIS SENSOR FUSION MIGHT NOT WORK:
                        // TODO: - We do not have magnetometer data
                        // TODO: - The Fusion AHRS library cannot take into account that the ADXL375 is off the center of mass and therefore will register accelerations when the rocket rotates about its center of mass.
                        // TODO: make these not use hardcoded offsets as calibration lol
                        let adxl_offs_x = -0.75 / 9.81;
                        let adxl_offs_y = -3.8 / 9.81;
                        let adxl_offs_z = -8.19 / 9.81;

                        let bmi323_accel_offs_x = 0.;
                        let bmi323_accel_offs_y = 0.;
                        let bmi323_accel_offs_z = 0.;

                        let bmi323_gyro_offs_x = 0.5;
                        let bmi323_gyro_offs_y = 0.;
                        let bmi323_gyro_offs_z = 0.;

                        let accelerometer = FusionVector {
                            array: [
                                -(p.adxl375_accel_x + adxl_offs_x),
                                -(p.adxl375_accel_y + adxl_offs_y),
                                p.adxl375_accel_z + adxl_offs_z,
                            ],
                        };
                        // let accelerometer = FusionVector {
                        //     array: [
                        //         -(p.bmi323_accel_x + bmi323_accel_offs_x),
                        //         -(p.bmi323_accel_y + bmi323_accel_offs_y),
                        //         p.bmi323_accel_z + bmi323_accel_offs_z,
                        //     ],
                        // };
                        let gyroscope = FusionVector {
                            array: [
                                -(p.bmi323_gyro_x + bmi323_gyro_offs_x),
                                -(p.bmi323_gyro_y + bmi323_gyro_offs_y),
                                -(p.bmi323_gyro_z + bmi323_gyro_offs_z),
                            ],
                        };

                        FusionOffsetUpdate(&mut offset, gyroscope);

                        // set gain to favor gyro if angular velocities are high
                        let favor_gyro = p.bmi323_gyro_x.abs() > 3.0
                            || p.bmi323_gyro_y.abs() > 3.0
                            || p.bmi323_gyro_z.abs() > 3.0;
                        if favor_gyro {
                            settings.gain = 0.5;
                        } else {
                            settings.gain = 0.5;
                        }
                        FusionAhrsSetSettings(&mut ahrs, &settings);

                        for i in 0..(time_elapsed_ms / INTERVAL_MS) {
                            FusionAhrsUpdateNoMagnetometer(
                                &mut ahrs,
                                gyroscope,
                                accelerometer,
                                INTERVAL_MS as f32 / 1000.0,
                            );    
                        }
                        let euler = FusionQuaternionToEuler(FusionAhrsGetQuaternion(&ahrs));

                        let fused_accel_rel_earth = FusionAhrsGetLinearAcceleration(&ahrs);

                        let euler_a = euler.angle.roll;
                        let euler_b = euler.angle.pitch;
                        let euler_y = euler.angle.yaw;

                        entries.push(DataLogV1Entry {
                            fused_accel_rel_earth,
                            euler_a,
                            euler_b,
                            euler_y,
                            packet: p,
                        });
                    }
                    CRCMismatch => num_packets_crc_mismatch += 1,
                    NoPacket => {}
                }
            }
            if bytes_read == 0 {
                break;
            }
        }

        return Ok(DataLogV1 {
            entries,
            num_packets_crc_mismatch,
        });
    }
}

impl GroundControlApp {
    pub fn replay_until_time_ms(&mut self, time_ms: f64) {
        let data_log = self.data_log.as_ref().unwrap();

        while self.data_log_replay_next_packet_index < data_log.entries.len() {
            let i = self.data_log_replay_next_packet_index;
            let p = data_log.entries[i].packet;
            if p.time_boot_ms > time_ms as u32 {
                self.data_log_replay_time_ms = time_ms;
                return;
            }

            /* The same way the sensor fusion on the flight computer works */
            let t = p.time_boot_ms as f64 / 1000.0;
            let fused = &data_log.entries[i];
            self.data.euler_a.add_point(t, fused.euler_a as f64);
            self.data.euler_b.add_point(t, fused.euler_b as f64);
            self.data.euler_y.add_point(t, fused.euler_y as f64);

            unsafe {
                let accel_magnitude = FusionVectorMagnitude(fused.fused_accel_rel_earth);
                self.data
                    .fused_accel_magnitude
                    .add_point(t, G_to_mps2(accel_magnitude as f64));
                self.data
                    .fused_accel_x
                    .add_point(t, G_to_mps2(fused.fused_accel_rel_earth.axis.x as f64));
                self.data
                    .fused_accel_y
                    .add_point(t, G_to_mps2(fused.fused_accel_rel_earth.axis.y as f64));
                self.data
                    .fused_accel_z
                    .add_point(t, G_to_mps2(fused.fused_accel_rel_earth.axis.z as f64));
            }

            self.data
                .ms5607_pressure_mbar
                .add_point(t, p.ms5607_pressure_mbar as f64);

            self.data
                .bmi323_accel_x
                .add_point(t, G_to_mps2(p.bmi323_accel_x as f64));
            self.data
                .bmi323_accel_y
                .add_point(t, G_to_mps2(p.bmi323_accel_y as f64));
            self.data
                .bmi323_accel_z
                .add_point(t, G_to_mps2(p.bmi323_accel_z as f64));

            self.data
                .bmi323_gyro_x
                .add_point(t, (p.bmi323_gyro_x as f64));
            self.data
                .bmi323_gyro_y
                .add_point(t, (p.bmi323_gyro_y as f64));
            self.data
                .bmi323_gyro_z
                .add_point(t, (p.bmi323_gyro_z as f64));

            self.data
                .adxl375_accel_x
                .add_point(t, G_to_mps2(p.adxl375_accel_x as f64));
            self.data
                .adxl375_accel_y
                .add_point(t, G_to_mps2(p.adxl375_accel_y as f64));
            self.data
                .adxl375_accel_z
                .add_point(t, G_to_mps2(p.adxl375_accel_z as f64));

            self.data.status_flag_recovery_armed = p.status_flags & (1 << 0) != 0;
            self.data.status_flag_ematch_drogue_deployed = p.status_flags & (1 << 1) != 0;
            self.data.status_flag_ematch_main_deployed = p.status_flags & (1 << 2) != 0;
            self.data.status_flag_sd_card_degraded = p.status_flags & (1 << 3) != 0;
            self.data.status_flag_adxl375_degraded = p.status_flags & (1 << 4) != 0;
            self.data.status_flag_bm1422_degraded = p.status_flags & (1 << 5) != 0;
            self.data.status_flag_bmi323_degraded = p.status_flags & (1 << 6) != 0;
            self.data.status_flag_ms5607_degraded = p.status_flags & (1 << 7) != 0;

            self.data_log_replay_next_packet_index += 1;
        }

        self.data_log_status = RichText::new("Playback complete");
    }

    pub fn replay_skip_ahead_to_launch(&mut self) {
        // skip to 5 seconds before something hits a high accel
        let mut time_ms = 0;
        // println!("{}", self.data_log.as_ref().unwrap().entries.len());
        for e in &self.data_log.as_ref().unwrap().entries {
            unsafe {
                let accel_magnitude = FusionVectorMagnitude(e.fused_accel_rel_earth);
                if accel_magnitude > 10. {
                    // this value is in G
                    time_ms = e.packet.time_boot_ms;
                    break;
                }
            }
        }
        self.replay_until_time_ms((time_ms - 5000) as f64);
    }
}
