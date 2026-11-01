//function that takes in software buffer byte
//size and which hardware serial buffer, 0 or 1
pub fn set_FIFO(byte_size: u8, hw_buffer: u8) !void {}

//begins the serial communication for the
//hw buffer w/ input baud rate
pub fn serial_begin(hw_buffer: u8, baud_rate: u32) !void {}

//assign input pin to rx using microzig
pub fn set_Rx(wire_num: u8) !void {}

//assign input pin to tx using microzig
pub fn set_Tx(wire_num: u8) !void {}
