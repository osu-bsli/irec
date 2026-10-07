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

pub const Camera = struct {
    pos: zm.Vec,
    front: zm.Vec = .{ 0.0, 0.0, 1.0, 0.0 },
    up: zm.Vec = .{ 0.0, 1.0, 0.0, 0.0 },

    is_using_mouse: bool = false,
    yaw: f32 = 0.0,
    pitch: f32 = 0.0,

    pub fn setPos(self: *Camera, pos_x: f32, pos_y: f32, pos_z: f32) void {
        self.pos = zm.f32x3(pos_x, pos_y, pos_z);
    }

    pub fn move(self: *Camera, direction: MOVE_DIR, value: f32) void {
        const v = zm.f32x4s(value);

        var result: zm.Vec = zm.f32x4(0.0, 0.0, 0.0, 0.0);

        if (direction == MOVE_DIR.MOVE_UP or direction == MOVE_DIR.MOVE_DOWN) {
            result = self.*.up * v;
        } else if (direction == MOVE_DIR.MOVE_FORWARD or direction == MOVE_DIR.MOVE_BACKWARD) {
            // Zero out the Y component for horizontal-only forward movement
            const forward_dir = zm.f32x4(self.*.front[0], 0.0, self.*.front[2], 0.0);
            result = zm.normalize3(forward_dir) * v;
        } else if (direction == MOVE_DIR.MOVE_LEFT or direction == MOVE_DIR.MOVE_RIGHT) {
            const right_dir = zm.cross3(self.*.front, self.*.up);
            result = zm.normalize3(right_dir) * v;
        }

        if (direction == MOVE_DIR.MOVE_UP or direction == MOVE_DIR.MOVE_RIGHT or direction == MOVE_DIR.MOVE_FORWARD) {
            self.*.pos += result;
        } else if (direction == MOVE_DIR.MOVE_DOWN or direction == MOVE_DIR.MOVE_LEFT or direction == MOVE_DIR.MOVE_BACKWARD) {
            self.*.pos -= result;
        }
        return;
    }

    pub fn enable_mouse_looking(self: *Camera, value: bool) void {
        self.*.is_using_mouse = value;
        return;
    }
};
