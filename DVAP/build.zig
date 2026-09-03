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
        }),
    });

    // Compile, include, and link GLAD for OpenGL functions
    const glad_c_translate = b.addTranslateC(.{
        .link_libc = true,
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("lib/GLAD/include/glad/gl.h"),
    });

    const glad_mod = glad_c_translate.createModule();

    glad_mod.addIncludePath(b.path("lib/GLAD/include/"));

    glad_mod.addCSourceFiles(.{
        .files = &.{
            "lib/GLAD/src/gl.c",
        },
        .flags = &.{""},
    });

    dvap.root_module.addImport("glad", glad_mod);

    // Compile, include, and link GLFW
    const glfw_c_translate = b.addTranslateC(.{
        .link_libc = true,
        .optimize = optimize,
        .target = target,
        .root_source_file = b.path("lib/GLFW/include/GLFW/glfw3.h"),
    });

    glfw_c_translate.addIncludePath(b.path("lib/GLFW/include/"));
    glfw_c_translate.addIncludePath(b.path("lib/GLFW/src/"));

    const glfw_mod = glfw_c_translate.createModule();

    glfw_mod.addIncludePath(b.path("lib/GLFW/include/"));
    glfw_mod.addIncludePath(b.path("lib/GLFW/src/"));

    if (target.result.os.tag == .windows) {
        glfw_mod.addCSourceFiles(.{
            .files = &.{
                // "lib/GLFW/src/internal.h",
                // "lib/GLFW/src/mappings.h",
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
            },
        });

        glfw_mod.addCSourceFiles(.{
            .files = &.{
                // "lib/GLFW/src/cocoa_joystick.h",
                // "lib/GLFW/src/cocoa_platform.h",
                // "lib/GLFW/src/linux_joystick.h",
                // "lib/GLFW/src/macos_time.h",
                // "lib/GLFW/src/null_joystick.h",
                // "lib/GLFW/src/null_platform.h",
                // "lib/GLFW/src/platform.h",
                // "lib/GLFW/src/posix_poll.h",
                // "lib/GLFW/src/posix_thread.h",
                // "lib/GLFW/src/win32_joystick.h",
                // "lib/GLFW/src/win32_platform.h",
                // "lib/GLFW/src/win32_thread.h",

                // "lib/GLFW/src/cocoa_init.m",
                // "lib/GLFW/src/cocoa_joystick.m",
                // "lib/GLFW/src/cocoa_monitor.m",
                // "lib/GLFW/src/cocoa_window.m",

                // "lib/GLFW/src/glfw.rc.in",

                // "lib/GLFW/src/macos_time.c",

                // "lib/GLFW/src/mappings.h.in",

                "lib/GLFW/src/win32_init.c",

                "lib/GLFW/src/win32_joystick.c",
                "lib/GLFW/src/win32_module.c",
                "lib/GLFW/src/win32_monitor.c",
                "lib/GLFW/src/win32_thread.c",
                "lib/GLFW/src/win32_time.h",
                "lib/GLFW/src/win32_time.c",
                "lib/GLFW/src/win32_window.c",
            },
            .flags = &.{"-D_GLFW_WIN32"},
        });
    } else {
        glfw_mod.addCSourceFiles(.{
            .files = &.{
                // "lib/GLFW/src/internal.h",
                // "lib/GLFW/src/mappings.h",
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
            },
            .flags = &.{
                // "-D_GLFW_WAYLAND",
                "-D_GLFW_X11",
            },
        });

        glfw_mod.addCSourceFiles(.{
            .files = &.{
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

    dvap.root_module.addImport("glfw", glfw_mod);

    // Local C examples compiled and included in the executable
    const example_c_translate = b.addTranslateC(.{
        .link_libc = true,
        .optimize = optimize,
        .root_source_file = b.path("lib/example.h"),
        .target = target,
    });
    const example_c_mod = example_c_translate.createModule();

    example_c_mod.addCSourceFiles(.{
        .files = &.{
            "lib/example.c",
            "lib/example2.c",
        },
        .flags = &.{""},
    });

    dvap.root_module.addImport("example", example_c_mod);

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
