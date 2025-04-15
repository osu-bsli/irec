#[repr(C, packed)]
#[derive(Clone, Copy, bytemuck::Zeroable, bytemuck::Pod)]
pub struct PacketHeader {
    pub magic: [u8; 9],
    pub size: u8, // Total size of packet struct
    pub crc16: u16,
}

pub trait Packet {
    fn magic() -> &'static [u8];
}

#[repr(C, packed)]
#[derive(Clone, Copy, bytemuck::Zeroable, bytemuck::Pod)]
pub struct TelemetryPacket {
    pub header: PacketHeader, // Magic is 'FUCKPETER' in ASCII with no null terminator
    pub status_flags: u8,     // StatusFlags bitfield
    pub time_boot_ms: u32,    // Timestamp (ms since system boot)
    pub euler_a: f32,         // Fused sensor data (unit: Euler angle deg)
    pub euler_b: f32,         // Fused sensor data (unit: Euler angle deg)
    pub euler_y: f32,         // Fused sensor data (unit: Euler angle deg)
    pub accel_magnitude: f32, // Magnitude of acceleration (unit: G)
    pub ms5607_pressure_mbar: f32, // Pressure (unit: mbar)
}

impl Packet for TelemetryPacket {
    fn magic() -> &'static [u8] {
        b"FUCKPETER"
    }
}

/* Used on the 4-12-2025 test launch */
#[repr(C, packed)]
#[derive(Clone, Copy, bytemuck::Zeroable, bytemuck::Pod)]
pub struct LogPacketV1 {
    pub header: PacketHeader, // Magic is 'COREYMAYS' in ASCII with no null terminator
    pub status_flags: u8,     // StatusFlags bitfield
    pub time_boot_ms: u32,    // Timestamp (ms since system boot)
    pub ms5607_pressure_mbar: f32, // MS5607 Air Pressure (unit: mbar)
    pub ms5607_temperature_c: f32, // MS5607 Temperature (unit: degrees C)
    pub bmi323_accel_x_g: f32,  // BMI323 Acceleration X (unit: G)
    pub bmi323_accel_y_g: f32,  // BMI323 Acceleration Y (unit: G)
    pub bmi323_accel_z_g: f32,  // BMI323 Acceleration Z (unit: G)
    pub bmi323_gyro_x_dps: f32,   // BMI323 Gyroscope X (unit: deg/s)
    pub bmi323_gyro_y_dps: f32,   // BMI323 Gyroscope Y (unit: deg/s)
    pub bmi323_gyro_z_dps: f32,   // BMI323 Gyroscope Z (unit: deg/s)
    pub adxl375_accel_x_g: f32, // ADXL375 Acceleration X (unit: G)
    pub adxl375_accel_y_g: f32, // ADXL375 Acceleration Y (unit: G)
    pub adxl375_accel_z_g: f32, // ADXL375 Acceleration Z (unit: G)
}

impl Packet for LogPacketV1 {
    fn magic() -> &'static [u8] {
        b"COREYMAYS"
    }
}

pub struct TelemetryDecoder<T> {
    data: [u8; 1024],
    data_pos: usize,

    pub packets_accepted: usize,
    pub packets_rejected: usize,

    _marker: std::marker::PhantomData<T>,
}

pub enum TelemetryDecoderResult<T> {
    NoPacket,
    Packet(T),
    CRCMismatch,
}

impl<T: Clone + Packet + bytemuck::AnyBitPattern> TelemetryDecoder<T> {
    pub fn new() -> Self {
        Self {
            data: [0; 1024],
            data_pos: 0,

            packets_accepted: 0,
            packets_rejected: 0,

            _marker: Default::default(),
        }
    }

    pub fn decode(&mut self, byte: u8) -> TelemetryDecoderResult<T> {
        if self.data_pos < T::magic().len() {
            self.data[self.data_pos] = byte;

            if byte == T::magic()[self.data_pos] {
                self.data_pos += 1;
            } else {
                self.data_pos = 0;
            }

            return TelemetryDecoderResult::NoPacket;
        } else {
            // decode the packet!!!
            self.data[self.data_pos] = byte;
            self.data_pos += 1;

            if self.data_pos >= size_of::<T>() {
                self.data_pos = 0;

                // Use bytemuck to cast data to packet header
                let header = bytemuck::from_bytes_mut::<PacketHeader>(&mut self.data[0..size_of::<PacketHeader>()]);
                // Grab the crc16 from header
                let packet_crc16 = header.crc16;
                // the crc16 in the packet is the CRC of the packet data with the crc16 field zeroed out
                // so zero out the crc16 in self.data
                header.crc16 = 0;

                // Now cast the data to the packet itself
                let packet = bytemuck::from_bytes::<T>(&self.data[0..size_of::<T>()]);

                let crc16: crc::Crc<u16> = crc::Crc::<u16>::new(&crc::CRC_16_MODBUS);
                let calculated_crc16 = crc16.checksum(&self.data[0..size_of::<T>()]);
                if calculated_crc16 != packet_crc16 {
                    // println!("warning: Telemetry packet CRC16 mismatch. In packet: {:#x} Calculated: {:#x}", packet_crc16, calculated_crc16);
                    self.packets_rejected += 1;
                    return TelemetryDecoderResult::CRCMismatch;
                }

                self.packets_accepted += 1;
                return TelemetryDecoderResult::Packet(packet.clone());
            }
        }

        return TelemetryDecoderResult::NoPacket;
    }
}
