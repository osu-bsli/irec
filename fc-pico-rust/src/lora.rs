// Ported from arduino-LoRa Copyright (c) Brian Jia, Sandeep Mistry. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

use bytemuck::Contiguous;
use defmt::println;
use embassy_rp::{gpio::{Output}, mode::{Async}, spi::Spi};
use embassy_time::Timer;

// registers
#[allow(unused)]
mod registers {
    pub const REG_FIFO: u8 =                 0x00;
    pub const REG_OP_MODE: u8 =              0x01;
    pub const REG_FRF_MSB: u8 =              0x06;
    pub const REG_FRF_MID: u8 =              0x07;
    pub const REG_FRF_LSB: u8 =              0x08;
    pub const REG_PA_CONFIG: u8 =            0x09;
    pub const REG_OCP: u8 =                  0x0b;
    pub const REG_LNA: u8 =                  0x0c;
    pub const REG_FIFO_ADDR_PTR: u8 =        0x0d;
    pub const REG_FIFO_TX_BASE_ADDR: u8 =    0x0e;
    pub const REG_FIFO_RX_BASE_ADDR: u8 =    0x0f;
    pub const REG_FIFO_RX_CURRENT_ADDR: u8 = 0x10;
    pub const REG_IRQ_FLAGS: u8 =            0x12;
    pub const REG_RX_NB_BYTES: u8 =          0x13;
    pub const REG_PKT_SNR_VALUE: u8 =        0x19;
    pub const REG_PKT_RSSI_VALUE: u8 =       0x1a;
    pub const REG_RSSI_VALUE: u8 =           0x1b;
    pub const REG_MODEM_CONFIG_1: u8 =       0x1d;
    pub const REG_MODEM_CONFIG_2: u8 =       0x1e;
    pub const REG_PREAMBLE_MSB: u8 =         0x20;
    pub const REG_PREAMBLE_LSB: u8 =         0x21;
    pub const REG_PAYLOAD_LENGTH: u8 =       0x22;
    pub const REG_MODEM_CONFIG_3: u8 =       0x26;
    pub const REG_FREQ_ERROR_MSB: u8 =       0x28;
    pub const REG_FREQ_ERROR_MID: u8 =       0x29;
    pub const REG_FREQ_ERROR_LSB: u8 =       0x2a;
    pub const REG_RSSI_WIDEBAND: u8 =        0x2c;
    pub const REG_DETECTION_OPTIMIZE: u8 =   0x31;
    pub const REG_INVERTIQ: u8 =             0x33;
    pub const REG_DETECTION_THRESHOLD: u8 =  0x37;
    pub const REG_SYNC_WORD: u8 =            0x39;
    pub const REG_INVERTIQ2: u8 =            0x3b;
    pub const REG_DIO_MAPPING_1: u8 =        0x40;
    pub const REG_VERSION: u8 =              0x42;
    pub const REG_PA_DAC: u8 =               0x4d;

    // modes
    pub const MODE_LONG_RANGE_MODE: u8 =     0x80;
    pub const MODE_SLEEP: u8 =               0x00;
    pub const MODE_STDBY: u8 =               0x01;
    pub const MODE_TX: u8 =                  0x03;
    pub const MODE_RX_CONTINUOUS: u8 =       0x05;
    pub const MODE_RX_SINGLE: u8 =           0x06;
    pub const MODE_CAD: u8 =                 0x07;

    // PA config
    pub const PA_BOOST: u8 =                 0x80;

    // IRQ masks
    pub const IRQ_TX_DONE_MASK: u8 =           0x08;
    pub const IRQ_PAYLOAD_CRC_ERROR_MASK: u8 = 0x20;
    pub const IRQ_RX_DONE_MASK: u8 =           0x40;
    pub const IRQ_CAD_DONE_MASK: u8 =          0x04;
    pub const IRQ_CAD_DETECTED_MASK: u8 =      0x01;

