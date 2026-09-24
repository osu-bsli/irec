const std = @import("std");
const c_libs = @import("clibs.zig");
const gl = c_libs.gl;
const glfw = c_libs.glfw;
const Io = std.Io;
const zm = @import("zmath");

const rocket_verts = @import("rocket_vertices.zig");

const shader_lib = @import("shader.zig");
const camera_lib = @import("camera.zig");
// const gl = @import("glad");
// const glfw = @import("glfw");

// const DVAP = @import("DVAP");

const GraphicsContext = struct {
    window: *glfw.GLFWwindow = undefined,
};

const DVAPError = error{
    NullWindow,
    OpenGLLoadFailure,
};

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);
    for (args, 0..args.len) |arg, i| {
        std.log.info("arg: {s} {}", .{ arg, arg[i] });
    }

    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    var graphics_context = GraphicsContext{};

    // Init GLFW
    const c = if (glfw.glfwInit() == glfw.GLFW_TRUE) true else false;

    // What version of OpenGL is required
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 6);
    glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);

    const window_name = "DVAP";

    // Make window
    graphics_context.window = glfw.glfwCreateWindow(800, 600, &window_name.*, null, null) orelse return DVAPError.NullWindow;

    // Make the window the user's selected window
    glfw.glfwMakeContextCurrent(graphics_context.window);

    // Window resizing
    const set_frame_buffer_status = glfw.glfwSetFramebufferSizeCallback(graphics_context.window, framebufferSizeCallback);
    _ = &set_frame_buffer_status;
    // TODO add new Error type and return if unable to set framebuffer size

    // const a = c.e.chicken(0);
    // const b = c.e.amongus(0.003);

    // _ = &a;
    // _ = &b;
    _ = &window_name;

    // Attach OpenGL to the window
    const load_gl_status = gl.gladLoadGL(@as(gl.GLADloadfunc, glfw.glfwGetProcAddress));

    std.debug.print("from c: {} {} \n", .{
        // a,
        // b,
        c,
        load_gl_status,
    });

    if (load_gl_status == 0) {
        // TODO needs to be more specific
        return DVAPError.OpenGLLoadFailure;
    }

    gl.glViewport(0, 0, 800, 600);

    const shader = try shader_lib.Shader.init(
        @embedFile("vertex.glsl").* ++ "\x00",
        @embedFile("fragment.glsl").* ++ "\x00",
    );
    defer shader.cleanup();
    shader.use();

    // const verts = [_]f32{ // Placeholder Vertices -- should render a triangle w/ interpolated colors
    //     -0.5, -0.5, 0.0, 1.0, 0.0, 0.0,
    //     0.5,  -0.5, 0.0, 0.0, 1.0, 0.0,
    //     0.0,  0.5,  0.0, 0.0, 0.0, 1.0,
    // };
    const verts = rocket_verts.verts;

    // Make VBO and VAO
    var VAO: u32 = 0; // using u32 rather than unsigned int to ensure 32 bits
    var VBO: u32 = 0;

    // Gen and bind VAO
    gl.glGenVertexArrays(1, &VAO);
    gl.glBindVertexArray(VAO);

    // Make VBO
    gl.glGenBuffers(1, &VBO);
    gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO);
    gl.glBufferData(gl.GL_ARRAY_BUFFER, @sizeOf(f32) * verts.len, &verts, gl.GL_STATIC_DRAW);

    // Set XYZ vec3 in location = 0
    gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 6 * @sizeOf(f32), @ptrFromInt(0));
    gl.glEnableVertexAttribArray(0);
    // Set RGB vec3 in location = 1
    gl.glVertexAttribPointer(1, 3, gl.GL_FLOAT, gl.GL_FALSE, 6 * @sizeOf(f32), @ptrFromInt(3 * @sizeOf(f32)));
    gl.glEnableVertexAttribArray(1);

    gl.glEnable(gl.GL_DEPTH_TEST);

    while (glfw.glfwWindowShouldClose(graphics_context.window) != glfw.GLFW_TRUE) {
        gl.glClearColor(0.2, 0.3, 0.3, 1.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT);

        // Bind VBO and VAO
        gl.glBindVertexArray(VAO);
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO);

        gl.glDrawArrays(gl.GL_TRIANGLES, 0, verts.len / 6); // Divide by 6 because thats the number of floats per vertex

        glfw.glfwSwapBuffers(graphics_context.window);
        glfw.glfwPollEvents();
    }

    try stdout_writer.flush(); // Don't forget to flush!

    if (std.debug.runtime_safety == true) {
        glfw.glfwTerminate();
    }
}

pub export fn framebufferSizeCallback(window: ?*glfw.GLFWwindow, width: c_int, height: c_int) void {
    _ = &window;
    gl.glViewport(0, 0, width, height);
}

fn processInput(window: *glfw.GLFWwindow) void {
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) == glfw.GLFW_PRESS) {
        glfw.glfwSetWindowShouldClose(window, glfw.GLFW_TRUE);
    }
}

fn mouseCallback(window: *glfw.GLFWwindow, mouse_x: f32, mouse_y: f32) void {
    _ = &window;
    _ = &mouse_x;
    _ = &mouse_y;
}

fn scrollCallback(window: *glfw.GLFWwindow, offset_x: f32, offset_y: f32) void {
    _ = &window;
    _ = &offset_x;
    _ = &offset_y;
}
