const std = @import("std");
const Io = std.io;

const c_libs = @import("clibs.zig");
const gl = c_libs.gl;
const glfw = c_libs.glfw;

const ShaderError = error{
    VertexError,
    FragmentError,
    ProgramError,
};

// A function to assist with compiling the vertex and fragment shaders
fn compileShader(source: [:0]const u8, shader_type: c_int) ShaderError!u32 {
    const shader = gl.glCreateShader(shader_type); // GL_VERTEX_SHADER, GL_FRAGMENT_SHADER
    gl.glShaderSource(shader, 1, &source.ptr, null);
    gl.glCompileShader(shader);

    var success: c_int = 0;
    gl.glGetShaderiv(shader, gl.GL_COMPILE_STATUS, &success);

    if (!success) {
        var info_log: [512]u8 = undefined;
        gl.glGetShaderInfoLog(shader, 512, null, &info_log);
        std.debug.print("{s}", info_log);

        // Cleanup because compilation failed
        gl.glDeleteShader(shader);
        return ShaderError.CompileError;
    }

    return shader;
}

pub const Shader = struct {
    ID: u32 = 0,

    // TO USE: const shader: Shader = Shader.init(@embedFile("Path/to/vertex_shadder.glsl"), @embedFile("Path/to/fragment_shader.glsl"));
    fn init(vertex_source: [:0]const u8, fragment_source: [:0]const u8) ShaderError!Shader {
        // Compile the vertex and fragment shaders
        // vertex_source is the soruce code of the vertex shader;
        // fragment_source is the source code of the fragment shader

        // Compile the vertex shader
        const vertex_shader: u32 = try compileShader(vertex_source, gl.GL_VERTEX_SHADER);
        defer gl.glDeleteShader(vertex_shader);

        // Compile the fragment shader
        const fragment_shader: u32 = try compileShader(fragment_source, gl.GL_FRAGMENT_SHADER);
        defer gl.glDeleteShader(fragment_shader);

        // Make the shader program
        const program = gl.glCreateProgram();
        gl.glAttachShader(program, vertex_shader);
        gl.glAttachShader(program, fragment_shader);
        gl.glLinkProgram(program);
        // Check if program was made successfully
        var success: c_int = 0;
        gl.glGetProgramiv(program, gl.GL_COMPILE_STATUS, &success);
        if (!success) {
            var info_log: [512]u8 = undefined;
            gl.glGetProgramInfoLog(program, 512, null, &info_log);
            std.debug.print("{s}", info_log);
        }

        return Shader{ .ID = program };
    }

    fn use(self: *Shader) void {
        gl.glUseProgram(self.ID);
    }

    fn cleanup(self: *Shader) void {
        gl.glDeleteProgram(self.ID);
    }

    // Functions to assist with setting uniform variables
    fn set_bool(self: *Shader, name: [:0]u8, ) {

    }
};
