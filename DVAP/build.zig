const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const mod = b.addModule("DVAP", .{
    // .root_source_file = b.path("src/root.zig"),
    // .target = target,
    // });

    const exe = b.addExecutable(.{
        .name = "DVAP",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            // .imports = &.{
            // .{ .name = "DVAP", .module = mod },
            // },
        }),
    });

    const example_c_translate = b.addTranslateC(.{
        .link_libc = true,
        .optimize = optimize,
        .root_source_file = b.path("lib/example.c"),
        .target = target,
    });
    const example_c_mod = example_c_translate.createModule();

    exe.root_module.addImport("example", example_c_mod);
    example_c_mod.addCSourceFiles(.{
        .files = &.{
            "lib/example2.c",
        },
        .flags = &.{""},
    });

    b.installArtifact(exe);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // const mod_tests = b.addTest(.{
    // .root_module = mod,
    // });

    // const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run tests");
    // test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);
}
