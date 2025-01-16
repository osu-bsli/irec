use std::{
    io::Read, sync::mpsc, time::Duration
};

use serialport::SerialPortInfo;

#[derive(Clone, PartialEq)]
pub enum Status {
    Disconnected,
    Connecting,
    Connected,
    Disconnecting,
    Failed,
}

#[derive(Clone, PartialEq)]
pub struct ConnectionSettings {
    port_name: String,
}

#[derive(PartialEq)]
pub enum Control {
    Connect(ConnectionSettings),
    Disconnect,
}

pub struct SerialConnection {
    data_rx: mpsc::Receiver<u8>,
    control_tx: mpsc::Sender<Control>,
    status_rx: mpsc::Receiver<Status>,

    // pub port: Option<Box<dyn SerialPort>>, // boxed because dyn SerialPort is unsized but Option requires a sized type
    pub known_ports: Vec<SerialPortInfo>,
    pub selected_port: String, // the name of the port selected in the ui, "" if not connected
    pub baud_rate: u32,
    pub data_bits: serialport::DataBits,
    pub parity: serialport::Parity,
    pub stop_bits: serialport::StopBits,
    // ^ None if disconnected
    status: Status,
    bytes_read: u32,
}

impl SerialConnection {
    pub fn new() -> Self {
        let (data_tx, data_rx) = mpsc::channel();
        let (status_tx, status_rx) = mpsc::channel();
        let (control_tx, control_rx) = mpsc::channel();

        std::thread::spawn(move || {
            println!("Serial port thread started.");

            let update_status = |status: Status| {
                status_tx.send(status).unwrap();
            };

            // TODO: serial port settings for data bits, parity, stop bits, baud rate, etc.
            loop {
                // wait for connection settings message
                let c: Control = control_rx.recv().unwrap();

                if let Control::Connect(connection_settings) = c {
                    let port_name = connection_settings.port_name;
                    println!("Connecting to serial port {:?}...", port_name);
                    update_status(Status::Connecting);

                    let port = serialport::new(port_name.clone(), 9600)
                        .timeout(Duration::from_millis(100))
                        .open();

                    if let Ok(mut port) = port {
                        println!("Connected to serial port {}.", port_name);
                        update_status(Status::Connected);

                        loop {
                            let mut buf = [0u8; 1024];
                            if let Ok(data_size) = port.read(buf.as_mut_slice()) {
                                for i in 0..data_size {
                                    data_tx.send(buf[i]).unwrap();
                                }
                            }

                            if let Ok(c) = control_rx.try_recv() {
                                if c == Control::Disconnect {
                                    println!("Disconnecting from serial port {}...", port_name);
                                    update_status(Status::Disconnecting);
                                    
                                    break;
                                } else {
                                    panic!();
                                }
                            }
                        }

                        std::mem::drop(port);

                        println!("Disconnected from serial port {}!", port_name);
                        update_status(Status::Disconnected);
                    } else if let Err(err) = port {
                        println!("Failed to connect to serial port {}: {}", port_name, err);
                        update_status(Status::Failed);
                    }
                } else {
                    panic!();
                }
            }
        });

        Self {
            data_rx: data_rx,
            control_tx: control_tx,
            status_rx: status_rx,
            status: Status::Disconnected,
            known_ports: Vec::new(),
            selected_port: "".to_string(),
            baud_rate: 9600,
            data_bits: serialport::DataBits::Eight,
            parity: serialport::Parity::None,
            stop_bits: serialport::StopBits::One,
            bytes_read: 0
        }
    }

    pub fn read_byte(&mut self) -> Result<u8, mpsc::TryRecvError> {
        let recv = self.data_rx.try_recv();
        if let Ok(_) = recv {
            self.bytes_read += 1;
        }
        recv
    }

    pub fn bytes_read(&self) -> u32 {
        self.bytes_read
    }

    pub fn connect(&mut self, port_name: String) {
        self.control_tx
            .send(Control::Connect(ConnectionSettings { port_name }))
            .unwrap();
    }

    pub fn refresh_known_ports(&mut self) {
        self.known_ports = serialport::available_ports().unwrap_or(Vec::new());
    }

    pub fn disconnect(&mut self) {
        self.control_tx.send(Control::Disconnect).unwrap();
    }

    pub fn connection_allowed(&self) -> bool {
        self.status == Status::Disconnected 
        || self.status == Status::Failed
    }

    pub fn disconnection_allowed(&self) -> bool {
        self.status == Status::Connected
    }

    pub fn connection_status(&mut self) -> Status {
        loop {
            let status = self.status_rx.try_recv();
            if let Ok(status) = status {
                self.status = status;
            } else {
                break;
            }
        }

        self.status.clone()
    }
}
