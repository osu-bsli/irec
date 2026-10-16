const std = @import("std");
const c_libs = @import("clibs.zig");
const gl = c_libs.gl;
const glfw = c_libs.glfw;
const Io = std.Io;
const zm = @import("zmath");

const rocket_verts = @import("rocket_vertices.zig");

const delta_time_lib = @import("delta_time.zig");
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

var camera = camera_lib.Camera{
    .pos = zm.f32x4(0.0, 0.0, 5.0, 1.0),
};
var window_width: c_int = 800;
var window_height: c_int = 600;

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
    graphics_context.window = glfw.glfwCreateWindow(window_width, window_height, &window_name.*, null, null) orelse return DVAPError.NullWindow;

    // Make the window the user's selected window
    glfw.glfwMakeContextCurrent(graphics_context.window);
    glfw.glfwSetInputMode(graphics_context.window, glfw.GLFW_CURSOR, glfw.GLFW_CURSOR_DISABLED);
    _ = glfw.glfwSetCursorPosCallback(graphics_context.window, mouseCallback);

    // Window resizing
    const set_frame_buffer_status = glfw.glfwSetFramebufferSizeCallback(graphics_context.window, framebufferSizeCallback);
    _ = &set_frame_buffer_status;
    // const set_key_callback_status = glfw.glfwSetKeyCallback(graphics_context.window, processInput);
    // _ = &set_key_callback_status;
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
    shader.use();

    // var camera = camera_lib.Camera{
    //     .pos = .{ 0.0, 0.0, 0.0, 0.0 },
    // };
    camera.enableMouseLooking(true);

    // Location of the projection and view matrixes in vertex.glsl
    // Where opengl knows to set the values for the variables
    const projection_loc = gl.glGetUniformLocation(shader.ID, "projection");
    const view_loc: c_int = gl.glGetUniformLocation(shader.ID, "view");
    gl.glUniformMatrix4fv(projection_loc, 1, gl.GL_FALSE, zm.arrNPtr(&camera.projection));
    gl.glUniformMatrix4fv(view_loc, 1, gl.GL_FALSE, zm.arrNPtr(&camera.view));
    // ^^^ moved to global scope

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

        processInput(graphics_context.window);

        delta_time_lib.updateDeltaTime(); // find time between frames

        // processInput(graphics_context.window);

        // Bind VBO and VAO
        gl.glBindVertexArray(VAO);
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, VBO);

        camera.updateView();
        const window_width_float: f32 = @floatFromInt(window_width);
        const window_height_float: f32 = @floatFromInt(window_height);
        const fov: f32 = std.math.degreesToRadians(45.0);
        camera.updateProjection(fov, (window_width_float / window_height_float), 0.1, 1000.0);

        // Set the vertex shader uniform variables
        gl.glUniformMatrix4fv(projection_loc, 1, gl.GL_FALSE, zm.arrNPtr(&camera.projection));
        gl.glUniformMatrix4fv(view_loc, 1, gl.GL_FALSE, zm.arrNPtr(&camera.view));

        gl.glDrawArrays(gl.GL_TRIANGLES, 0, verts.len / 6); // Divide by 6 because thats the number of floats per vertex

        glfw.glfwSwapBuffers(graphics_context.window);
        glfw.glfwPollEvents();
    }

    // Shader Cleanup
    shader.deinit();

    try stdout_writer.flush(); // Don't forget to flush!

    if (std.debug.runtime_safety == true) {
        glfw.glfwTerminate();
    }
}

pub export fn framebufferSizeCallback(window: ?*glfw.GLFWwindow, width: c_int, height: c_int) void {
    _ = &window;
    window_width = width;
    window_height = height;
    gl.glViewport(0, 0, width, height);
}

// pub export fn processInput(window: ?*glfw.GLFWwindow, key: c_int, scancode: c_int, action: c_int, mods: c_int) void {
//     _ = &key;
//     _ = &scancode;
//     _ = &action;
//     _ = &mods;
//     if (glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) == glfw.GLFW_PRESS) {
//         glfw.glfwSetWindowShouldClose(window, glfw.GLFW_TRUE);
//     }