    pub const RF_MID_BAND_THRESHOLD: u32 =    525000000;
    pub const RSSI_OFFSET_HF_PORT: u8 =      157;
    pub const RSSI_OFFSET_LF_PORT: u8 =      164;

    pub const MAX_PKT_LENGTH: u8 =           255;

    pub const PA_OUTPUT_RFO_PIN: u8 =           0;
    pub const PA_OUTPUT_PA_BOOST_PIN: u8 =      1;
}

use registers::*;

struct LoRa<'a> {
    cs: Output<'a>, // Chip select
    reset: Option<Output<'a>>, 
    spi: Spi<'a, Async>,

    _implicit_header_mode: bool,
    _packet_index: u32,
    _frequency: u32,
}

impl<'a> LoRa<'a> {
    async fn new(cs: Output<'a>, reset: Option<Output<'a>>, spi: Spi<'a, Async>, frequency: u32) -> Option<Self> {
        let mut lora = LoRa {
            cs, reset, spi,
            _implicit_header_mode: false,
            _packet_index: 0,
            _frequency: frequency,
        };
        // set CS high
        lora.cs.set_high();

        if let Some(reset) = &mut lora.reset {
            // perform reset
            reset.set_low();
            Timer::after_millis(10).await;
            reset.set_high();
            Timer::after_millis(10).await;
        }

        // check version
        let version = lora.read_register(REG_VERSION).await;
        if version != 0x12 {
            return None;
        }

        // put in sleep mode
        lora.sleep().await;

        // set frequency
        lora.set_frequency(frequency).await;

        // set bandwith to 41.7 kHz by default
        lora.set_signal_bandwidth(41.7E3 as u32).await;

        // set base addresses
        lora.write_register(REG_FIFO_TX_BASE_ADDR, 0).await;
        lora.write_register(REG_FIFO_RX_BASE_ADDR, 0).await;

        // set LNA boost
        let reg_lna_val = lora.read_register(REG_LNA).await;
        lora.write_register(REG_LNA, reg_lna_val | 0x03).await;

        // set auto AGC
        lora.write_register(REG_MODEM_CONFIG_3, 0x04).await;

        // set output power to 17 dBm
        lora.set_tx_power(17, PA_OUTPUT_PA_BOOST_PIN).await;

        // put in standby mode
        lora.idle().await;

        return Some(lora);
    }

    async fn begin_packet(&mut self, implicit_header: bool) -> bool {
        if self.is_transmitting().await {
            return false;
        }

        // put in standby mode
        self.idle().await;

        if implicit_header {
            self.implicit_header_mode().await;
        } else {
            self.explicit_header_mode().await;
        }

        // reset FIFO address and paload length
        self.write_register(REG_FIFO_ADDR_PTR, 0).await;
        self.write_register(REG_PAYLOAD_LENGTH, 0).await;

        return true;
    }

    async fn end_packet(&mut self, do_async: bool) -> bool {
        // TODO: the original line is if (do_async) && (_onTxDone) {
        if do_async {
            self.write_register(REG_DIO_MAPPING_1, 0x40).await; // DIO0 => TXDONE
        }

        // put in TX mode
        self.write_register(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_TX).await;

        if !do_async {
            // wait for TX done
            while self.read_register(REG_IRQ_FLAGS).await & IRQ_TX_DONE_MASK == 0 {
                // TODO: yield(); 
            }
            // clear IRQ's
            self.write_register(REG_IRQ_FLAGS, IRQ_TX_DONE_MASK).await;
        }

        return true;
    }

    async fn is_transmitting(&mut self) -> bool {
        if self.read_register(REG_OP_MODE).await & MODE_TX != 0 {
            return true;
        }

        if self.read_register(REG_IRQ_FLAGS).await & IRQ_TX_DONE_MASK != 0 {
            // clear IRQ's
            self.write_register(REG_IRQ_FLAGS, IRQ_TX_DONE_MASK).await;
        }

        return false;
    }

