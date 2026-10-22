const std = @import("std");
const Io = std.Io;
const microzig = @import("microzig");
const rp = microzig.hal;
const time = rp.time;

// const uart = rp.uart.instance.num(0);
// const uart_tx_pin = rp.gpio.num(0);

// pub const std_options

// pub const std_options = microzig.std_options(.{
//     .log_level = .debug,
//     .logFn = rp.uart.log,
// });

comptime {
    _ = microzig.export_startup();
}

const pin_config = rp.pins.GlobalConfiguration{
    .GPIO25 = .{
        .name = "led",
        .direction = .out,
    },
};

const rtt = microzig.cpu.rtt;
const rtt_instance = rtt.RTT(.{});

var rtt_logger: ?rtt_instance.Writer = null;

// const log = std.log.scoped(.main);

pub fn main() !void {
    const pins = pin_config.apply();

    // uart_tx_pin.set_function(.uart);
    // uart.apply(.{
    // .clock_config = rp.clock_config,
    // });
    // rp.uart.init_logger(uart);

    rtt_instance.init();

    _ = rtt_instance.write(0, "Hello World!\n");

    while (true) {
        // std.log.err("Hello World ", .{});
        _ = rtt_instance.write(0, "Hello World!\n");
        try rtt_logger.?.interface.flush();
        pins.led.toggle();
        time.sleep_ms(250);
    }
}
