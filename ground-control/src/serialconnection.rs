use std::{io::BufReader, time::Duration};

use log::{debug, info, error};

use serialport::{SerialPort, Error, DataBits, Parity, StopBits};

pub struct SerialConnection {
    pub reader: Option<BufReader<Box<dyn SerialPort>>>, // boxed because dyn SerialPort is unsized but Option requires a sized type
    // ^ None if disconnected
}

impl SerialConnection {
    pub fn new() -> Self {
        Self {
            reader: None,
        }
    }

    pub fn connect(&mut self, port: String, baudrate: u32, databits: DataBits, parity: Parity, stopbits: StopBits, timeout_ms: u64) -> Result<(), Error> {

        self.disconnect();

        match serialport::new(port, baudrate)
            .data_bits(databits)
            .parity(parity)
            .stop_bits(stopbits)
            .timeout(Duration::from_millis(timeout_ms))
            .open() {
                Ok(p) => {
                    self.reader = Some(BufReader::new(Box::from(p)));
                    Ok(())
                },
                Err(e) => Err(e),
            }
    }

    pub fn disconnect(&mut self) {
        // TODO: figure out how this is meant to be done
        self.reader = None;
    }

    pub fn isconnected(&self) -> bool {
        self.reader.is_some()
    }
}