//     // Movement
//     const camera_speed: f32 = 10.0 * delta_time_lib.delta_time;
//     if (glfw.glfwGetKey(window, glfw.GLFW_KEY_W) == glfw.GLFW_PRESS) {
//         camera.move(camera_lib.MOVE_DIR.MOVE_FORWARD, camera_speed);
//     }
//     if (glfw.glfwGetKey(window, glfw.GLFW_KEY_A) == glfw.GLFW_PRESS) {
//         camera.move(camera_lib.MOVE_DIR.MOVE_LEFT, camera_speed);
//     }
//     if (glfw.glfwGetKey(window, glfw.GLFW_KEY_S) == glfw.GLFW_PRESS) {
//         camera.move(camera_lib.MOVE_DIR.MOVE_BACKWARD, camera_speed);
//     }
//     if (glfw.glfwGetKey(window, glfw.GLFW_KEY_D) == glfw.GLFW_PRESS) {
//         camera.move(camera_lib.MOVE_DIR.MOVE_RIGHT, camera_speed);
//     }
// }

pub export fn processInput(window: ?*glfw.GLFWwindow) void {
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_ESCAPE) == glfw.GLFW_PRESS) {
        glfw.glfwSetWindowShouldClose(window, glfw.GLFW_TRUE);
    }

    // Movement
    const camera_speed: f32 = 5.0 * delta_time_lib.delta_time;
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_W) == glfw.GLFW_PRESS) {
        camera.move(camera_lib.MOVE_DIR.MOVE_FORWARD, camera_speed);
    }
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_A) == glfw.GLFW_PRESS) {
        camera.move(camera_lib.MOVE_DIR.MOVE_LEFT, camera_speed);
    }
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_S) == glfw.GLFW_PRESS) {
        camera.move(camera_lib.MOVE_DIR.MOVE_BACKWARD, camera_speed);
    }
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_D) == glfw.GLFW_PRESS) {
        camera.move(camera_lib.MOVE_DIR.MOVE_RIGHT, camera_speed);
    }
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_SPACE) == glfw.GLFW_PRESS) {
        camera.move(camera_lib.MOVE_DIR.MOVE_UP, camera_speed);
    }
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_LEFT_SHIFT) == glfw.GLFW_PRESS) {
        camera.move(camera_lib.MOVE_DIR.MOVE_DOWN, camera_speed);
    }

    // View wiremesh
    if (glfw.glfwGetKey(window, glfw.GLFW_KEY_X) == glfw.GLFW_PRESS) {
        gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_LINE);
    } else {
        gl.glPolygonMode(gl.GL_FRONT_AND_BACK, gl.GL_FILL);
    }
}

var last_mouse_x: f64 = 0.0;
var last_mouse_y: f64 = 0.0;
var first_mouse: bool = true;
pub export fn mouseCallback(window: ?*glfw.GLFWwindow, mouse_x: f64, mouse_y: f64) void {
    _ = &window;

    // Check whether the program just started
    // Handle the mouse such that there is no jerky motion when the mouse first enters the screen
    if (first_mouse) {
        last_mouse_x = mouse_x;
        last_mouse_y = mouse_y;
        first_mouse = false;
    }

    // Find how far the mouse moved between frames
    var mouse_offset_x: f64 = mouse_x - last_mouse_x;
    var mouse_offset_y: f64 = mouse_y - last_mouse_y;
    last_mouse_x = mouse_x;
    last_mouse_y = mouse_y;

    // Convert the mouse change in position to a reasonable change in position for the camera
    const sensitivity: f64 = 500.0 * delta_time_lib.delta_time;
    mouse_offset_x *= sensitivity;
    mouse_offset_y *= sensitivity;

    camera.yaw += mouse_offset_x;
    camera.pitch -= mouse_offset_y; // Had to make this -= to invert the y axis

    // Make sure the camera can't look too far up
    // Like how your neck stops you from looking too far up
    if (camera.pitch > 89.0) {
        camera.pitch = 89.0;
    } else if (camera.pitch < -89.0) {
        camera.pitch = -89.0;
    }

    // Update camera front
    var direction: zm.Vec = .{ 1.0, 1.0, 1.0, 0.0 };
    direction[0] = @floatCast(std.math.cos(std.math.degreesToRadians(camera.yaw)) * std.math.cos(std.math.degreesToRadians(camera.pitch)));
    direction[1] = @floatCast(std.math.sin(std.math.degreesToRadians(camera.pitch)));
    direction[2] = @floatCast(std.math.sin(std.math.degreesToRadians(camera.yaw)) * std.math.cos(std.math.degreesToRadians(camera.pitch)));
    camera.front = zm.normalize4(direction);
    // std.debug.print
}

fn scrollCallback(window: *glfw.GLFWwindow, offset_x: f32, offset_y: f32) void {
    _ = &window;
    _ = &offset_x;
    _ = &offset_y;
}