    async fn parse_packet(&mut self, size: u8) -> u8
    {
        let mut packet_length: u8 = 0;
        let irq_flags: u8 = self.read_register(REG_IRQ_FLAGS).await;

        if size > 0 {
            self.implicit_header_mode().await;
            self.write_register(REG_PAYLOAD_LENGTH, size).await;
        } else {
            self.explicit_header_mode().await;
        }

        // clear IRQ's
        self.write_register(REG_IRQ_FLAGS, irq_flags).await;

        if (irq_flags & IRQ_RX_DONE_MASK != 0) && (irq_flags & IRQ_PAYLOAD_CRC_ERROR_MASK) == 0 {
            // received a packet
            self._packet_index = 0;

            // read packet length
            if self._implicit_header_mode {
                packet_length = self.read_register(REG_PAYLOAD_LENGTH).await;
            } else {
                packet_length = self.read_register(REG_RX_NB_BYTES).await;
            }

            // set FIFO address to current RX address
            let reg_fifo_rx_current_addr_val = self.read_register(REG_FIFO_RX_CURRENT_ADDR).await;
            self.write_register(REG_FIFO_ADDR_PTR, reg_fifo_rx_current_addr_val).await;

            // put in standby mode
            self.idle().await;
        } else if self.read_register(REG_OP_MODE).await != (MODE_LONG_RANGE_MODE | MODE_RX_SINGLE) {
            // not currently in RX mode

            // reset FIFO address
            self.write_register(REG_FIFO_ADDR_PTR, 0).await;

            // put in single RX mode
            self.write_register(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_RX_SINGLE).await;
        }

        return packet_length;
    }

    async fn packet_rssi(&mut self) -> i32 {
        return (self.read_register(REG_PKT_RSSI_VALUE).await as i32) - (if self._frequency < RF_MID_BAND_THRESHOLD {RSSI_OFFSET_LF_PORT as i32} else {RSSI_OFFSET_HF_PORT as i32} );
    }

    async fn packet_snr(&mut self) -> f32 {
        return (self.read_register(REG_PKT_SNR_VALUE).await as i8 as f32) * 0.25;
    }

    async fn packet_frequency_error(&mut self) -> u64 {
        let mut freq_error: u32;
        freq_error = (self.read_register(REG_FREQ_ERROR_MSB).await & 0b111) as u32;
        freq_error <<= 8;
        freq_error += self.read_register(REG_FREQ_ERROR_MID).await as u32;
        freq_error <<= 8;
        freq_error += self.read_register(REG_FREQ_ERROR_LSB).await as u32;

        if self.read_register(REG_FREQ_ERROR_MSB).await & 0b1000 != 0 { // Sign bit is on
            freq_error -= 524288; // 0b1000'0000'0000'0000'0000
        }

        let f_xtal: f32 = 32E6; // FXOSC: crystal oscillator (XTAL) frequency (2.5. Chip Specification, p. 14)
        let f_error: f32 = (((freq_error as f32) * ((1 << 24) as f32)) / f_xtal) * ((self.get_signal_bandwidth().await.unwrap() as f32) / 500000.0f32); // p. 37

        return f_error as u64;
    }

    async fn rssi(&mut self) -> i32 {
        return (self.read_register(REG_RSSI_VALUE).await as i32 - (if self._frequency < RF_MID_BAND_THRESHOLD {RSSI_OFFSET_LF_PORT as i32} else {RSSI_OFFSET_HF_PORT as i32}));
    }

    async fn write(&mut self, buffer: &[u8]) -> Result<(), ()> {
        if buffer.len() >= 256 {
            return Err(());
        }
        let current_length: u8 = self.read_register(REG_PAYLOAD_LENGTH).await;

        // check size
        if (current_length + buffer.len() as u8) > MAX_PKT_LENGTH {
            return Err(());
        }

        // write data
        for i in 0..buffer.len() {
            self.write_register(REG_FIFO, buffer[i]).await;
        }

        // update length
        self.write_register(REG_PAYLOAD_LENGTH, current_length + buffer.len() as u8).await;

        return Ok(());
    }

