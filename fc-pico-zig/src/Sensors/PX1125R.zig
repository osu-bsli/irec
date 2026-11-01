pub const wire = @import("wire.zig");
pub const serial = @import("serial.zig");

//Initialize
pub fn GPS_Init() !void {
    const tx = set_Tx(16); //assign pin 16 to tx
    const rx = set_Rx(17); //assign pin 17 to rx
    set_FIFO(1024, 1); //software_buffer is 1024 bytes, assigned to HW serial 1
    serial_begin(1, 115200); //tell serial 1 to begin at 115200 baud
}

//transports data from software_buffer -> FDIR struct
pub fn GPS_Buffer_To_Storage(Data: *GNC_Data)
