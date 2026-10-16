const std = @import("std");
const zm = @import("zmath");

const c_libs = @import("clibs.zig");
const gl = c_libs.gl;
const glfw = c_libs.glfw;

pub const MOVE_DIR = enum {
    MOVE_FORWARD,
    MOVE_BACKWARD,
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DOWN,
};

pub const Camera = struct {
    pos: zm.Vec = .{ 0.0, 0.0, 5.0, 1.0 },
    front: zm.Vec = .{ 0.0, 0.0, -1.0, 0.0 },
    up: zm.Vec = .{ 0.0, 1.0, 0.0, 0.0 },

    is_using_mouse: bool = false,
    yaw: f64 = -90.0,
    pitch: f64 = 0.0,

    view: zm.Mat = zm.identity(),
    projection: zm.Mat = zm.identity(),

    pub fn setPos(self: *Camera, pos_x: f32, pos_y: f32, pos_z: f32) void {
        self.pos = zm.f32x4(pos_x, pos_y, pos_z, 1.0);
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

    pub fn enableMouseLooking(self: *Camera, value: bool) void {
        self.*.is_using_mouse = value;
        return;
    }

    pub fn updateView(self: *Camera) void {
        self.view = zm.lookAtRh(
            self.pos,
            self.pos + self.front,
            self.up,
        );
    }

    pub fn updateProjection(self: *Camera, fov: f32, aspect_ratio: f32, near_clip_plane: f32, far_clip_plane: f32) void {
        // Use `perspectiveFovRhGl` for OpenGL [-1, 1] clip space
        self.projection = zm.perspectiveFovRhGl(
            fov,
            aspect_ratio,
            near_clip_plane,
            far_clip_plane,
        );
    }
};