    async fn available(&mut self) -> u32
    {
        return self.read_register(REG_RX_NB_BYTES).await as u32 - self._packet_index;
    }

    async fn read(&mut self) -> Result<u8, ()> {
        if self.available().await == 0 {
            return Err(());
        }

        self._packet_index += 1;

        return Ok(self.read_register(REG_FIFO).await);
    }

    async fn peek(&mut self) -> Result<u8, ()>
    {
        if self.available().await == 0 {
            return Err(());
        }

        // store current FIFO address
        let current_address = self.read_register(REG_FIFO_ADDR_PTR).await;

        // read
        let b: u8 = self.read_register(REG_FIFO).await;

        // restore FIFO address
        self.write_register(REG_FIFO_ADDR_PTR, current_address).await;

        return Ok(b);
    }

    // void LoRaClass::onReceive(void(*callback)(int))
    // {
    // _onReceive = callback;

    // if (callback) {
    //     pinMode(_dio0, INPUT);
    // #ifdef SPI_HAS_NOTUSINGINTERRUPT
    //     SPI.usingInterrupt(digitalPinToInterrupt(_dio0));
    // #endif
    //     attachInterrupt(digitalPinToInterrupt(_dio0), LoRaClass::onDio0Rise, RISING);
    // } else {
    //     detachInterrupt(digitalPinToInterrupt(_dio0));
    // #ifdef SPI_HAS_NOTUSINGINTERRUPT
    //     SPI.notUsingInterrupt(digitalPinToInterrupt(_dio0));
    // #endif
    // }
    // }

    // void LoRaClass::onCadDone(void(*callback)(boolean))
    // {
    // _onCadDone = callback;

    // if (callback) {
    //     pinMode(_dio0, INPUT);
    // #ifdef SPI_HAS_NOTUSINGINTERRUPT
    //     SPI.usingInterrupt(digitalPinToInterrupt(_dio0));
    // #endif
    //     attachInterrupt(digitalPinToInterrupt(_dio0), LoRaClass::onDio0Rise, RISING);
    // } else {
    //     detachInterrupt(digitalPinToInterrupt(_dio0));
    // #ifdef SPI_HAS_NOTUSINGINTERRUPT
    //     SPI.notUsingInterrupt(digitalPinToInterrupt(_dio0));
    // #endif
    // }
    // }

    // void LoRaClass::onTxDone(void(*callback)())
    // {
    // _onTxDone = callback;

    // if (callback) {
    //     pinMode(_dio0, INPUT);
    // #ifdef SPI_HAS_NOTUSINGINTERRUPT
    //     SPI.usingInterrupt(digitalPinToInterrupt(_dio0));
    // #endif
    //     attachInterrupt(digitalPinToInterrupt(_dio0), LoRaClass::onDio0Rise, RISING);
    // } else {
    //     detachInterrupt(digitalPinToInterrupt(_dio0));
    // #ifdef SPI_HAS_NOTUSINGINTERRUPT
    //     SPI.notUsingInterrupt(digitalPinToInterrupt(_dio0));
    // #endif
    // }
    // }

    async fn receive_implicit_header(&mut self, size: u8) {
        self.write_register(REG_DIO_MAPPING_1, 0x00).await; // DIO0 => RXDONE
        self.write_register(REG_PAYLOAD_LENGTH, size).await;
        self.write_register(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_RX_CONTINUOUS).await;
    }

    async fn receive_explicit_header(&mut self) {
        self.write_register(REG_DIO_MAPPING_1, 0x00).await; // DIO0 => RXDONE
        self.explicit_header_mode().await;
        self.write_register(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_RX_CONTINUOUS).await;
    }

    // void LoRaClass::channelActivityDetection(void)
    // {
    // writeRegister(REG_DIO_MAPPING_1, 0x80);// DIO0 => CADDONE
    // writeRegister(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_CAD);
    // }

