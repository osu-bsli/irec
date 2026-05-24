use std::{
    fs::File,
    io::{BufReader, Read, Write},
    mem::MaybeUninit,
    num,
    path::PathBuf,
};

use egui::{Color32, RichText};
use num_traits::{ops::bytes, Float, Pow};
use serde::Serialize;

use crate::{
    telemetry::{LogPacketV3, TelemetryDecoder},
    G_to_mps2, GroundControlApp,
};

use crate::telemetry::TelemetryDecoderResult::{CRCMismatch, NoPacket, Packet};

pub struct DataLogV3Entry {
    pub packet: LogPacketV3,
}

pub struct DataLogV3 {
    pub entries: Vec<DataLogV3Entry>,
    pub num_packets_crc_mismatch: u32,
}

impl DataLogV3 {
    pub fn get_launch_time_ms(&self) -> Option<u32> {
        let mut time_ms = None;
        // println!("{}", self.data_log.as_ref().unwrap().entries.len());
        for e in &self.entries {
            unsafe {
                let p = e.packet;
                let accel_magnitude = (p.adxl375_accel_x.powi(2)
                    + p.adxl375_accel_y.powi(2)
                    + p.adxl375_accel_z.powi(2))
                .sqrt();
                if accel_magnitude > 10. {
                    // this value is in G
                    time_ms = Some(e.packet.time_boot_ms);
                    break;
                }
            }
        }

        time_ms
    }

    pub fn flight_to_csv<T: Write>(&self, out: T) {
        // TODO
    }
}

fn load_data_log_v3_from_bufreader<T: Read>(buf_reader: &mut T) -> Result<DataLogV3, std::io::Error> {
    let mut entries = Vec::new();
    let mut num_packets_crc_mismatch: u32 = 0;
    let mut buf = vec![0; 1048576];

    let mut packet_decoder = TelemetryDecoder::<LogPacketV3>::new();

    loop {
        let bytes_read= buf_reader.read(&mut buf)?;
        for b in &buf[0..bytes_read] {
            match packet_decoder.decode(*b) {
                Packet(p) => {
                    entries.push(DataLogV3Entry { packet: p });
                }
                CRCMismatch => num_packets_crc_mismatch += 1,
                NoPacket => {}
            }
        }
        if bytes_read == 0 {
            break;
        }
    }

    return Ok(DataLogV3 {
        entries,
        num_packets_crc_mismatch,
    })
}

pub fn load_data_log_v3_from_path(
    path: PathBuf,
    is_zstd_compressed: bool,
) -> Result<DataLogV3, std::io::Error> {
    let file = File::open(path).unwrap();
    let mut buf_reader = BufReader::new(file);

    if is_zstd_compressed
    {
        let mut zstd_reader = zstd::Decoder::new(buf_reader)?;
        return load_data_log_v3_from_bufreader(&mut zstd_reader);
    }
    else {
        return load_data_log_v3_from_bufreader(&mut buf_reader);
    }
}

impl GroundControlApp {
    pub fn open_data_log_v3(&mut self, path: PathBuf, is_zstd_compressed: bool) {
        if let Ok(data_log) = load_data_log_v3_from_path(path, is_zstd_compressed) {
            self.data_log_status = RichText::new(format!(
                "Data log successfully loaded!\n{} packets\n{} bad packets",
                data_log.entries.len(),
                data_log.num_packets_crc_mismatch
            ));

            for e in &data_log.entries
            {
                let t = e.packet.time_boot_ms as f64 / 1000.0;
                self.data.adxl375_accel_z.add_point(t, e.packet.adxl375_accel_z as f64);
            }

            self.data_log = Some(data_log);
        } else {
            if is_zstd_compressed
            {
                self.data_log_status =
                    RichText::new("Error loading data log. It should be compressed with zstd, is it?")
                        .color(Color32::RED);
            }
            else
            {
                self.data_log_status =
                    RichText::new("Error loading data log.")
                        .color(Color32::RED);
            }
        }
    }

    pub fn replay_until_time_ms(&mut self, time_ms: f64) {
        // TODO
        self.data_log_status = RichText::new("Playback complete");
    }

    pub fn replay_skip_ahead_to_launch(&mut self, ms_before_launch: u32) {
        let time_ms = self.data_log.as_ref().unwrap().get_launch_time_ms();
        if let Some(time_ms) = time_ms {
            self.replay_until_time_ms((time_ms - ms_before_launch) as f64);
        }
    }
}
