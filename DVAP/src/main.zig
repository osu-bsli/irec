const std = @import("std");
const e = @import("example");
const Io = std.Io;
const gl = @import("glad");
const glfw = @import("glfw");

// const DVAP = @import("DVAP");

const GraphicsContext = struct {
    window: *glfw.GLFWwindow = undefined,
};

const DVAPError = error{
    NullWindow,
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

    const a = e.chicken(0);
    const b = e.amongus(0.003);

    // Attach OpenGL to the window
    const load_gl_status = gl.gladLoadGL(@as(gl.GLADloadfunc, glfw.glfwGetProcAddress));

    std.debug.print("from c: {} {} {} {} \n", .{ a, b, c, load_gl_status });

    gl.glViewport(0, 0, 800, 600);

    while (glfw.glfwWindowShouldClose(graphics_context.window) != glfw.GLFW_TRUE) {
        glfw.glfwSwapBuffers(graphics_context.window);
        glfw.glfwPollEvents();

        gl.glClearColor(0.2, 0.3, 0.3, 1.0);
        gl.glClear(gl.GL_COLOR_BUFFER_BIT);
    }

    try stdout_writer.flush(); // Don't forget to flush!

    if (std.debug.runtime_safety == true) {
        glfw.glfwTerminate();
    }
}
