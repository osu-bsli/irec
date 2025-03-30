
#[repr(C, packed)]
#[derive(Clone)]
pub struct TelemetryPacket {
    pub magic: [u8; 9], // 'FUCKPETER' in ASCII with no null terminator
    pub size: u8, // Total size of struct
    pub crc16: u16, // CRC16 
    pub status_flags: u8, // StatusFlags bitfield
    pub time_boot_ms: u32, // Timestamp (ms since system boot)
    pub pitch: f32, // Fused sensor data (unit: Euler angle deg)
    pub yaw: f32,   // Fused sensor data (unit: Euler angle deg)
    pub roll: f32,  // Fused sensor data (unit: Euler angle deg)
    pub accel_magnitude: f32, // Magnitude of acceleration (unit: G)
    pub ms5607_pressure_mbar: f32, // Pressure (unit: mbar)
}

pub struct TelemetryDecoder {
    data: [u8; size_of::<TelemetryPacket>()],
    data_pos: usize,

    pub packets_accepted: usize,
    pub packets_rejected: usize,
}

impl TelemetryDecoder {
    const MAGIC: &'static [u8] = "FUCKPETER".as_bytes();

    pub fn new() -> Self {
        Self {
            data: [0; size_of::<TelemetryPacket>()],
            data_pos: 0,

            packets_accepted: 0,
            packets_rejected: 0,
        }
    }

    pub fn decode(&mut self, byte: u8) -> Option<TelemetryPacket> {
        if self.data_pos < TelemetryDecoder::MAGIC.len() {
            self.data[self.data_pos] = byte;

            if byte == TelemetryDecoder::MAGIC[self.data_pos] {
                self.data_pos += 1;
            } else {
                self.data_pos = 0;
            }
        } else {
            // decode the packet!!!
            self.data[self.data_pos] = byte;
            self.data_pos += 1;

            if self.data_pos >= size_of::<TelemetryPacket>() {
                self.data_pos = 0;

                // Cast array to telemetry packet :sob: 
                let ptr = &mut self.data;
                let packet = unsafe { &mut *(ptr as *mut [u8; size_of::<TelemetryPacket>()] as *mut TelemetryPacket) };

                // extern crate hexdump;
                // hexdump::hexdump(&self.data);

                let packet_crc16 = packet.crc16;
                // the crc16 in the packet is the CRC of the packet data with the crc16 field zeroed out
                packet.crc16 = 0;
                const crc16: crc::Crc<u16> = crc::Crc::<u16>::new(&crc::CRC_16_MODBUS);
                let calculated_crc16 = crc16.checksum(&self.data);
                if calculated_crc16 != packet_crc16 {
                    println!("warning: Telemetry packet CRC16 mismatch. In packet: {:#x} Calculated: {:#x}", packet_crc16, calculated_crc16);
                    self.packets_rejected += 1;
                    return None;
                }

                self.packets_accepted += 1;
                return Some(packet.clone());
            }
        }

        None
    }
}

