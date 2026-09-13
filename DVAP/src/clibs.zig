// pub const glfw = @cImport({
// @cInclude("lib/GLAD/include/glad/gl.h");
// });

pub const e = @cImport({
    @cInclude("example.c");
    @cInclude("example2.c");
});

pub const gl = @cImport({
    @cInclude("glad/gl.h");
});

pub const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});
