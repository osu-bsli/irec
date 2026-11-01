const std = @import("std");
const microzig = @import("microzig");

const MicroBuild = microzig.MicroBuild(.{
    .rp2xxx = true,
});

const optimize = std.lang.Optimize.ReleaseSmall;

pub fn build(b: *std.Build) void {
    const mz_dep = b.dependency("microzig", .{});
    const mb = MicroBuild.init(b, mz_dep) orelse return;

    const firmware = mb.add_firmware(.{
        .name = "blinky",
        .target = mb.ports.rp2xxx.boards.raspberrypi.pico2_arm,
        .optimize = optimize,
        .root_source_file = b.path("src/main.zig"),
    });

    const Translator = @import("translate_c").Translator;
    const translate_c = b.dependency("translate_c", .{});

    const target = b.resolveTargetQuery(firmware.target.zig_target);

    const t: Translator = .init(translate_c, .{
        .c_source_file = b.path("to_translate.h"),
        .target = target,
        // This is the optimization mode of the C code being translated and
        // the resulting Zig code.
        .optimize = optimize,
        .link_libc = false, // no libc for freestanding target
        // more options go here (see below)
    });

    const freertos_mod = b.addModule("freertos", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{
                .name = "c",
                .module = t.mod,
            },
        },
    });

    firmware.exe.root_module.addImport("freertos", freertos_mod);

    // We call this twice to demonstrate that the default binary output for
    // RP2040 is UF2, but we can also output other formats easily
    mb.install_firmware(firmware, .{});
    mb.install_firmware(firmware, .{ .format = .elf });
}
