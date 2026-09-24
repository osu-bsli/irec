const std = @import("std");
const zm = @import("zmath");

const c_libs = @import("clibs.zig");
const gl = c_libs.gl;
const glfw = c_libs.glfw;

const MOVE_DIR = enum {
    MOVE_FORWARD,
    MOVE_BACKWARD,
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DOWN,
};

pub const Camera: type = struct {
    var is_using_mouse: bool = false;
    var pos: zm.f32x3 = undefined;

    pub fn init() void {
        return;
    }

    pub fn move() void {
        return;
    }

    pub fn enable_mouse_looking() void {
        return;
    }
};
