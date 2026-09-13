// pub const glfw = @cImport({
// @cInclude("lib/GLAD/include/glad/gl.h");
// });
const builtin = @import("builtin");

pub const e = @cImport({
    @cInclude("example.c");
    @cInclude("example2.c");
});

pub const gl = @cImport({
    @cInclude("glad/gl.h");
});

pub const glfw = @cImport({
    // if (builtin.os.tag == .windows) {
    // @cInclude("stdbool.h");
    // @cInclude("stdint.h");
    @cInclude("windef.h");
    // }
    @cInclude("GLFW/glfw3.h");
});
