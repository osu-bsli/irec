use embassy_rp::uart::BufferedUart;
use embassy_rp::uart::BufferedInterruptHandler;
use embassy_rp::uart::Config;
use embassy_rp::peripherals::{UART0, PIN_0, PIN_1};
use embassy_rp::Peri;
use embassy_rp::bind_interrupts;
use static_cell::StaticCell;
use crate::data::PX1125R_NMEA_Packet;

const MAX_BUFFER_SIZE: usize = 1024;
const MAX_GPS_MESSAGE_SIZE: usize = 256;

pub struct Gps<'a> {
    pub uart: BufferedUart<'a>,
}

impl<'a> Gps<'a> {

    //This function initializes the software uart buffer, and automatically stores HW buffer data to software buffer using a hardware interrupt
    pub async fn initialize_gps(p_hw_uart: Peri<'static, UART0>, p_tx: Peri<'static, PIN_0>, p_rx: Peri<'static, PIN_1>) -> Self {
        //bind interrupt for gps, so hardware buffer interrupts pico, tells it to read data to software
        bind_interrupts!(struct Irqs {
            UART0_IRQ => BufferedInterruptHandler<UART0>;
        });

        //define tx software buffer, max size is max buffer size.
        //Don't think were writing to the GPS, but if we do, its ready
        static TX_BUF: StaticCell<[u8; MAX_BUFFER_SIZE]> = StaticCell::new();
        let tx_buf = &mut TX_BUF.init([0; MAX_BUFFER_SIZE])[..];

        //define rx software buffer, max size is max buffer size.
        static RX_BUF: StaticCell<[u8; MAX_BUFFER_SIZE]> = StaticCell::new();
        let rx_buf = &mut RX_BUF.init([0; MAX_BUFFER_SIZE])[..];

        //finally, initialize the uart connection with all definitions.
        let uart = BufferedUart::new(p_hw_uart, p_tx, p_rx, Irqs, tx_buf, rx_buf, Config::default());
        Self {uart}
    }

    //this function reads from the software buffer and finds gps messages. Can't assume there are < 1 message in the queue, so we check bit by bit.
    pub async fn read_gps(&mut self, data: &mut PX1125R_NMEA_Packet) {
        //message buffer, capped at MAX_GPS_MESSAGE_SIZE
        let mut message = [0; MAX_GPS_MESSAGE_SIZE];

        //total number of stored bytes, for storing size of message.
        let mut total_bytes: u8 = 0;

        //1 byte buffer
        let mut buf = [0; 1];
        loop{
            //This function reads a byte from the created buffer, stores it in buf, 
            //and outputs the # of bytes(1), which is added to a total
            total_bytes = total_bytes + (self.uart.read(&mut buf).await.unwrap()) as u8;
            
            //NMEA messages start with $ and end with \r\n
            //check to see if the current message has a starting character of $, and ending characters of \r\n, denoting a complete NMEA message
            //we can easily find the start and end of the message using that # of stored bytes.
            if (message[0] ==  b'$' && message[total_bytes as usize - 1] == b'\r' && message[total_bytes as usize] == b'\n') {
            
                //if it is a full message, send to unprocessed_messages struct and reset byte count
                data.push_back(message);
                total_bytes = 0;
            
            }
        }
    }
}