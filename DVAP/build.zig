const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dvap = b.addExecutable(.{
        .name = "DVAP",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    const zmath = b.dependency("zmath", .{});
    dvap.root_module.addImport("zmath", zmath.module("root"));

    dvap.root_module.addIncludePath(b.path("lib/"));

    dvap.root_module.addCSourceFiles(.{
        .files = &.{
            "lib/GLAD/src/gl.c",
        },
    });

    dvap.root_module.addIncludePath(b.path("lib/GLAD/include/"));
    dvap.root_module.addIncludePath(b.path("lib/GLFW/include/"));
    dvap.root_module.addIncludePath(b.path("lib/GLFW/src/"));

    if (target.result.os.tag == .windows) {
        dvap.root_module.linkSystemLibrary("gdi32", .{});
        dvap.root_module.linkSystemLibrary("user32", .{});
        dvap.root_module.linkSystemLibrary("shell32", .{});

        dvap.root_module.addCSourceFiles(.{
            .files = &.{
                "lib/GLFW/src/platform.c",
                "lib/GLFW/src/monitor.c",
                "lib/GLFW/src/init.c",
                "lib/GLFW/src/vulkan.c",
                "lib/GLFW/src/input.c",
                "lib/GLFW/src/context.c",
                "lib/GLFW/src/window.c",
                "lib/GLFW/src/osmesa_context.c",
                "lib/GLFW/src/egl_context.c",
                "lib/GLFW/src/wgl_context.c",
                "lib/GLFW/src/null_init.c",
                "lib/GLFW/src/null_joystick.c",
                "lib/GLFW/src/null_monitor.c",
                "lib/GLFW/src/null_window.c",

                "lib/GLFW/src/win32_thread.c",
                "lib/GLFW/src/win32_init.c",
                "lib/GLFW/src/win32_monitor.c",
                "lib/GLFW/src/win32_time.c",
                "lib/GLFW/src/win32_joystick.c",
                "lib/GLFW/src/win32_window.c",
                "lib/GLFW/src/win32_module.c",
            },
            .flags = &.{"-D_GLFW_WIN32"},
        });
    } else {
        dvap.root_module.addCSourceFiles(.{
            .files = &.{
                "lib/GLFW/src/context.c",
                "lib/GLFW/src/egl_context.c",
                "lib/GLFW/src/glx_context.c",
                "lib/GLFW/src/init.c",
                "lib/GLFW/src/input.c",
                "lib/GLFW/src/window.c",
                "lib/GLFW/src/wgl_context.c",
                "lib/GLFW/src/monitor.c",
                "lib/GLFW/src/nsgl_context.m",
                "lib/GLFW/src/null_init.c",
                "lib/GLFW/src/null_joystick.c",
                "lib/GLFW/src/null_monitor.c",
                "lib/GLFW/src/null_window.c",
                "lib/GLFW/src/osmesa_context.c",
                "lib/GLFW/src/platform.c",
                "lib/GLFW/src/vulkan.c",

                // "lib/GLFW/src/posix_time.h",
                // "lib/GLFW/src/wl_platform.h",
                // "lib/GLFW/src/x11_platform.h",
                "lib/GLFW/src/wl_init.c",
                "lib/GLFW/src/wl_monitor.c",
                "lib/GLFW/src/wl_window.c",
                "lib/GLFW/src/x11_init.c",
                "lib/GLFW/src/x11_monitor.c",
                "lib/GLFW/src/x11_window.c",
                "lib/GLFW/src/xkb_unicode.c",
                "lib/GLFW/src/linux_joystick.c",
                "lib/GLFW/src/posix_module.c",
                "lib/GLFW/src/posix_poll.c",
                "lib/GLFW/src/posix_thread.c",
                "lib/GLFW/src/posix_time.c",
            },
            .flags = &.{
                // "-D_GLFW_WAYLAND",
                "-D_GLFW_X11",
            },
        });
    }

    // example_c_mod.addCSourceFiles(.{
    //     .files = &.{
    //         "lib/example.c",
    //         "lib/example2.c",
    //     },
    //     .flags = &.{""},
    // });

    // dvap.root_module.addImport("example", example_c_mod);

    // Build and Run step

    b.installArtifact(dvap);

    const run_step = b.step("run", "Run the app");

    const run_cmd = b.addRunArtifact(dvap);
    run_step.dependOn(&run_cmd.step);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // Tests

    const dvap_tests = b.addTest(.{
        .root_module = dvap.root_module,
    });

    const run_exe_tests = b.addRunArtifact(dvap_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_exe_tests.step);
}
