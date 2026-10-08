const std = @import("std");
const Io = std.Io;
const microzig = @import("microzig");
const rp = microzig.hal;
const time = rp.time;

// const fc_pico_zig = @import("fc_pico_zig");

comptime {
    _ = microzig.export_startup();
}

const pin_config = rp.pins.GlobalConfiguration{
    .GPIO25 = .{
        .name = "led",
        .direction = .out,
    },
};

pub fn main() !void {
    const pins = pin_config.apply();

    while (true) {
        pins.led.toggle();
        time.sleep_ms(250);
    }
}
