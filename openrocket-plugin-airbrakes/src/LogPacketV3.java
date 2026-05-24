import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.charset.StandardCharsets;

/** Builds a packed log_packet_v3 byte array matching the C struct in telemetry.h. */
final class LogPacketV3 {

    static final int   SIZE        = 98;
    static final float DEG_PER_RAD = (float)(180.0 / Math.PI);

    private static final int CRC16_OFFSET = 10;

    /** ISA troposphere: altitude (m) → pressure (mbar). */
    static float altitudeToPressMbar(float alt_m) {
        return 1013.25f * (float) Math.pow(1.0 - 2.25577e-5 * alt_m, 5.25588);
    }

    /** ISA troposphere: altitude (m) → temperature (°C). */
    static float altitudeToTempC(float alt_m) {
        return 14.85f - 0.0065f * alt_m;
    }

    /** CRC-16/Modbus: init=0xFFFF, poly=0xA001 (reflected 0x8005). */
    private static int crcModbus(byte[] data) {
        int crc = 0xFFFF;
        for (byte b : data) {
            crc ^= (b & 0xFF);
            for (int i = 0; i < 8; i++) {
                if ((crc & 1) != 0) crc = (crc >>> 1) ^ 0xA001;
                else                crc >>>= 1;
            }
        }
        return crc;
    }

    /**
     * Fills a packed log_packet_v3 byte array ready to write to serial.
     * Field order and byte layout match the C struct exactly (little-endian, no padding).
     * CRC-Modbus is computed over the whole packet (crc16 field zeroed) and written in.
     *
     * @param accelX_G … Z_G     BMI323 specific force in body frame (G)
     * @param gyroX_degps … Z    BMI323 angular rate in body frame (deg/s)
     * @param hgAccelX_G … Z_G   ADXL375 high-g accelerometer (G)
     */
    static byte[] build(
            int statusFlags,
            long timeBootMs,
            float pressureMbar, float temperatureC,
            float accelX_G,    float accelY_G,    float accelZ_G,
            float gyroX_degps, float gyroY_degps, float gyroZ_degps,
            float hgAccelX_G,  float hgAccelY_G,  float hgAccelZ_G
    ) {
        ByteBuffer buf = ByteBuffer.allocate(SIZE).order(ByteOrder.LITTLE_ENDIAN);
        buf.put("COREYMAY3".getBytes(StandardCharsets.US_ASCII)); // magic[9]
        buf.put((byte) SIZE);                                      // size
        buf.putShort((short) 0);                                   // crc16 placeholder
        buf.put((byte) statusFlags);                               // status_flags
        buf.putInt((int) timeBootMs);                              // time_boot_ms
        buf.putFloat(pressureMbar);                                // ms5607_pressure_mbar
        buf.putFloat(temperatureC);                                // ms5607_temperature_c
        buf.putFloat(accelX_G);                                    // bmi323_accel_x_G
        buf.putFloat(accelY_G);                                    // bmi323_accel_y_G
        buf.putFloat(accelZ_G);                                    // bmi323_accel_z_G
        buf.putFloat(gyroX_degps);                                 // bmi323_gyro_x_degps
        buf.putFloat(gyroY_degps);                                 // bmi323_gyro_y_degps
        buf.putFloat(gyroZ_degps);                                 // bmi323_gyro_z_degps
        buf.putFloat(hgAccelX_G);                                  // adxl375_accel_x_G
        buf.putFloat(hgAccelY_G);                                  // adxl375_accel_y_G
        buf.putFloat(hgAccelZ_G);                                  // adxl375_accel_z_G
        buf.putFloat(0f);                                          // bm1422_magn_x
        buf.putFloat(0f);                                          // bm1422_magn_y
        buf.putFloat(0f);                                          // bm1422_magn_z
        buf.putFloat(0f);                                          // gps_lat_deg
        buf.putFloat(0f);                                          // gps_lng_deg
        buf.putFloat(0f);                                          // gps_alt_m
        buf.putFloat(0f);                                          // gps_speed_mps
        buf.putFloat(0f);                                          // pt_volts
        buf.putInt(0);                                             // gps_course
        buf.put((byte) 0);                                         // gps_num_sats

        byte[] bytes = buf.array();
        int crc = crcModbus(bytes);
        bytes[CRC16_OFFSET]     = (byte)  (crc & 0xFF);
        bytes[CRC16_OFFSET + 1] = (byte) ((crc >> 8) & 0xFF);
        return bytes;
    }

    private LogPacketV3() {}
}
