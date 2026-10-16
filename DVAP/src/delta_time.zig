const std = @import("std");
const c_libs = @import("clibs.zig");
const glfw = c_libs.glfw;

pub var delta_time: f32 = 0.0;
var last_time_check: f32 = 0.0;

pub fn updateDeltaTime() void {
    const current_time_check: f32 = @floatCast(glfw.glfwGetTime()); // convert the f64 into f32
    delta_time = current_time_check - last_time_check; // Change of time between frames
    last_time_check = current_time_check; // Update the last time check
}

var last_fps_time_check = 0.0;
pub fn calcFPS() void {
    // Caclulate FPS from delta time
    // Try to print to console every second
    // prints every second as to not bloat up the console

    const current_fps_time_check: f32 = @floatCast(glfw.glfwGetTime());
    if (current_fps_time_check - last_fps_time_check >= 1.0) {
        std.debug.print("FPS: {}", .{1 / delta_time});
        last_fps_time_check = current_fps_time_check;
    }
}