    async fn idle(&mut self) {
        self.write_register(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_STDBY).await;
    }

    async fn sleep(&mut self) {
        self.write_register(REG_OP_MODE, MODE_LONG_RANGE_MODE | MODE_SLEEP).await;
    }

    async fn set_tx_power(&mut self, mut level: u8, output_pin: u8) -> Result<(), ()> {
        if PA_OUTPUT_RFO_PIN == output_pin {
            // RFO
            if level > 14 {
                return Err(());
            }

            self.write_register(REG_PA_CONFIG, 0x70 | level).await;
            return Ok(());
        } else {
            // PA BOOST
            if level > 17 {
                if level > 20 {
                    return Err(());
                }

                // subtract 3 from level, so 18 - 20 maps to 15 - 17
                level -= 3;

                // High Power +20 dBm Operation (Semtech SX1276/77/78/79 5.4.3.)
                self.write_register(REG_PA_DAC, 0x87).await;
                self.set_ocp(140).await;
            } else {
                if level < 2 {
                    return Err(());
                }
                //Default value PA_HF/LF or +17dBm
                self.write_register(REG_PA_DAC, 0x84).await;
                self.set_ocp(100).await;
            }

            self.write_register(REG_PA_CONFIG, PA_BOOST | (level - 2)).await;
            return Ok(());
        }
    }

    async fn set_frequency(&mut self, frequency: u32)
    {
        self._frequency = frequency;

        let frf: u64 = ((frequency as u64) << 19) / 32000000;

        self.write_register(REG_FRF_MSB, (frf >> 16) as u8).await;
        self.write_register(REG_FRF_MID, (frf >> 8) as u8).await;
        self.write_register(REG_FRF_LSB, (frf >> 0) as u8).await;
    }

    async fn get_frequency(&mut self) -> u64 {
        let frf: u64 = 
            ((self.read_register(REG_FRF_MSB).await as u64) << 16) |
            ((self.read_register(REG_FRF_MID).await as u64) << 8) | 
            (self.read_register(REG_FRF_LSB).await as u64);
        return (frf * 32000000) >> 19;
    }

    async fn get_spreading_factor(&mut self) -> u8 {
        return self.read_register(REG_MODEM_CONFIG_2).await >> 4;
    }

    async fn set_spreading_factor(&mut self, sf: u32) -> Result<(), ()> {
        if sf < 6 {
            return Err(());
        } else if sf > 12 {
            return Err(());
        }

        if sf == 6 {
            self.write_register(REG_DETECTION_OPTIMIZE, 0xc5).await;
            self.write_register(REG_DETECTION_THRESHOLD, 0x0c).await;
        } else {
            self.write_register(REG_DETECTION_OPTIMIZE, 0xc3).await;
            self.write_register(REG_DETECTION_THRESHOLD, 0x0a).await;
        }

        let reg_modem_config_2_val = self.read_register(REG_MODEM_CONFIG_2).await;
        self.write_register(REG_MODEM_CONFIG_2, (reg_modem_config_2_val & 0x0f) | (((sf << 4) as u8) & 0xf0)).await;
        self.set_ldo_flag().await;

        return Ok(());
    }

    async fn get_signal_bandwidth(&mut self) -> Option<u32> {
        let bw: u8 = self.read_register(REG_MODEM_CONFIG_1).await >> 4;

        match bw {
            0 => Some(7_800),
            1 => Some(10_400),
            2 => Some(15_600),
            3 => Some(20_800),
            4 => Some(31_250),
            5 => Some(41_700),
            6 => Some(62_500),
            7 => Some(125_00),
            8 => Some(250_00),
            9 => Some(500_00),
            _ => None,
        }
    }

