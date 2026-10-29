const std = @import("std");
const Io = std.Io;
const microzig = @import("microzig");
const rp = microzig.hal;
const time = rp.time;

// const uart = rp.uart.instance.num(0);
// const uart_tx_pin = rp.gpio.num(0);

// pub const std_options

// Replaces the zig standard library's log function with our custom one to RTT
pub const std_options = microzig.std_options(.{
    .log_level = .debug,
    .logFn = log,
});

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    const level_prefix = comptime "[{}.{:0>6}] " ++ level.asText();
    const prefix = comptime level_prefix ++ switch (scope) {
        .default => ": ",
        else => " (" ++ @tagName(scope) ++ "): ",
    };
    if (rtt_logger) |*writer| {
        const current_time = time.get_time_since_boot();
        const seconds = current_time.to_us() / std.time.us_per_s;
        const microseconds = current_time.to_us() % std.time.us_per_s;
        writer.interface.print(prefix ++ format ++ "\r\n", .{ seconds, microseconds } ++ args) catch {};
        // Don't forget to flush! This never returns an error with how the Writer interface is implemented
        // so unreachable is appropriate here.
        writer.interface.flush() catch unreachable;
    }
}

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

pub export fn main() void {
    const pins = pin_config.apply();

    // uart_tx_pin.set_function(.uart);
    // uart.apply(.{
    // .clock_config = rp.clock_config,
    // });
    // rp.uart.init_logger(uart);

    rtt_instance.init();

    // _ = rtt_instance.write(0, "Hello World!\n");

    // rtt_logger = rtt_instance.writer(0, &.{});

    // std.log.info("Hello World\n", .{});

    while (true) {
        log(.info, .default, "Hello World!\n", .{});
        // _ = rtt_instance.write(0, "Hello World!\n");
        // std.log.err("Hello World ", .{});
        // _ = rtt_instance.write(0, "Hello World!\n");
        // try rtt_logger.?.interface.flush();
        pins.led.toggle();
        time.sleep_ms(500);
    }
}
