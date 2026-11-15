#![no_std]
#![no_main]

//mod gps and the data struct files
mod gps;
mod data;

//Use the Data struct 
use data::Data;
use defmt_rtt as _;
use embassy_executor::Spawner;
use panic_probe as _;

//main function
#[embassy_executor::main(executor = "embassy_rp::executor::Executor", entry = "cortex_m_rt::entry")]
async fn main(spawner: Spawner) {
    //create peripherals
    let p = embassy_rp::init(Default::default());
    //create data pipeline struct
    let pico_data: data::Data;
    //initialize the gps
    let gps_new = gps::Gps::initialize_gps(p.UART0, p.PIN_0, p.PIN_1);  
    //demonstrate how to read the gps.  
    gps_new.read_gps(gps_new, &pico_data.unprocessed.px1125r);
}
