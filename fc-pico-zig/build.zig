const std = @import("std");
const microzig = @import("microzig");

const MicroBuild = microzig.MicroBuild(.{
    .rp2xxx = true,
});

pub fn build(b: *std.Build) void {
    const mz_dependency = b.dependency("microzig", .{});
    const micro_build = MicroBuild.init(b, mz_dependency) orelse return;

    const firmware = micro_build.add_firmware(.{
        .name = "fc_pico",
        .target = micro_build.ports.rp2xxx.boards.raspberrypi.pico2_arm,
        .optimize = .ReleaseSmall,
        .root_source_file = b.path("src/main.zig"),
    });

    micro_build.install_firmware(firmware, .{});

    // const mod_tests = b.addTest(.{
    //     .root_module = mod,
    // });

    // const run_mod_tests = b.addRunArtifact(mod_tests);

    // const exe_tests = b.addTest(.{
    // .root_module = exe.root_module,
    // });

    // const run_exe_tests = b.addRunArtifact(exe_tests);

    // const test_step = b.step("test", "Run tests");
    // test_step.dependOn(&run_mod_tests.step);
    // test_step.dependOn(&run_exe_tests.step);
}