    async fn set_signal_bandwidth(&mut self, sbw: u32) {
        let bw;

        if sbw <= 7_800 {
            bw = 0;
        } else if sbw <= 10_400 {
            bw = 1;
        } else if sbw <= 15_600 {
            bw = 2;
        } else if sbw <= 20_800 {
            bw = 3;
        } else if sbw <= 31_250 {
            bw = 4;
        } else if sbw <= 41_700 {
            bw = 5;
        } else if sbw <= 62_500 {
            bw = 6;
        } else if sbw <= 125_000 {
            bw = 7;
        } else if sbw <= 250_000 {
            bw = 8;
        } else /*if (sbw <= 250E3)*/ {
            bw = 9;
        }

        let reg_modem_config_1_val = self.read_register(REG_MODEM_CONFIG_1).await;
        self.write_register(REG_MODEM_CONFIG_1, (reg_modem_config_1_val & 0x0f) | (bw << 4)).await;
        self.set_ldo_flag().await;
    }

    async fn set_ldo_flag(&mut self) {
        // Section 4.1.1.5
        let symbol_duration: u32 = 1000 / ( self.get_signal_bandwidth().await.unwrap() / (1 << self.get_spreading_factor().await) ) ;

        // Section 4.1.1.6
        let ldo_on: bool = symbol_duration > 16;

        let mut config3: u8 = self.read_register(REG_MODEM_CONFIG_3).await;
        
        config3 &= !(1 << 3);
        config3 |= ldo_on.into_integer() << 3;
        self.write_register(REG_MODEM_CONFIG_3, config3).await;
    }

    async fn set_ldo_flag_forced(&mut self, ldo_on: bool) {
        let mut config3 = self.read_register(REG_MODEM_CONFIG_3).await;
        
        config3 &= !(1 << 3);
        config3 |= ldo_on.into_integer() << 3;
        self.write_register(REG_MODEM_CONFIG_3, config3).await;
    }

    async fn set_coding_rate4(&mut self, denominator: u32) -> Result<(), ()> {
        if denominator < 5 {
            return Err(());
        } else if denominator > 8 {
            return Err(());
        }

        let cr = denominator - 4;

        let reg_modem_config_1_val = self.read_register(REG_MODEM_CONFIG_1).await;
        self.write_register(REG_MODEM_CONFIG_1, (reg_modem_config_1_val & 0xf1) | (cr << 1) as u8).await;

        Ok(())
    }

    async fn set_preamble_length(&mut self, length: u16) {
        self.write_register(REG_PREAMBLE_MSB, (length >> 8) as u8).await;
        self.write_register(REG_PREAMBLE_LSB, (length >> 0) as u8).await;
    }

    async fn set_sync_word(&mut self, sw: u8) {
        self.write_register(REG_SYNC_WORD, sw).await;
    }

    async fn enable_crc(&mut self) {
        let reg_modem_config_2_val = self.read_register(REG_MODEM_CONFIG_2).await;
        self.write_register(REG_MODEM_CONFIG_2, reg_modem_config_2_val | 0x04).await;
    }

    async fn disable_crc(&mut self) {
        let reg_modem_config_2_val = self.read_register(REG_MODEM_CONFIG_2).await;
        self.write_register(REG_MODEM_CONFIG_2, reg_modem_config_2_val & 0xfb).await;
    }

    async fn enable_invert_iq(&mut self) {
        self.write_register(REG_INVERTIQ,  0x66).await;
        self.write_register(REG_INVERTIQ2, 0x19).await;
    }

    async fn disable_invert_iq(&mut self) {
        self.write_register(REG_INVERTIQ,  0x27).await;
        self.write_register(REG_INVERTIQ2, 0x1d).await;
    }

    async fn enable_low_data_rate_optimize(&mut self) {
        self.set_ldo_flag_forced(true).await;
    }

    async fn disable_low_data_rate_optimize(&mut self) {
        self.set_ldo_flag_forced(false).await;
    }

