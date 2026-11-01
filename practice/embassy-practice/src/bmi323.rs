use embassy_rp::{
    i2c::I2c,
    mode::{Async, Mode},
};

pub struct Bmi323<'a> {
    i2c: I2c<'a, Async>,
}

impl Bmi323<'_> {
    const I2C_ADDR: u8 = 0x68;
    const CHIP_ID: u8 = 0x43;
    const REG_ADDR_ID: u8 = 0x00;
    pub async fn init(mut i2c: I2c<'_, Async>) -> Option<Bmi323<'_>> {
        let reg_addr = [Self::REG_ADDR_ID];
        if i2c.write(Self::I2C_ADDR, &reg_addr).await.is_err() {
            return None;
        }
        
        let mut buf = [0u8; 4]; // 2 dummy bytes, 
        if i2c.read(Self::I2C_ADDR, &mut buf).await.is_err() {
            return None;
        }
        if buf[2] != Self::CHIP_ID {
            return None;
        }

        Some(Bmi323 { i2c })
    }
}