    async fn set_ocp(&mut self, milliamps: u8) {
        let mut ocp_trim = 27u8;

        if milliamps <= 120 {
            ocp_trim = milliamps - 45 / 5;
        } else if milliamps <= 240 {
            ocp_trim = (milliamps + 30) / 10;
        }

        self.write_register(REG_OCP, 0x20 | (0x1F & ocp_trim)).await;
    }

    async fn set_gain(&mut self, gain: u8) -> Result<(), ()> {
        // check allowed range
        if gain > 6 {
            return Err(());
        }
        
        // set to standby
        self.idle().await;
        
        // set gain
        if gain == 0 {
            // if gain = 0, enable AGC
            self.write_register(REG_MODEM_CONFIG_3, 0x04).await;
        } else {
            // disable AGC
            self.write_register(REG_MODEM_CONFIG_3, 0x00).await;
            
            // clear Gain and set LNA boost
            self.write_register(REG_LNA, 0x03).await;
            
            // set gain
            let reg_lna_val = self.read_register(REG_LNA).await;
            self.write_register(REG_LNA, reg_lna_val | (gain << 5)).await;
        }

        return Ok(());
    }

    async fn dump_registers(&mut self) {
        for i in 0..128 {
            println!("0x{:X}: 0x{:X}", i, self.read_register(i).await);
        }
    }

    async fn explicit_header_mode(&mut self)
    {
        self._implicit_header_mode = false;
        let reg_modem_config_1_val = self.read_register(REG_MODEM_CONFIG_1).await;
        self.write_register(REG_MODEM_CONFIG_1, reg_modem_config_1_val & 0xfe).await;
    }

    async fn implicit_header_mode(&mut self)
    {
        self._implicit_header_mode = true;
        let reg_modem_config_1_val = self.read_register(REG_MODEM_CONFIG_1).await;
        self.write_register(REG_MODEM_CONFIG_1, reg_modem_config_1_val | 0x01).await;
    }

    // void LoRaClass::handleDio0Rise()
    // {
    //     int irqFlags = readRegister(REG_IRQ_FLAGS);

    //     // clear IRQ's
    //     writeRegister(REG_IRQ_FLAGS, irqFlags);

    //     if ((irqFlags & IRQ_CAD_DONE_MASK) != 0) {
    //         if (_onCadDone) {
    //         _onCadDone((irqFlags & IRQ_CAD_DETECTED_MASK) != 0);
    //         }
    //     } else if ((irqFlags & IRQ_PAYLOAD_CRC_ERROR_MASK) == 0) {

    //         if ((irqFlags & IRQ_RX_DONE_MASK) != 0) {
    //         // received a packet
    //         _packetIndex = 0;

    //         // read packet length
    //         int packetLength = _implicitHeaderMode ? readRegister(REG_PAYLOAD_LENGTH) : readRegister(REG_RX_NB_BYTES);

    //         // set FIFO address to current RX address
    //         writeRegister(REG_FIFO_ADDR_PTR, readRegister(REG_FIFO_RX_CURRENT_ADDR));

    //         if (_onReceive) {
    //             _onReceive(packetLength);
    //         }
    //         } else if ((irqFlags & IRQ_TX_DONE_MASK) != 0) {
    //         if (_onTxDone) {
    //             _onTxDone();
    //         }
    //         }
    //     }
    // }

    async fn read_register(&mut self, address: u8) -> u8 {
        return self.single_transfer(address & 0x7f, 0x00).await;
    }

    async fn write_register(&mut self, address: u8, value: u8) {
        self.single_transfer(address | 0x80, value).await;
    }

    async fn single_transfer(&mut self, address: u8, value: u8) -> u8 {
        let mut response = [value];

        self.cs.set_low();
        self.spi.blocking_transfer_in_place(&mut [address]);
        self.spi.blocking_transfer_in_place(&mut response);
        self.cs.set_high();

        return response[0];
    }

    // ISR_PREFIX void LoRaClass::onDio0Rise()
    // {
    // LoRa.handleDio0Rise();
    // }

    // LoRaClass LoRa;

}
