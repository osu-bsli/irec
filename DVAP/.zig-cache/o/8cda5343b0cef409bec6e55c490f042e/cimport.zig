const __root = @This();
pub const __builtin = @import("std").zig.c_translation.builtins;
pub const __helpers = @import("std").zig.c_translation.helpers;
pub const GLADapiproc = ?*const fn () callconv(.c) void;
pub const GLADloadfunc = ?*const fn (name: [*c]const u8) callconv(.c) GLADapiproc;
pub const GLADuserptrloadfunc = ?*const fn (userptr: ?*anyopaque, name: [*c]const u8) callconv(.c) GLADapiproc;
pub const GLADprecallback = ?*const fn (name: [*c]const u8, apiproc: GLADapiproc, len_args: c_int, ...) callconv(.c) void;
pub const GLADpostcallback = ?*const fn (ret: ?*anyopaque, name: [*c]const u8, apiproc: GLADapiproc, len_args: c_int, ...) callconv(.c) void;
pub const __builtin_va_list = [*c]u8;
pub const __gnuc_va_list = __builtin_va_list;
pub const va_list = __gnuc_va_list;
pub extern fn __mingw_get_crt_info() [*c]const u8;
pub const rsize_t = usize;
pub const ptrdiff_t = c_longlong;
pub const wchar_t = c_ushort;
pub const wint_t = c_ushort;
pub const wctype_t = c_ushort;
pub const errno_t = c_int;
pub const __time32_t = c_long;
pub const __time64_t = c_longlong;
pub const time_t = __time64_t;
pub const struct_threadlocaleinfostruct = extern struct {
    _locale_pctype: [*c]const c_ushort = null,
    _locale_mb_cur_max: c_int = 0,
    _locale_lc_codepage: c_uint = 0,
};
pub const struct_threadmbcinfostruct = opaque {};
pub const pthreadlocinfo = [*c]struct_threadlocaleinfostruct;
pub const pthreadmbcinfo = ?*struct_threadmbcinfostruct;
pub const struct___lc_time_data = opaque {};
pub const struct_localeinfo_struct = extern struct {
    locinfo: pthreadlocinfo = null,
    mbcinfo: pthreadmbcinfo = null,
};
pub const _locale_tstruct = struct_localeinfo_struct;
pub const _locale_t = [*c]struct_localeinfo_struct;
pub const struct_tagLC_ID = extern struct {
    wLanguage: c_ushort = 0,
    wCountry: c_ushort = 0,
    wCodePage: c_ushort = 0,
};
pub const LC_ID = struct_tagLC_ID;
pub const LPLC_ID = [*c]struct_tagLC_ID;
pub const threadlocinfo = struct_threadlocaleinfostruct;
pub const max_align_t = extern struct {
    __aro_max_align_ll: c_longlong = 0,
    __aro_max_align_ld: c_longdouble = 0,
};
pub const int_least8_t = i8;
pub const uint_least8_t = u8;
pub const int_least16_t = c_short;
pub const uint_least16_t = c_ushort;
pub const int_least32_t = c_int;
pub const uint_least32_t = c_uint;
pub const int_least64_t = c_longlong;
pub const uint_least64_t = c_ulonglong;
pub const int_fast8_t = i8;
pub const uint_fast8_t = u8;
pub const int_fast16_t = c_short;
pub const uint_fast16_t = c_ushort;
pub const int_fast32_t = c_int;
pub const uint_fast32_t = c_uint;
pub const int_fast64_t = c_longlong;
pub const uint_fast64_t = c_ulonglong;
pub const intmax_t = c_longlong;
pub const uintmax_t = c_ulonglong;
pub const khronos_int32_t = i32;
pub const khronos_uint32_t = u32;
pub const khronos_int64_t = i64;
pub const khronos_uint64_t = u64;
pub const khronos_int8_t = i8;
pub const khronos_uint8_t = u8;
pub const khronos_int16_t = c_short;
pub const khronos_uint16_t = c_ushort;
pub const khronos_intptr_t = isize;
pub const khronos_uintptr_t = usize;
pub const khronos_ssize_t = c_longlong;
pub const khronos_usize_t = c_ulonglong;
pub const khronos_float_t = f32;
pub const khronos_utime_nanoseconds_t = khronos_uint64_t;
pub const khronos_stime_nanoseconds_t = khronos_int64_t;
pub const KHRONOS_FALSE: c_int = 0;
pub const KHRONOS_TRUE: c_int = 1;
pub const KHRONOS_BOOLEAN_ENUM_FORCE_SIZE: c_int = 2147483647;
pub const khronos_boolean_enum_t = c_uint;
pub const GLenum = c_uint;
pub const GLboolean = u8;
pub const GLbitfield = c_uint;
pub const GLvoid = anyopaque;
pub const GLbyte = khronos_int8_t;
pub const GLubyte = khronos_uint8_t;
pub const GLshort = khronos_int16_t;
pub const GLushort = khronos_uint16_t;
pub const GLint = c_int;
pub const GLuint = c_uint;
pub const GLclampx = khronos_int32_t;
pub const GLsizei = c_int;
pub const GLfloat = khronos_float_t;
pub const GLclampf = khronos_float_t;
pub const GLdouble = f64;
pub const GLclampd = f64;
pub const GLeglClientBufferEXT = ?*anyopaque;
pub const GLeglImageOES = ?*anyopaque;
pub const GLchar = u8;
pub const GLcharARB = u8;
pub const GLhandleARB = c_uint;
pub const GLhalf = khronos_uint16_t;
pub const GLhalfARB = khronos_uint16_t;
pub const GLfixed = khronos_int32_t;
pub const GLintptr = khronos_intptr_t;
pub const GLintptrARB = khronos_intptr_t;
pub const GLsizeiptr = khronos_ssize_t;
pub const GLsizeiptrARB = khronos_ssize_t;
pub const GLint64 = khronos_int64_t;
pub const GLint64EXT = khronos_int64_t;
pub const GLuint64 = khronos_uint64_t;
pub const GLuint64EXT = khronos_uint64_t;
pub const struct___GLsync = opaque {};
pub const GLsync = ?*struct___GLsync;
pub const struct__cl_context = opaque {};
pub const struct__cl_event = opaque {};
pub const GLDEBUGPROC = ?*const fn (source: GLenum, @"type": GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: [*c]const GLchar, userParam: ?*const anyopaque) callconv(.c) void;
pub const GLDEBUGPROCARB = ?*const fn (source: GLenum, @"type": GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: [*c]const GLchar, userParam: ?*const anyopaque) callconv(.c) void;
pub const GLDEBUGPROCKHR = ?*const fn (source: GLenum, @"type": GLenum, id: GLuint, severity: GLenum, length: GLsizei, message: [*c]const GLchar, userParam: ?*const anyopaque) callconv(.c) void;
pub const GLDEBUGPROCAMD = ?*const fn (id: GLuint, category: GLenum, severity: GLenum, length: GLsizei, message: [*c]const GLchar, userParam: ?*anyopaque) callconv(.c) void;
pub const GLhalfNV = c_ushort;
pub const GLvdpauSurfaceNV = GLintptr;
pub const GLVULKANPROCNV = ?*const fn () callconv(.c) void;
pub extern var GLAD_GL_VERSION_1_0: c_int;
pub extern var GLAD_GL_VERSION_1_1: c_int;
pub extern var GLAD_GL_VERSION_1_2: c_int;
pub extern var GLAD_GL_VERSION_1_3: c_int;
pub extern var GLAD_GL_VERSION_1_4: c_int;
pub extern var GLAD_GL_VERSION_1_5: c_int;
pub extern var GLAD_GL_VERSION_2_0: c_int;
pub extern var GLAD_GL_VERSION_2_1: c_int;
pub extern var GLAD_GL_VERSION_3_0: c_int;
pub extern var GLAD_GL_VERSION_3_1: c_int;
pub extern var GLAD_GL_VERSION_3_2: c_int;
pub extern var GLAD_GL_VERSION_3_3: c_int;
pub extern var GLAD_GL_VERSION_4_0: c_int;
pub extern var GLAD_GL_VERSION_4_1: c_int;
pub extern var GLAD_GL_VERSION_4_2: c_int;
pub extern var GLAD_GL_VERSION_4_3: c_int;
pub extern var GLAD_GL_VERSION_4_4: c_int;
pub extern var GLAD_GL_VERSION_4_5: c_int;
pub extern var GLAD_GL_VERSION_4_6: c_int;
pub const PFNGLACTIVESHADERPROGRAMPROC = ?*const fn (pipeline: GLuint, program: GLuint) callconv(.c) void;
pub const PFNGLACTIVETEXTUREPROC = ?*const fn (texture: GLenum) callconv(.c) void;
pub const PFNGLATTACHSHADERPROC = ?*const fn (program: GLuint, shader: GLuint) callconv(.c) void;
pub const PFNGLBEGINCONDITIONALRENDERPROC = ?*const fn (id: GLuint, mode: GLenum) callconv(.c) void;
pub const PFNGLBEGINQUERYPROC = ?*const fn (target: GLenum, id: GLuint) callconv(.c) void;
pub const PFNGLBEGINQUERYINDEXEDPROC = ?*const fn (target: GLenum, index: GLuint, id: GLuint) callconv(.c) void;
pub const PFNGLBEGINTRANSFORMFEEDBACKPROC = ?*const fn (primitiveMode: GLenum) callconv(.c) void;
pub const PFNGLBINDATTRIBLOCATIONPROC = ?*const fn (program: GLuint, index: GLuint, name: [*c]const GLchar) callconv(.c) void;
pub const PFNGLBINDBUFFERPROC = ?*const fn (target: GLenum, buffer: GLuint) callconv(.c) void;
pub const PFNGLBINDBUFFERBASEPROC = ?*const fn (target: GLenum, index: GLuint, buffer: GLuint) callconv(.c) void;
pub const PFNGLBINDBUFFERRANGEPROC = ?*const fn (target: GLenum, index: GLuint, buffer: GLuint, offset: GLintptr, size: GLsizeiptr) callconv(.c) void;
pub const PFNGLBINDBUFFERSBASEPROC = ?*const fn (target: GLenum, first: GLuint, count: GLsizei, buffers: [*c]const GLuint) callconv(.c) void;
pub const PFNGLBINDBUFFERSRANGEPROC = ?*const fn (target: GLenum, first: GLuint, count: GLsizei, buffers: [*c]const GLuint, offsets: [*c]const GLintptr, sizes: [*c]const GLsizeiptr) callconv(.c) void;
pub const PFNGLBINDFRAGDATALOCATIONPROC = ?*const fn (program: GLuint, color: GLuint, name: [*c]const GLchar) callconv(.c) void;
pub const PFNGLBINDFRAGDATALOCATIONINDEXEDPROC = ?*const fn (program: GLuint, colorNumber: GLuint, index: GLuint, name: [*c]const GLchar) callconv(.c) void;
pub const PFNGLBINDFRAMEBUFFERPROC = ?*const fn (target: GLenum, framebuffer: GLuint) callconv(.c) void;
pub const PFNGLBINDIMAGETEXTUREPROC = ?*const fn (unit: GLuint, texture: GLuint, level: GLint, layered: GLboolean, layer: GLint, access: GLenum, format: GLenum) callconv(.c) void;
pub const PFNGLBINDIMAGETEXTURESPROC = ?*const fn (first: GLuint, count: GLsizei, textures: [*c]const GLuint) callconv(.c) void;
pub const PFNGLBINDPROGRAMPIPELINEPROC = ?*const fn (pipeline: GLuint) callconv(.c) void;
pub const PFNGLBINDRENDERBUFFERPROC = ?*const fn (target: GLenum, renderbuffer: GLuint) callconv(.c) void;
pub const PFNGLBINDSAMPLERPROC = ?*const fn (unit: GLuint, sampler: GLuint) callconv(.c) void;
pub const PFNGLBINDSAMPLERSPROC = ?*const fn (first: GLuint, count: GLsizei, samplers: [*c]const GLuint) callconv(.c) void;
pub const PFNGLBINDTEXTUREPROC = ?*const fn (target: GLenum, texture: GLuint) callconv(.c) void;
pub const PFNGLBINDTEXTUREUNITPROC = ?*const fn (unit: GLuint, texture: GLuint) callconv(.c) void;
pub const PFNGLBINDTEXTURESPROC = ?*const fn (first: GLuint, count: GLsizei, textures: [*c]const GLuint) callconv(.c) void;
pub const PFNGLBINDTRANSFORMFEEDBACKPROC = ?*const fn (target: GLenum, id: GLuint) callconv(.c) void;
pub const PFNGLBINDVERTEXARRAYPROC = ?*const fn (array: GLuint) callconv(.c) void;
pub const PFNGLBINDVERTEXBUFFERPROC = ?*const fn (bindingindex: GLuint, buffer: GLuint, offset: GLintptr, stride: GLsizei) callconv(.c) void;
pub const PFNGLBINDVERTEXBUFFERSPROC = ?*const fn (first: GLuint, count: GLsizei, buffers: [*c]const GLuint, offsets: [*c]const GLintptr, strides: [*c]const GLsizei) callconv(.c) void;
pub const PFNGLBLENDCOLORPROC = ?*const fn (red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) callconv(.c) void;
pub const PFNGLBLENDEQUATIONPROC = ?*const fn (mode: GLenum) callconv(.c) void;
pub const PFNGLBLENDEQUATIONSEPARATEPROC = ?*const fn (modeRGB: GLenum, modeAlpha: GLenum) callconv(.c) void;
pub const PFNGLBLENDEQUATIONSEPARATEIPROC = ?*const fn (buf: GLuint, modeRGB: GLenum, modeAlpha: GLenum) callconv(.c) void;
pub const PFNGLBLENDEQUATIONIPROC = ?*const fn (buf: GLuint, mode: GLenum) callconv(.c) void;
pub const PFNGLBLENDFUNCPROC = ?*const fn (sfactor: GLenum, dfactor: GLenum) callconv(.c) void;
pub const PFNGLBLENDFUNCSEPARATEPROC = ?*const fn (sfactorRGB: GLenum, dfactorRGB: GLenum, sfactorAlpha: GLenum, dfactorAlpha: GLenum) callconv(.c) void;
pub const PFNGLBLENDFUNCSEPARATEIPROC = ?*const fn (buf: GLuint, srcRGB: GLenum, dstRGB: GLenum, srcAlpha: GLenum, dstAlpha: GLenum) callconv(.c) void;
pub const PFNGLBLENDFUNCIPROC = ?*const fn (buf: GLuint, src: GLenum, dst: GLenum) callconv(.c) void;
pub const PFNGLBLITFRAMEBUFFERPROC = ?*const fn (srcX0: GLint, srcY0: GLint, srcX1: GLint, srcY1: GLint, dstX0: GLint, dstY0: GLint, dstX1: GLint, dstY1: GLint, mask: GLbitfield, filter: GLenum) callconv(.c) void;
pub const PFNGLBLITNAMEDFRAMEBUFFERPROC = ?*const fn (readFramebuffer: GLuint, drawFramebuffer: GLuint, srcX0: GLint, srcY0: GLint, srcX1: GLint, srcY1: GLint, dstX0: GLint, dstY0: GLint, dstX1: GLint, dstY1: GLint, mask: GLbitfield, filter: GLenum) callconv(.c) void;
pub const PFNGLBUFFERDATAPROC = ?*const fn (target: GLenum, size: GLsizeiptr, data: ?*const anyopaque, usage: GLenum) callconv(.c) void;
pub const PFNGLBUFFERSTORAGEPROC = ?*const fn (target: GLenum, size: GLsizeiptr, data: ?*const anyopaque, flags: GLbitfield) callconv(.c) void;
pub const PFNGLBUFFERSUBDATAPROC = ?*const fn (target: GLenum, offset: GLintptr, size: GLsizeiptr, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCHECKFRAMEBUFFERSTATUSPROC = ?*const fn (target: GLenum) callconv(.c) GLenum;
pub const PFNGLCHECKNAMEDFRAMEBUFFERSTATUSPROC = ?*const fn (framebuffer: GLuint, target: GLenum) callconv(.c) GLenum;
pub const PFNGLCLAMPCOLORPROC = ?*const fn (target: GLenum, clamp: GLenum) callconv(.c) void;
pub const PFNGLCLEARPROC = ?*const fn (mask: GLbitfield) callconv(.c) void;
pub const PFNGLCLEARBUFFERDATAPROC = ?*const fn (target: GLenum, internalformat: GLenum, format: GLenum, @"type": GLenum, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCLEARBUFFERSUBDATAPROC = ?*const fn (target: GLenum, internalformat: GLenum, offset: GLintptr, size: GLsizeiptr, format: GLenum, @"type": GLenum, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCLEARBUFFERFIPROC = ?*const fn (buffer: GLenum, drawbuffer: GLint, depth: GLfloat, stencil: GLint) callconv(.c) void;
pub const PFNGLCLEARBUFFERFVPROC = ?*const fn (buffer: GLenum, drawbuffer: GLint, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLCLEARBUFFERIVPROC = ?*const fn (buffer: GLenum, drawbuffer: GLint, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLCLEARBUFFERUIVPROC = ?*const fn (buffer: GLenum, drawbuffer: GLint, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLCLEARCOLORPROC = ?*const fn (red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) callconv(.c) void;
pub const PFNGLCLEARDEPTHPROC = ?*const fn (depth: GLdouble) callconv(.c) void;
pub const PFNGLCLEARDEPTHFPROC = ?*const fn (d: GLfloat) callconv(.c) void;
pub const PFNGLCLEARNAMEDBUFFERDATAPROC = ?*const fn (buffer: GLuint, internalformat: GLenum, format: GLenum, @"type": GLenum, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCLEARNAMEDBUFFERSUBDATAPROC = ?*const fn (buffer: GLuint, internalformat: GLenum, offset: GLintptr, size: GLsizeiptr, format: GLenum, @"type": GLenum, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCLEARNAMEDFRAMEBUFFERFIPROC = ?*const fn (framebuffer: GLuint, buffer: GLenum, drawbuffer: GLint, depth: GLfloat, stencil: GLint) callconv(.c) void;
pub const PFNGLCLEARNAMEDFRAMEBUFFERFVPROC = ?*const fn (framebuffer: GLuint, buffer: GLenum, drawbuffer: GLint, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLCLEARNAMEDFRAMEBUFFERIVPROC = ?*const fn (framebuffer: GLuint, buffer: GLenum, drawbuffer: GLint, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLCLEARNAMEDFRAMEBUFFERUIVPROC = ?*const fn (framebuffer: GLuint, buffer: GLenum, drawbuffer: GLint, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLCLEARSTENCILPROC = ?*const fn (s: GLint) callconv(.c) void;
pub const PFNGLCLEARTEXIMAGEPROC = ?*const fn (texture: GLuint, level: GLint, format: GLenum, @"type": GLenum, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCLEARTEXSUBIMAGEPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, @"type": GLenum, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCLIENTWAITSYNCPROC = ?*const fn (sync: GLsync, flags: GLbitfield, timeout: GLuint64) callconv(.c) GLenum;
pub const PFNGLCLIPCONTROLPROC = ?*const fn (origin: GLenum, depth: GLenum) callconv(.c) void;
pub const PFNGLCOLORMASKPROC = ?*const fn (red: GLboolean, green: GLboolean, blue: GLboolean, alpha: GLboolean) callconv(.c) void;
pub const PFNGLCOLORMASKIPROC = ?*const fn (index: GLuint, r: GLboolean, g: GLboolean, b: GLboolean, a: GLboolean) callconv(.c) void;
pub const PFNGLCOMPILESHADERPROC = ?*const fn (shader: GLuint) callconv(.c) void;
pub const PFNGLCOMPRESSEDTEXIMAGE1DPROC = ?*const fn (target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, border: GLint, imageSize: GLsizei, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCOMPRESSEDTEXIMAGE2DPROC = ?*const fn (target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, height: GLsizei, border: GLint, imageSize: GLsizei, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCOMPRESSEDTEXIMAGE3DPROC = ?*const fn (target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, border: GLint, imageSize: GLsizei, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCOMPRESSEDTEXSUBIMAGE1DPROC = ?*const fn (target: GLenum, level: GLint, xoffset: GLint, width: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCOMPRESSEDTEXSUBIMAGE2DPROC = ?*const fn (target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCOMPRESSEDTEXSUBIMAGE3DPROC = ?*const fn (target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCOMPRESSEDTEXTURESUBIMAGE1DPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, width: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCOMPRESSEDTEXTURESUBIMAGE2DPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCOMPRESSEDTEXTURESUBIMAGE3DPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLCOPYBUFFERSUBDATAPROC = ?*const fn (readTarget: GLenum, writeTarget: GLenum, readOffset: GLintptr, writeOffset: GLintptr, size: GLsizeiptr) callconv(.c) void;
pub const PFNGLCOPYIMAGESUBDATAPROC = ?*const fn (srcName: GLuint, srcTarget: GLenum, srcLevel: GLint, srcX: GLint, srcY: GLint, srcZ: GLint, dstName: GLuint, dstTarget: GLenum, dstLevel: GLint, dstX: GLint, dstY: GLint, dstZ: GLint, srcWidth: GLsizei, srcHeight: GLsizei, srcDepth: GLsizei) callconv(.c) void;
pub const PFNGLCOPYNAMEDBUFFERSUBDATAPROC = ?*const fn (readBuffer: GLuint, writeBuffer: GLuint, readOffset: GLintptr, writeOffset: GLintptr, size: GLsizeiptr) callconv(.c) void;
pub const PFNGLCOPYTEXIMAGE1DPROC = ?*const fn (target: GLenum, level: GLint, internalformat: GLenum, x: GLint, y: GLint, width: GLsizei, border: GLint) callconv(.c) void;
pub const PFNGLCOPYTEXIMAGE2DPROC = ?*const fn (target: GLenum, level: GLint, internalformat: GLenum, x: GLint, y: GLint, width: GLsizei, height: GLsizei, border: GLint) callconv(.c) void;
pub const PFNGLCOPYTEXSUBIMAGE1DPROC = ?*const fn (target: GLenum, level: GLint, xoffset: GLint, x: GLint, y: GLint, width: GLsizei) callconv(.c) void;
pub const PFNGLCOPYTEXSUBIMAGE2DPROC = ?*const fn (target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLCOPYTEXSUBIMAGE3DPROC = ?*const fn (target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLCOPYTEXTURESUBIMAGE1DPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, x: GLint, y: GLint, width: GLsizei) callconv(.c) void;
pub const PFNGLCOPYTEXTURESUBIMAGE2DPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLCOPYTEXTURESUBIMAGE3DPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLCREATEBUFFERSPROC = ?*const fn (n: GLsizei, buffers: [*c]GLuint) callconv(.c) void;
pub const PFNGLCREATEFRAMEBUFFERSPROC = ?*const fn (n: GLsizei, framebuffers: [*c]GLuint) callconv(.c) void;
pub const PFNGLCREATEPROGRAMPROC = ?*const fn () callconv(.c) GLuint;
pub const PFNGLCREATEPROGRAMPIPELINESPROC = ?*const fn (n: GLsizei, pipelines: [*c]GLuint) callconv(.c) void;
pub const PFNGLCREATEQUERIESPROC = ?*const fn (target: GLenum, n: GLsizei, ids: [*c]GLuint) callconv(.c) void;
pub const PFNGLCREATERENDERBUFFERSPROC = ?*const fn (n: GLsizei, renderbuffers: [*c]GLuint) callconv(.c) void;
pub const PFNGLCREATESAMPLERSPROC = ?*const fn (n: GLsizei, samplers: [*c]GLuint) callconv(.c) void;
pub const PFNGLCREATESHADERPROC = ?*const fn (@"type": GLenum) callconv(.c) GLuint;
pub const PFNGLCREATESHADERPROGRAMVPROC = ?*const fn (@"type": GLenum, count: GLsizei, strings: [*c]const [*c]const GLchar) callconv(.c) GLuint;
pub const PFNGLCREATETEXTURESPROC = ?*const fn (target: GLenum, n: GLsizei, textures: [*c]GLuint) callconv(.c) void;
pub const PFNGLCREATETRANSFORMFEEDBACKSPROC = ?*const fn (n: GLsizei, ids: [*c]GLuint) callconv(.c) void;
pub const PFNGLCREATEVERTEXARRAYSPROC = ?*const fn (n: GLsizei, arrays: [*c]GLuint) callconv(.c) void;
pub const PFNGLCULLFACEPROC = ?*const fn (mode: GLenum) callconv(.c) void;
pub const PFNGLDEBUGMESSAGECALLBACKPROC = ?*const fn (callback: GLDEBUGPROC, userParam: ?*const anyopaque) callconv(.c) void;
pub const PFNGLDEBUGMESSAGECONTROLPROC = ?*const fn (source: GLenum, @"type": GLenum, severity: GLenum, count: GLsizei, ids: [*c]const GLuint, enabled: GLboolean) callconv(.c) void;
pub const PFNGLDEBUGMESSAGEINSERTPROC = ?*const fn (source: GLenum, @"type": GLenum, id: GLuint, severity: GLenum, length: GLsizei, buf: [*c]const GLchar) callconv(.c) void;
pub const PFNGLDELETEBUFFERSPROC = ?*const fn (n: GLsizei, buffers: [*c]const GLuint) callconv(.c) void;
pub const PFNGLDELETEFRAMEBUFFERSPROC = ?*const fn (n: GLsizei, framebuffers: [*c]const GLuint) callconv(.c) void;
pub const PFNGLDELETEPROGRAMPROC = ?*const fn (program: GLuint) callconv(.c) void;
pub const PFNGLDELETEPROGRAMPIPELINESPROC = ?*const fn (n: GLsizei, pipelines: [*c]const GLuint) callconv(.c) void;
pub const PFNGLDELETEQUERIESPROC = ?*const fn (n: GLsizei, ids: [*c]const GLuint) callconv(.c) void;
pub const PFNGLDELETERENDERBUFFERSPROC = ?*const fn (n: GLsizei, renderbuffers: [*c]const GLuint) callconv(.c) void;
pub const PFNGLDELETESAMPLERSPROC = ?*const fn (count: GLsizei, samplers: [*c]const GLuint) callconv(.c) void;
pub const PFNGLDELETESHADERPROC = ?*const fn (shader: GLuint) callconv(.c) void;
pub const PFNGLDELETESYNCPROC = ?*const fn (sync: GLsync) callconv(.c) void;
pub const PFNGLDELETETEXTURESPROC = ?*const fn (n: GLsizei, textures: [*c]const GLuint) callconv(.c) void;
pub const PFNGLDELETETRANSFORMFEEDBACKSPROC = ?*const fn (n: GLsizei, ids: [*c]const GLuint) callconv(.c) void;
pub const PFNGLDELETEVERTEXARRAYSPROC = ?*const fn (n: GLsizei, arrays: [*c]const GLuint) callconv(.c) void;
pub const PFNGLDEPTHFUNCPROC = ?*const fn (func: GLenum) callconv(.c) void;
pub const PFNGLDEPTHMASKPROC = ?*const fn (flag: GLboolean) callconv(.c) void;
pub const PFNGLDEPTHRANGEPROC = ?*const fn (n: GLdouble, f: GLdouble) callconv(.c) void;
pub const PFNGLDEPTHRANGEARRAYVPROC = ?*const fn (first: GLuint, count: GLsizei, v: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLDEPTHRANGEINDEXEDPROC = ?*const fn (index: GLuint, n: GLdouble, f: GLdouble) callconv(.c) void;
pub const PFNGLDEPTHRANGEFPROC = ?*const fn (n: GLfloat, f: GLfloat) callconv(.c) void;
pub const PFNGLDETACHSHADERPROC = ?*const fn (program: GLuint, shader: GLuint) callconv(.c) void;
pub const PFNGLDISABLEPROC = ?*const fn (cap: GLenum) callconv(.c) void;
pub const PFNGLDISABLEVERTEXARRAYATTRIBPROC = ?*const fn (vaobj: GLuint, index: GLuint) callconv(.c) void;
pub const PFNGLDISABLEVERTEXATTRIBARRAYPROC = ?*const fn (index: GLuint) callconv(.c) void;
pub const PFNGLDISABLEIPROC = ?*const fn (target: GLenum, index: GLuint) callconv(.c) void;
pub const PFNGLDISPATCHCOMPUTEPROC = ?*const fn (num_groups_x: GLuint, num_groups_y: GLuint, num_groups_z: GLuint) callconv(.c) void;
pub const PFNGLDISPATCHCOMPUTEINDIRECTPROC = ?*const fn (indirect: GLintptr) callconv(.c) void;
pub const PFNGLDRAWARRAYSPROC = ?*const fn (mode: GLenum, first: GLint, count: GLsizei) callconv(.c) void;
pub const PFNGLDRAWARRAYSINDIRECTPROC = ?*const fn (mode: GLenum, indirect: ?*const anyopaque) callconv(.c) void;
pub const PFNGLDRAWARRAYSINSTANCEDPROC = ?*const fn (mode: GLenum, first: GLint, count: GLsizei, instancecount: GLsizei) callconv(.c) void;
pub const PFNGLDRAWARRAYSINSTANCEDBASEINSTANCEPROC = ?*const fn (mode: GLenum, first: GLint, count: GLsizei, instancecount: GLsizei, baseinstance: GLuint) callconv(.c) void;
pub const PFNGLDRAWBUFFERPROC = ?*const fn (buf: GLenum) callconv(.c) void;
pub const PFNGLDRAWBUFFERSPROC = ?*const fn (n: GLsizei, bufs: [*c]const GLenum) callconv(.c) void;
pub const PFNGLDRAWELEMENTSPROC = ?*const fn (mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque) callconv(.c) void;
pub const PFNGLDRAWELEMENTSBASEVERTEXPROC = ?*const fn (mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, basevertex: GLint) callconv(.c) void;
pub const PFNGLDRAWELEMENTSINDIRECTPROC = ?*const fn (mode: GLenum, @"type": GLenum, indirect: ?*const anyopaque) callconv(.c) void;
pub const PFNGLDRAWELEMENTSINSTANCEDPROC = ?*const fn (mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, instancecount: GLsizei) callconv(.c) void;
pub const PFNGLDRAWELEMENTSINSTANCEDBASEINSTANCEPROC = ?*const fn (mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, instancecount: GLsizei, baseinstance: GLuint) callconv(.c) void;
pub const PFNGLDRAWELEMENTSINSTANCEDBASEVERTEXPROC = ?*const fn (mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, instancecount: GLsizei, basevertex: GLint) callconv(.c) void;
pub const PFNGLDRAWELEMENTSINSTANCEDBASEVERTEXBASEINSTANCEPROC = ?*const fn (mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, instancecount: GLsizei, basevertex: GLint, baseinstance: GLuint) callconv(.c) void;
pub const PFNGLDRAWRANGEELEMENTSPROC = ?*const fn (mode: GLenum, start: GLuint, end: GLuint, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque) callconv(.c) void;
pub const PFNGLDRAWRANGEELEMENTSBASEVERTEXPROC = ?*const fn (mode: GLenum, start: GLuint, end: GLuint, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, basevertex: GLint) callconv(.c) void;
pub const PFNGLDRAWTRANSFORMFEEDBACKPROC = ?*const fn (mode: GLenum, id: GLuint) callconv(.c) void;
pub const PFNGLDRAWTRANSFORMFEEDBACKINSTANCEDPROC = ?*const fn (mode: GLenum, id: GLuint, instancecount: GLsizei) callconv(.c) void;
pub const PFNGLDRAWTRANSFORMFEEDBACKSTREAMPROC = ?*const fn (mode: GLenum, id: GLuint, stream: GLuint) callconv(.c) void;
pub const PFNGLDRAWTRANSFORMFEEDBACKSTREAMINSTANCEDPROC = ?*const fn (mode: GLenum, id: GLuint, stream: GLuint, instancecount: GLsizei) callconv(.c) void;
pub const PFNGLENABLEPROC = ?*const fn (cap: GLenum) callconv(.c) void;
pub const PFNGLENABLEVERTEXARRAYATTRIBPROC = ?*const fn (vaobj: GLuint, index: GLuint) callconv(.c) void;
pub const PFNGLENABLEVERTEXATTRIBARRAYPROC = ?*const fn (index: GLuint) callconv(.c) void;
pub const PFNGLENABLEIPROC = ?*const fn (target: GLenum, index: GLuint) callconv(.c) void;
pub const PFNGLENDCONDITIONALRENDERPROC = ?*const fn () callconv(.c) void;
pub const PFNGLENDQUERYPROC = ?*const fn (target: GLenum) callconv(.c) void;
pub const PFNGLENDQUERYINDEXEDPROC = ?*const fn (target: GLenum, index: GLuint) callconv(.c) void;
pub const PFNGLENDTRANSFORMFEEDBACKPROC = ?*const fn () callconv(.c) void;
pub const PFNGLFENCESYNCPROC = ?*const fn (condition: GLenum, flags: GLbitfield) callconv(.c) GLsync;
pub const PFNGLFINISHPROC = ?*const fn () callconv(.c) void;
pub const PFNGLFLUSHPROC = ?*const fn () callconv(.c) void;
pub const PFNGLFLUSHMAPPEDBUFFERRANGEPROC = ?*const fn (target: GLenum, offset: GLintptr, length: GLsizeiptr) callconv(.c) void;
pub const PFNGLFLUSHMAPPEDNAMEDBUFFERRANGEPROC = ?*const fn (buffer: GLuint, offset: GLintptr, length: GLsizeiptr) callconv(.c) void;
pub const PFNGLFRAMEBUFFERPARAMETERIPROC = ?*const fn (target: GLenum, pname: GLenum, param: GLint) callconv(.c) void;
pub const PFNGLFRAMEBUFFERRENDERBUFFERPROC = ?*const fn (target: GLenum, attachment: GLenum, renderbuffertarget: GLenum, renderbuffer: GLuint) callconv(.c) void;
pub const PFNGLFRAMEBUFFERTEXTUREPROC = ?*const fn (target: GLenum, attachment: GLenum, texture: GLuint, level: GLint) callconv(.c) void;
pub const PFNGLFRAMEBUFFERTEXTURE1DPROC = ?*const fn (target: GLenum, attachment: GLenum, textarget: GLenum, texture: GLuint, level: GLint) callconv(.c) void;
pub const PFNGLFRAMEBUFFERTEXTURE2DPROC = ?*const fn (target: GLenum, attachment: GLenum, textarget: GLenum, texture: GLuint, level: GLint) callconv(.c) void;
pub const PFNGLFRAMEBUFFERTEXTURE3DPROC = ?*const fn (target: GLenum, attachment: GLenum, textarget: GLenum, texture: GLuint, level: GLint, zoffset: GLint) callconv(.c) void;
pub const PFNGLFRAMEBUFFERTEXTURELAYERPROC = ?*const fn (target: GLenum, attachment: GLenum, texture: GLuint, level: GLint, layer: GLint) callconv(.c) void;
pub const PFNGLFRONTFACEPROC = ?*const fn (mode: GLenum) callconv(.c) void;
pub const PFNGLGENBUFFERSPROC = ?*const fn (n: GLsizei, buffers: [*c]GLuint) callconv(.c) void;
pub const PFNGLGENFRAMEBUFFERSPROC = ?*const fn (n: GLsizei, framebuffers: [*c]GLuint) callconv(.c) void;
pub const PFNGLGENPROGRAMPIPELINESPROC = ?*const fn (n: GLsizei, pipelines: [*c]GLuint) callconv(.c) void;
pub const PFNGLGENQUERIESPROC = ?*const fn (n: GLsizei, ids: [*c]GLuint) callconv(.c) void;
pub const PFNGLGENRENDERBUFFERSPROC = ?*const fn (n: GLsizei, renderbuffers: [*c]GLuint) callconv(.c) void;
pub const PFNGLGENSAMPLERSPROC = ?*const fn (count: GLsizei, samplers: [*c]GLuint) callconv(.c) void;
pub const PFNGLGENTEXTURESPROC = ?*const fn (n: GLsizei, textures: [*c]GLuint) callconv(.c) void;
pub const PFNGLGENTRANSFORMFEEDBACKSPROC = ?*const fn (n: GLsizei, ids: [*c]GLuint) callconv(.c) void;
pub const PFNGLGENVERTEXARRAYSPROC = ?*const fn (n: GLsizei, arrays: [*c]GLuint) callconv(.c) void;
pub const PFNGLGENERATEMIPMAPPROC = ?*const fn (target: GLenum) callconv(.c) void;
pub const PFNGLGENERATETEXTUREMIPMAPPROC = ?*const fn (texture: GLuint) callconv(.c) void;
pub const PFNGLGETACTIVEATOMICCOUNTERBUFFERIVPROC = ?*const fn (program: GLuint, bufferIndex: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETACTIVEATTRIBPROC = ?*const fn (program: GLuint, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, size: [*c]GLint, @"type": [*c]GLenum, name: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETACTIVESUBROUTINENAMEPROC = ?*const fn (program: GLuint, shadertype: GLenum, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, name: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETACTIVESUBROUTINEUNIFORMNAMEPROC = ?*const fn (program: GLuint, shadertype: GLenum, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, name: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETACTIVESUBROUTINEUNIFORMIVPROC = ?*const fn (program: GLuint, shadertype: GLenum, index: GLuint, pname: GLenum, values: [*c]GLint) callconv(.c) void;
pub const PFNGLGETACTIVEUNIFORMPROC = ?*const fn (program: GLuint, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, size: [*c]GLint, @"type": [*c]GLenum, name: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETACTIVEUNIFORMBLOCKNAMEPROC = ?*const fn (program: GLuint, uniformBlockIndex: GLuint, bufSize: GLsizei, length: [*c]GLsizei, uniformBlockName: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETACTIVEUNIFORMBLOCKIVPROC = ?*const fn (program: GLuint, uniformBlockIndex: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETACTIVEUNIFORMNAMEPROC = ?*const fn (program: GLuint, uniformIndex: GLuint, bufSize: GLsizei, length: [*c]GLsizei, uniformName: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETACTIVEUNIFORMSIVPROC = ?*const fn (program: GLuint, uniformCount: GLsizei, uniformIndices: [*c]const GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETATTACHEDSHADERSPROC = ?*const fn (program: GLuint, maxCount: GLsizei, count: [*c]GLsizei, shaders: [*c]GLuint) callconv(.c) void;
pub const PFNGLGETATTRIBLOCATIONPROC = ?*const fn (program: GLuint, name: [*c]const GLchar) callconv(.c) GLint;
pub const PFNGLGETBOOLEANI_VPROC = ?*const fn (target: GLenum, index: GLuint, data: [*c]GLboolean) callconv(.c) void;
pub const PFNGLGETBOOLEANVPROC = ?*const fn (pname: GLenum, data: [*c]GLboolean) callconv(.c) void;
pub const PFNGLGETBUFFERPARAMETERI64VPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]GLint64) callconv(.c) void;
pub const PFNGLGETBUFFERPARAMETERIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETBUFFERPOINTERVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]?*anyopaque) callconv(.c) void;
pub const PFNGLGETBUFFERSUBDATAPROC = ?*const fn (target: GLenum, offset: GLintptr, size: GLsizeiptr, data: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETCOMPRESSEDTEXIMAGEPROC = ?*const fn (target: GLenum, level: GLint, img: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETCOMPRESSEDTEXTUREIMAGEPROC = ?*const fn (texture: GLuint, level: GLint, bufSize: GLsizei, pixels: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETCOMPRESSEDTEXTURESUBIMAGEPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, bufSize: GLsizei, pixels: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETDEBUGMESSAGELOGPROC = ?*const fn (count: GLuint, bufSize: GLsizei, sources: [*c]GLenum, types: [*c]GLenum, ids: [*c]GLuint, severities: [*c]GLenum, lengths: [*c]GLsizei, messageLog: [*c]GLchar) callconv(.c) GLuint;
pub const PFNGLGETDOUBLEI_VPROC = ?*const fn (target: GLenum, index: GLuint, data: [*c]GLdouble) callconv(.c) void;
pub const PFNGLGETDOUBLEVPROC = ?*const fn (pname: GLenum, data: [*c]GLdouble) callconv(.c) void;
pub const PFNGLGETERRORPROC = ?*const fn () callconv(.c) GLenum;
pub const PFNGLGETFLOATI_VPROC = ?*const fn (target: GLenum, index: GLuint, data: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETFLOATVPROC = ?*const fn (pname: GLenum, data: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETFRAGDATAINDEXPROC = ?*const fn (program: GLuint, name: [*c]const GLchar) callconv(.c) GLint;
pub const PFNGLGETFRAGDATALOCATIONPROC = ?*const fn (program: GLuint, name: [*c]const GLchar) callconv(.c) GLint;
pub const PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVPROC = ?*const fn (target: GLenum, attachment: GLenum, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETFRAMEBUFFERPARAMETERIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETGRAPHICSRESETSTATUSPROC = ?*const fn () callconv(.c) GLenum;
pub const PFNGLGETINTEGER64I_VPROC = ?*const fn (target: GLenum, index: GLuint, data: [*c]GLint64) callconv(.c) void;
pub const PFNGLGETINTEGER64VPROC = ?*const fn (pname: GLenum, data: [*c]GLint64) callconv(.c) void;
pub const PFNGLGETINTEGERI_VPROC = ?*const fn (target: GLenum, index: GLuint, data: [*c]GLint) callconv(.c) void;
pub const PFNGLGETINTEGERVPROC = ?*const fn (pname: GLenum, data: [*c]GLint) callconv(.c) void;
pub const PFNGLGETINTERNALFORMATI64VPROC = ?*const fn (target: GLenum, internalformat: GLenum, pname: GLenum, count: GLsizei, params: [*c]GLint64) callconv(.c) void;
pub const PFNGLGETINTERNALFORMATIVPROC = ?*const fn (target: GLenum, internalformat: GLenum, pname: GLenum, count: GLsizei, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETMULTISAMPLEFVPROC = ?*const fn (pname: GLenum, index: GLuint, val: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETNAMEDBUFFERPARAMETERI64VPROC = ?*const fn (buffer: GLuint, pname: GLenum, params: [*c]GLint64) callconv(.c) void;
pub const PFNGLGETNAMEDBUFFERPARAMETERIVPROC = ?*const fn (buffer: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETNAMEDBUFFERPOINTERVPROC = ?*const fn (buffer: GLuint, pname: GLenum, params: [*c]?*anyopaque) callconv(.c) void;
pub const PFNGLGETNAMEDBUFFERSUBDATAPROC = ?*const fn (buffer: GLuint, offset: GLintptr, size: GLsizeiptr, data: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETNAMEDFRAMEBUFFERATTACHMENTPARAMETERIVPROC = ?*const fn (framebuffer: GLuint, attachment: GLenum, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETNAMEDFRAMEBUFFERPARAMETERIVPROC = ?*const fn (framebuffer: GLuint, pname: GLenum, param: [*c]GLint) callconv(.c) void;
pub const PFNGLGETNAMEDRENDERBUFFERPARAMETERIVPROC = ?*const fn (renderbuffer: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETOBJECTLABELPROC = ?*const fn (identifier: GLenum, name: GLuint, bufSize: GLsizei, length: [*c]GLsizei, label: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETOBJECTPTRLABELPROC = ?*const fn (ptr: ?*const anyopaque, bufSize: GLsizei, length: [*c]GLsizei, label: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETPOINTERVPROC = ?*const fn (pname: GLenum, params: [*c]?*anyopaque) callconv(.c) void;
pub const PFNGLGETPROGRAMBINARYPROC = ?*const fn (program: GLuint, bufSize: GLsizei, length: [*c]GLsizei, binaryFormat: [*c]GLenum, binary: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETPROGRAMINFOLOGPROC = ?*const fn (program: GLuint, bufSize: GLsizei, length: [*c]GLsizei, infoLog: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETPROGRAMINTERFACEIVPROC = ?*const fn (program: GLuint, programInterface: GLenum, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETPROGRAMPIPELINEINFOLOGPROC = ?*const fn (pipeline: GLuint, bufSize: GLsizei, length: [*c]GLsizei, infoLog: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETPROGRAMPIPELINEIVPROC = ?*const fn (pipeline: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETPROGRAMRESOURCEINDEXPROC = ?*const fn (program: GLuint, programInterface: GLenum, name: [*c]const GLchar) callconv(.c) GLuint;
pub const PFNGLGETPROGRAMRESOURCELOCATIONPROC = ?*const fn (program: GLuint, programInterface: GLenum, name: [*c]const GLchar) callconv(.c) GLint;
pub const PFNGLGETPROGRAMRESOURCELOCATIONINDEXPROC = ?*const fn (program: GLuint, programInterface: GLenum, name: [*c]const GLchar) callconv(.c) GLint;
pub const PFNGLGETPROGRAMRESOURCENAMEPROC = ?*const fn (program: GLuint, programInterface: GLenum, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, name: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETPROGRAMRESOURCEIVPROC = ?*const fn (program: GLuint, programInterface: GLenum, index: GLuint, propCount: GLsizei, props: [*c]const GLenum, count: GLsizei, length: [*c]GLsizei, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETPROGRAMSTAGEIVPROC = ?*const fn (program: GLuint, shadertype: GLenum, pname: GLenum, values: [*c]GLint) callconv(.c) void;
pub const PFNGLGETPROGRAMIVPROC = ?*const fn (program: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETQUERYBUFFEROBJECTI64VPROC = ?*const fn (id: GLuint, buffer: GLuint, pname: GLenum, offset: GLintptr) callconv(.c) void;
pub const PFNGLGETQUERYBUFFEROBJECTIVPROC = ?*const fn (id: GLuint, buffer: GLuint, pname: GLenum, offset: GLintptr) callconv(.c) void;
pub const PFNGLGETQUERYBUFFEROBJECTUI64VPROC = ?*const fn (id: GLuint, buffer: GLuint, pname: GLenum, offset: GLintptr) callconv(.c) void;
pub const PFNGLGETQUERYBUFFEROBJECTUIVPROC = ?*const fn (id: GLuint, buffer: GLuint, pname: GLenum, offset: GLintptr) callconv(.c) void;
pub const PFNGLGETQUERYINDEXEDIVPROC = ?*const fn (target: GLenum, index: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETQUERYOBJECTI64VPROC = ?*const fn (id: GLuint, pname: GLenum, params: [*c]GLint64) callconv(.c) void;
pub const PFNGLGETQUERYOBJECTIVPROC = ?*const fn (id: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETQUERYOBJECTUI64VPROC = ?*const fn (id: GLuint, pname: GLenum, params: [*c]GLuint64) callconv(.c) void;
pub const PFNGLGETQUERYOBJECTUIVPROC = ?*const fn (id: GLuint, pname: GLenum, params: [*c]GLuint) callconv(.c) void;
pub const PFNGLGETQUERYIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETRENDERBUFFERPARAMETERIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETSAMPLERPARAMETERIIVPROC = ?*const fn (sampler: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETSAMPLERPARAMETERIUIVPROC = ?*const fn (sampler: GLuint, pname: GLenum, params: [*c]GLuint) callconv(.c) void;
pub const PFNGLGETSAMPLERPARAMETERFVPROC = ?*const fn (sampler: GLuint, pname: GLenum, params: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETSAMPLERPARAMETERIVPROC = ?*const fn (sampler: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETSHADERINFOLOGPROC = ?*const fn (shader: GLuint, bufSize: GLsizei, length: [*c]GLsizei, infoLog: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETSHADERPRECISIONFORMATPROC = ?*const fn (shadertype: GLenum, precisiontype: GLenum, range: [*c]GLint, precision: [*c]GLint) callconv(.c) void;
pub const PFNGLGETSHADERSOURCEPROC = ?*const fn (shader: GLuint, bufSize: GLsizei, length: [*c]GLsizei, source: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETSHADERIVPROC = ?*const fn (shader: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETSTRINGPROC = ?*const fn (name: GLenum) callconv(.c) [*c]const GLubyte;
pub const PFNGLGETSTRINGIPROC = ?*const fn (name: GLenum, index: GLuint) callconv(.c) [*c]const GLubyte;
pub const PFNGLGETSUBROUTINEINDEXPROC = ?*const fn (program: GLuint, shadertype: GLenum, name: [*c]const GLchar) callconv(.c) GLuint;
pub const PFNGLGETSUBROUTINEUNIFORMLOCATIONPROC = ?*const fn (program: GLuint, shadertype: GLenum, name: [*c]const GLchar) callconv(.c) GLint;
pub const PFNGLGETSYNCIVPROC = ?*const fn (sync: GLsync, pname: GLenum, count: GLsizei, length: [*c]GLsizei, values: [*c]GLint) callconv(.c) void;
pub const PFNGLGETTEXIMAGEPROC = ?*const fn (target: GLenum, level: GLint, format: GLenum, @"type": GLenum, pixels: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETTEXLEVELPARAMETERFVPROC = ?*const fn (target: GLenum, level: GLint, pname: GLenum, params: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETTEXLEVELPARAMETERIVPROC = ?*const fn (target: GLenum, level: GLint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETTEXPARAMETERIIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETTEXPARAMETERIUIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]GLuint) callconv(.c) void;
pub const PFNGLGETTEXPARAMETERFVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETTEXPARAMETERIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETTEXTUREIMAGEPROC = ?*const fn (texture: GLuint, level: GLint, format: GLenum, @"type": GLenum, bufSize: GLsizei, pixels: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETTEXTURELEVELPARAMETERFVPROC = ?*const fn (texture: GLuint, level: GLint, pname: GLenum, params: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETTEXTURELEVELPARAMETERIVPROC = ?*const fn (texture: GLuint, level: GLint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETTEXTUREPARAMETERIIVPROC = ?*const fn (texture: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETTEXTUREPARAMETERIUIVPROC = ?*const fn (texture: GLuint, pname: GLenum, params: [*c]GLuint) callconv(.c) void;
pub const PFNGLGETTEXTUREPARAMETERFVPROC = ?*const fn (texture: GLuint, pname: GLenum, params: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETTEXTUREPARAMETERIVPROC = ?*const fn (texture: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETTEXTURESUBIMAGEPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, @"type": GLenum, bufSize: GLsizei, pixels: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETTRANSFORMFEEDBACKVARYINGPROC = ?*const fn (program: GLuint, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, size: [*c]GLsizei, @"type": [*c]GLenum, name: [*c]GLchar) callconv(.c) void;
pub const PFNGLGETTRANSFORMFEEDBACKI64_VPROC = ?*const fn (xfb: GLuint, pname: GLenum, index: GLuint, param: [*c]GLint64) callconv(.c) void;
pub const PFNGLGETTRANSFORMFEEDBACKI_VPROC = ?*const fn (xfb: GLuint, pname: GLenum, index: GLuint, param: [*c]GLint) callconv(.c) void;
pub const PFNGLGETTRANSFORMFEEDBACKIVPROC = ?*const fn (xfb: GLuint, pname: GLenum, param: [*c]GLint) callconv(.c) void;
pub const PFNGLGETUNIFORMBLOCKINDEXPROC = ?*const fn (program: GLuint, uniformBlockName: [*c]const GLchar) callconv(.c) GLuint;
pub const PFNGLGETUNIFORMINDICESPROC = ?*const fn (program: GLuint, uniformCount: GLsizei, uniformNames: [*c]const [*c]const GLchar, uniformIndices: [*c]GLuint) callconv(.c) void;
pub const PFNGLGETUNIFORMLOCATIONPROC = ?*const fn (program: GLuint, name: [*c]const GLchar) callconv(.c) GLint;
pub const PFNGLGETUNIFORMSUBROUTINEUIVPROC = ?*const fn (shadertype: GLenum, location: GLint, params: [*c]GLuint) callconv(.c) void;
pub const PFNGLGETUNIFORMDVPROC = ?*const fn (program: GLuint, location: GLint, params: [*c]GLdouble) callconv(.c) void;
pub const PFNGLGETUNIFORMFVPROC = ?*const fn (program: GLuint, location: GLint, params: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETUNIFORMIVPROC = ?*const fn (program: GLuint, location: GLint, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETUNIFORMUIVPROC = ?*const fn (program: GLuint, location: GLint, params: [*c]GLuint) callconv(.c) void;
pub const PFNGLGETVERTEXARRAYINDEXED64IVPROC = ?*const fn (vaobj: GLuint, index: GLuint, pname: GLenum, param: [*c]GLint64) callconv(.c) void;
pub const PFNGLGETVERTEXARRAYINDEXEDIVPROC = ?*const fn (vaobj: GLuint, index: GLuint, pname: GLenum, param: [*c]GLint) callconv(.c) void;
pub const PFNGLGETVERTEXARRAYIVPROC = ?*const fn (vaobj: GLuint, pname: GLenum, param: [*c]GLint) callconv(.c) void;
pub const PFNGLGETVERTEXATTRIBIIVPROC = ?*const fn (index: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETVERTEXATTRIBIUIVPROC = ?*const fn (index: GLuint, pname: GLenum, params: [*c]GLuint) callconv(.c) void;
pub const PFNGLGETVERTEXATTRIBLDVPROC = ?*const fn (index: GLuint, pname: GLenum, params: [*c]GLdouble) callconv(.c) void;
pub const PFNGLGETVERTEXATTRIBPOINTERVPROC = ?*const fn (index: GLuint, pname: GLenum, pointer: [*c]?*anyopaque) callconv(.c) void;
pub const PFNGLGETVERTEXATTRIBDVPROC = ?*const fn (index: GLuint, pname: GLenum, params: [*c]GLdouble) callconv(.c) void;
pub const PFNGLGETVERTEXATTRIBFVPROC = ?*const fn (index: GLuint, pname: GLenum, params: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETVERTEXATTRIBIVPROC = ?*const fn (index: GLuint, pname: GLenum, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETNCOMPRESSEDTEXIMAGEPROC = ?*const fn (target: GLenum, lod: GLint, bufSize: GLsizei, pixels: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETNTEXIMAGEPROC = ?*const fn (target: GLenum, level: GLint, format: GLenum, @"type": GLenum, bufSize: GLsizei, pixels: ?*anyopaque) callconv(.c) void;
pub const PFNGLGETNUNIFORMDVPROC = ?*const fn (program: GLuint, location: GLint, bufSize: GLsizei, params: [*c]GLdouble) callconv(.c) void;
pub const PFNGLGETNUNIFORMFVPROC = ?*const fn (program: GLuint, location: GLint, bufSize: GLsizei, params: [*c]GLfloat) callconv(.c) void;
pub const PFNGLGETNUNIFORMIVPROC = ?*const fn (program: GLuint, location: GLint, bufSize: GLsizei, params: [*c]GLint) callconv(.c) void;
pub const PFNGLGETNUNIFORMUIVPROC = ?*const fn (program: GLuint, location: GLint, bufSize: GLsizei, params: [*c]GLuint) callconv(.c) void;
pub const PFNGLHINTPROC = ?*const fn (target: GLenum, mode: GLenum) callconv(.c) void;
pub const PFNGLINVALIDATEBUFFERDATAPROC = ?*const fn (buffer: GLuint) callconv(.c) void;
pub const PFNGLINVALIDATEBUFFERSUBDATAPROC = ?*const fn (buffer: GLuint, offset: GLintptr, length: GLsizeiptr) callconv(.c) void;
pub const PFNGLINVALIDATEFRAMEBUFFERPROC = ?*const fn (target: GLenum, numAttachments: GLsizei, attachments: [*c]const GLenum) callconv(.c) void;
pub const PFNGLINVALIDATENAMEDFRAMEBUFFERDATAPROC = ?*const fn (framebuffer: GLuint, numAttachments: GLsizei, attachments: [*c]const GLenum) callconv(.c) void;
pub const PFNGLINVALIDATENAMEDFRAMEBUFFERSUBDATAPROC = ?*const fn (framebuffer: GLuint, numAttachments: GLsizei, attachments: [*c]const GLenum, x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLINVALIDATESUBFRAMEBUFFERPROC = ?*const fn (target: GLenum, numAttachments: GLsizei, attachments: [*c]const GLenum, x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLINVALIDATETEXIMAGEPROC = ?*const fn (texture: GLuint, level: GLint) callconv(.c) void;
pub const PFNGLINVALIDATETEXSUBIMAGEPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei) callconv(.c) void;
pub const PFNGLISBUFFERPROC = ?*const fn (buffer: GLuint) callconv(.c) GLboolean;
pub const PFNGLISENABLEDPROC = ?*const fn (cap: GLenum) callconv(.c) GLboolean;
pub const PFNGLISENABLEDIPROC = ?*const fn (target: GLenum, index: GLuint) callconv(.c) GLboolean;
pub const PFNGLISFRAMEBUFFERPROC = ?*const fn (framebuffer: GLuint) callconv(.c) GLboolean;
pub const PFNGLISPROGRAMPROC = ?*const fn (program: GLuint) callconv(.c) GLboolean;
pub const PFNGLISPROGRAMPIPELINEPROC = ?*const fn (pipeline: GLuint) callconv(.c) GLboolean;
pub const PFNGLISQUERYPROC = ?*const fn (id: GLuint) callconv(.c) GLboolean;
pub const PFNGLISRENDERBUFFERPROC = ?*const fn (renderbuffer: GLuint) callconv(.c) GLboolean;
pub const PFNGLISSAMPLERPROC = ?*const fn (sampler: GLuint) callconv(.c) GLboolean;
pub const PFNGLISSHADERPROC = ?*const fn (shader: GLuint) callconv(.c) GLboolean;
pub const PFNGLISSYNCPROC = ?*const fn (sync: GLsync) callconv(.c) GLboolean;
pub const PFNGLISTEXTUREPROC = ?*const fn (texture: GLuint) callconv(.c) GLboolean;
pub const PFNGLISTRANSFORMFEEDBACKPROC = ?*const fn (id: GLuint) callconv(.c) GLboolean;
pub const PFNGLISVERTEXARRAYPROC = ?*const fn (array: GLuint) callconv(.c) GLboolean;
pub const PFNGLLINEWIDTHPROC = ?*const fn (width: GLfloat) callconv(.c) void;
pub const PFNGLLINKPROGRAMPROC = ?*const fn (program: GLuint) callconv(.c) void;
pub const PFNGLLOGICOPPROC = ?*const fn (opcode: GLenum) callconv(.c) void;
pub const PFNGLMAPBUFFERPROC = ?*const fn (target: GLenum, access: GLenum) callconv(.c) ?*anyopaque;
pub const PFNGLMAPBUFFERRANGEPROC = ?*const fn (target: GLenum, offset: GLintptr, length: GLsizeiptr, access: GLbitfield) callconv(.c) ?*anyopaque;
pub const PFNGLMAPNAMEDBUFFERPROC = ?*const fn (buffer: GLuint, access: GLenum) callconv(.c) ?*anyopaque;
pub const PFNGLMAPNAMEDBUFFERRANGEPROC = ?*const fn (buffer: GLuint, offset: GLintptr, length: GLsizeiptr, access: GLbitfield) callconv(.c) ?*anyopaque;
pub const PFNGLMEMORYBARRIERPROC = ?*const fn (barriers: GLbitfield) callconv(.c) void;
pub const PFNGLMEMORYBARRIERBYREGIONPROC = ?*const fn (barriers: GLbitfield) callconv(.c) void;
pub const PFNGLMINSAMPLESHADINGPROC = ?*const fn (value: GLfloat) callconv(.c) void;
pub const PFNGLMULTIDRAWARRAYSPROC = ?*const fn (mode: GLenum, first: [*c]const GLint, count: [*c]const GLsizei, drawcount: GLsizei) callconv(.c) void;
pub const PFNGLMULTIDRAWARRAYSINDIRECTPROC = ?*const fn (mode: GLenum, indirect: ?*const anyopaque, drawcount: GLsizei, stride: GLsizei) callconv(.c) void;
pub const PFNGLMULTIDRAWARRAYSINDIRECTCOUNTPROC = ?*const fn (mode: GLenum, indirect: ?*const anyopaque, drawcount: GLintptr, maxdrawcount: GLsizei, stride: GLsizei) callconv(.c) void;
pub const PFNGLMULTIDRAWELEMENTSPROC = ?*const fn (mode: GLenum, count: [*c]const GLsizei, @"type": GLenum, indices: [*c]const ?*const anyopaque, drawcount: GLsizei) callconv(.c) void;
pub const PFNGLMULTIDRAWELEMENTSBASEVERTEXPROC = ?*const fn (mode: GLenum, count: [*c]const GLsizei, @"type": GLenum, indices: [*c]const ?*const anyopaque, drawcount: GLsizei, basevertex: [*c]const GLint) callconv(.c) void;
pub const PFNGLMULTIDRAWELEMENTSINDIRECTPROC = ?*const fn (mode: GLenum, @"type": GLenum, indirect: ?*const anyopaque, drawcount: GLsizei, stride: GLsizei) callconv(.c) void;
pub const PFNGLMULTIDRAWELEMENTSINDIRECTCOUNTPROC = ?*const fn (mode: GLenum, @"type": GLenum, indirect: ?*const anyopaque, drawcount: GLintptr, maxdrawcount: GLsizei, stride: GLsizei) callconv(.c) void;
pub const PFNGLNAMEDBUFFERDATAPROC = ?*const fn (buffer: GLuint, size: GLsizeiptr, data: ?*const anyopaque, usage: GLenum) callconv(.c) void;
pub const PFNGLNAMEDBUFFERSTORAGEPROC = ?*const fn (buffer: GLuint, size: GLsizeiptr, data: ?*const anyopaque, flags: GLbitfield) callconv(.c) void;
pub const PFNGLNAMEDBUFFERSUBDATAPROC = ?*const fn (buffer: GLuint, offset: GLintptr, size: GLsizeiptr, data: ?*const anyopaque) callconv(.c) void;
pub const PFNGLNAMEDFRAMEBUFFERDRAWBUFFERPROC = ?*const fn (framebuffer: GLuint, buf: GLenum) callconv(.c) void;
pub const PFNGLNAMEDFRAMEBUFFERDRAWBUFFERSPROC = ?*const fn (framebuffer: GLuint, n: GLsizei, bufs: [*c]const GLenum) callconv(.c) void;
pub const PFNGLNAMEDFRAMEBUFFERPARAMETERIPROC = ?*const fn (framebuffer: GLuint, pname: GLenum, param: GLint) callconv(.c) void;
pub const PFNGLNAMEDFRAMEBUFFERREADBUFFERPROC = ?*const fn (framebuffer: GLuint, src: GLenum) callconv(.c) void;
pub const PFNGLNAMEDFRAMEBUFFERRENDERBUFFERPROC = ?*const fn (framebuffer: GLuint, attachment: GLenum, renderbuffertarget: GLenum, renderbuffer: GLuint) callconv(.c) void;
pub const PFNGLNAMEDFRAMEBUFFERTEXTUREPROC = ?*const fn (framebuffer: GLuint, attachment: GLenum, texture: GLuint, level: GLint) callconv(.c) void;
pub const PFNGLNAMEDFRAMEBUFFERTEXTURELAYERPROC = ?*const fn (framebuffer: GLuint, attachment: GLenum, texture: GLuint, level: GLint, layer: GLint) callconv(.c) void;
pub const PFNGLNAMEDRENDERBUFFERSTORAGEPROC = ?*const fn (renderbuffer: GLuint, internalformat: GLenum, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLNAMEDRENDERBUFFERSTORAGEMULTISAMPLEPROC = ?*const fn (renderbuffer: GLuint, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLOBJECTLABELPROC = ?*const fn (identifier: GLenum, name: GLuint, length: GLsizei, label: [*c]const GLchar) callconv(.c) void;
pub const PFNGLOBJECTPTRLABELPROC = ?*const fn (ptr: ?*const anyopaque, length: GLsizei, label: [*c]const GLchar) callconv(.c) void;
pub const PFNGLPATCHPARAMETERFVPROC = ?*const fn (pname: GLenum, values: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPATCHPARAMETERIPROC = ?*const fn (pname: GLenum, value: GLint) callconv(.c) void;
pub const PFNGLPAUSETRANSFORMFEEDBACKPROC = ?*const fn () callconv(.c) void;
pub const PFNGLPIXELSTOREFPROC = ?*const fn (pname: GLenum, param: GLfloat) callconv(.c) void;
pub const PFNGLPIXELSTOREIPROC = ?*const fn (pname: GLenum, param: GLint) callconv(.c) void;
pub const PFNGLPOINTPARAMETERFPROC = ?*const fn (pname: GLenum, param: GLfloat) callconv(.c) void;
pub const PFNGLPOINTPARAMETERFVPROC = ?*const fn (pname: GLenum, params: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPOINTPARAMETERIPROC = ?*const fn (pname: GLenum, param: GLint) callconv(.c) void;
pub const PFNGLPOINTPARAMETERIVPROC = ?*const fn (pname: GLenum, params: [*c]const GLint) callconv(.c) void;
pub const PFNGLPOINTSIZEPROC = ?*const fn (size: GLfloat) callconv(.c) void;
pub const PFNGLPOLYGONMODEPROC = ?*const fn (face: GLenum, mode: GLenum) callconv(.c) void;
pub const PFNGLPOLYGONOFFSETPROC = ?*const fn (factor: GLfloat, units: GLfloat) callconv(.c) void;
pub const PFNGLPOLYGONOFFSETCLAMPPROC = ?*const fn (factor: GLfloat, units: GLfloat, clamp: GLfloat) callconv(.c) void;
pub const PFNGLPOPDEBUGGROUPPROC = ?*const fn () callconv(.c) void;
pub const PFNGLPRIMITIVERESTARTINDEXPROC = ?*const fn (index: GLuint) callconv(.c) void;
pub const PFNGLPROGRAMBINARYPROC = ?*const fn (program: GLuint, binaryFormat: GLenum, binary: ?*const anyopaque, length: GLsizei) callconv(.c) void;
pub const PFNGLPROGRAMPARAMETERIPROC = ?*const fn (program: GLuint, pname: GLenum, value: GLint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM1DPROC = ?*const fn (program: GLuint, location: GLint, v0: GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM1DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM1FPROC = ?*const fn (program: GLuint, location: GLint, v0: GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM1FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM1IPROC = ?*const fn (program: GLuint, location: GLint, v0: GLint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM1IVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM1UIPROC = ?*const fn (program: GLuint, location: GLint, v0: GLuint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM1UIVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM2DPROC = ?*const fn (program: GLuint, location: GLint, v0: GLdouble, v1: GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM2DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM2FPROC = ?*const fn (program: GLuint, location: GLint, v0: GLfloat, v1: GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM2FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM2IPROC = ?*const fn (program: GLuint, location: GLint, v0: GLint, v1: GLint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM2IVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM2UIPROC = ?*const fn (program: GLuint, location: GLint, v0: GLuint, v1: GLuint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM2UIVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM3DPROC = ?*const fn (program: GLuint, location: GLint, v0: GLdouble, v1: GLdouble, v2: GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM3DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM3FPROC = ?*const fn (program: GLuint, location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM3FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM3IPROC = ?*const fn (program: GLuint, location: GLint, v0: GLint, v1: GLint, v2: GLint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM3IVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM3UIPROC = ?*const fn (program: GLuint, location: GLint, v0: GLuint, v1: GLuint, v2: GLuint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM3UIVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM4DPROC = ?*const fn (program: GLuint, location: GLint, v0: GLdouble, v1: GLdouble, v2: GLdouble, v3: GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM4DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM4FPROC = ?*const fn (program: GLuint, location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat, v3: GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM4FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM4IPROC = ?*const fn (program: GLuint, location: GLint, v0: GLint, v1: GLint, v2: GLint, v3: GLint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM4IVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM4UIPROC = ?*const fn (program: GLuint, location: GLint, v0: GLuint, v1: GLuint, v2: GLuint, v3: GLuint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORM4UIVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX2DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX2FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX2X3DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX2X3FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX2X4DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX2X4FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX3DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX3FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX3X2DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX3X2FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX3X4DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX3X4FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX4DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX4FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX4X2DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX4X2FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX4X3DVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLPROGRAMUNIFORMMATRIX4X3FVPROC = ?*const fn (program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLPROVOKINGVERTEXPROC = ?*const fn (mode: GLenum) callconv(.c) void;
pub const PFNGLPUSHDEBUGGROUPPROC = ?*const fn (source: GLenum, id: GLuint, length: GLsizei, message: [*c]const GLchar) callconv(.c) void;
pub const PFNGLQUERYCOUNTERPROC = ?*const fn (id: GLuint, target: GLenum) callconv(.c) void;
pub const PFNGLREADBUFFERPROC = ?*const fn (src: GLenum) callconv(.c) void;
pub const PFNGLREADPIXELSPROC = ?*const fn (x: GLint, y: GLint, width: GLsizei, height: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*anyopaque) callconv(.c) void;
pub const PFNGLREADNPIXELSPROC = ?*const fn (x: GLint, y: GLint, width: GLsizei, height: GLsizei, format: GLenum, @"type": GLenum, bufSize: GLsizei, data: ?*anyopaque) callconv(.c) void;
pub const PFNGLRELEASESHADERCOMPILERPROC = ?*const fn () callconv(.c) void;
pub const PFNGLRENDERBUFFERSTORAGEPROC = ?*const fn (target: GLenum, internalformat: GLenum, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLRENDERBUFFERSTORAGEMULTISAMPLEPROC = ?*const fn (target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLRESUMETRANSFORMFEEDBACKPROC = ?*const fn () callconv(.c) void;
pub const PFNGLSAMPLECOVERAGEPROC = ?*const fn (value: GLfloat, invert: GLboolean) callconv(.c) void;
pub const PFNGLSAMPLEMASKIPROC = ?*const fn (maskNumber: GLuint, mask: GLbitfield) callconv(.c) void;
pub const PFNGLSAMPLERPARAMETERIIVPROC = ?*const fn (sampler: GLuint, pname: GLenum, param: [*c]const GLint) callconv(.c) void;
pub const PFNGLSAMPLERPARAMETERIUIVPROC = ?*const fn (sampler: GLuint, pname: GLenum, param: [*c]const GLuint) callconv(.c) void;
pub const PFNGLSAMPLERPARAMETERFPROC = ?*const fn (sampler: GLuint, pname: GLenum, param: GLfloat) callconv(.c) void;
pub const PFNGLSAMPLERPARAMETERFVPROC = ?*const fn (sampler: GLuint, pname: GLenum, param: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLSAMPLERPARAMETERIPROC = ?*const fn (sampler: GLuint, pname: GLenum, param: GLint) callconv(.c) void;
pub const PFNGLSAMPLERPARAMETERIVPROC = ?*const fn (sampler: GLuint, pname: GLenum, param: [*c]const GLint) callconv(.c) void;
pub const PFNGLSCISSORPROC = ?*const fn (x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLSCISSORARRAYVPROC = ?*const fn (first: GLuint, count: GLsizei, v: [*c]const GLint) callconv(.c) void;
pub const PFNGLSCISSORINDEXEDPROC = ?*const fn (index: GLuint, left: GLint, bottom: GLint, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLSCISSORINDEXEDVPROC = ?*const fn (index: GLuint, v: [*c]const GLint) callconv(.c) void;
pub const PFNGLSHADERBINARYPROC = ?*const fn (count: GLsizei, shaders: [*c]const GLuint, binaryFormat: GLenum, binary: ?*const anyopaque, length: GLsizei) callconv(.c) void;
pub const PFNGLSHADERSOURCEPROC = ?*const fn (shader: GLuint, count: GLsizei, string: [*c]const [*c]const GLchar, length: [*c]const GLint) callconv(.c) void;
pub const PFNGLSHADERSTORAGEBLOCKBINDINGPROC = ?*const fn (program: GLuint, storageBlockIndex: GLuint, storageBlockBinding: GLuint) callconv(.c) void;
pub const PFNGLSPECIALIZESHADERPROC = ?*const fn (shader: GLuint, pEntryPoint: [*c]const GLchar, numSpecializationConstants: GLuint, pConstantIndex: [*c]const GLuint, pConstantValue: [*c]const GLuint) callconv(.c) void;
pub const PFNGLSTENCILFUNCPROC = ?*const fn (func: GLenum, ref: GLint, mask: GLuint) callconv(.c) void;
pub const PFNGLSTENCILFUNCSEPARATEPROC = ?*const fn (face: GLenum, func: GLenum, ref: GLint, mask: GLuint) callconv(.c) void;
pub const PFNGLSTENCILMASKPROC = ?*const fn (mask: GLuint) callconv(.c) void;
pub const PFNGLSTENCILMASKSEPARATEPROC = ?*const fn (face: GLenum, mask: GLuint) callconv(.c) void;
pub const PFNGLSTENCILOPPROC = ?*const fn (fail: GLenum, zfail: GLenum, zpass: GLenum) callconv(.c) void;
pub const PFNGLSTENCILOPSEPARATEPROC = ?*const fn (face: GLenum, sfail: GLenum, dpfail: GLenum, dppass: GLenum) callconv(.c) void;
pub const PFNGLTEXBUFFERPROC = ?*const fn (target: GLenum, internalformat: GLenum, buffer: GLuint) callconv(.c) void;
pub const PFNGLTEXBUFFERRANGEPROC = ?*const fn (target: GLenum, internalformat: GLenum, buffer: GLuint, offset: GLintptr, size: GLsizeiptr) callconv(.c) void;
pub const PFNGLTEXIMAGE1DPROC = ?*const fn (target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, border: GLint, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) callconv(.c) void;
pub const PFNGLTEXIMAGE2DPROC = ?*const fn (target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, height: GLsizei, border: GLint, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) callconv(.c) void;
pub const PFNGLTEXIMAGE2DMULTISAMPLEPROC = ?*const fn (target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, fixedsamplelocations: GLboolean) callconv(.c) void;
pub const PFNGLTEXIMAGE3DPROC = ?*const fn (target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, border: GLint, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) callconv(.c) void;
pub const PFNGLTEXIMAGE3DMULTISAMPLEPROC = ?*const fn (target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, fixedsamplelocations: GLboolean) callconv(.c) void;
pub const PFNGLTEXPARAMETERIIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]const GLint) callconv(.c) void;
pub const PFNGLTEXPARAMETERIUIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]const GLuint) callconv(.c) void;
pub const PFNGLTEXPARAMETERFPROC = ?*const fn (target: GLenum, pname: GLenum, param: GLfloat) callconv(.c) void;
pub const PFNGLTEXPARAMETERFVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLTEXPARAMETERIPROC = ?*const fn (target: GLenum, pname: GLenum, param: GLint) callconv(.c) void;
pub const PFNGLTEXPARAMETERIVPROC = ?*const fn (target: GLenum, pname: GLenum, params: [*c]const GLint) callconv(.c) void;
pub const PFNGLTEXSTORAGE1DPROC = ?*const fn (target: GLenum, levels: GLsizei, internalformat: GLenum, width: GLsizei) callconv(.c) void;
pub const PFNGLTEXSTORAGE2DPROC = ?*const fn (target: GLenum, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLTEXSTORAGE2DMULTISAMPLEPROC = ?*const fn (target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, fixedsamplelocations: GLboolean) callconv(.c) void;
pub const PFNGLTEXSTORAGE3DPROC = ?*const fn (target: GLenum, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei) callconv(.c) void;
pub const PFNGLTEXSTORAGE3DMULTISAMPLEPROC = ?*const fn (target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, fixedsamplelocations: GLboolean) callconv(.c) void;
pub const PFNGLTEXSUBIMAGE1DPROC = ?*const fn (target: GLenum, level: GLint, xoffset: GLint, width: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) callconv(.c) void;
pub const PFNGLTEXSUBIMAGE2DPROC = ?*const fn (target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) callconv(.c) void;
pub const PFNGLTEXSUBIMAGE3DPROC = ?*const fn (target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) callconv(.c) void;
pub const PFNGLTEXTUREBARRIERPROC = ?*const fn () callconv(.c) void;
pub const PFNGLTEXTUREBUFFERPROC = ?*const fn (texture: GLuint, internalformat: GLenum, buffer: GLuint) callconv(.c) void;
pub const PFNGLTEXTUREBUFFERRANGEPROC = ?*const fn (texture: GLuint, internalformat: GLenum, buffer: GLuint, offset: GLintptr, size: GLsizeiptr) callconv(.c) void;
pub const PFNGLTEXTUREPARAMETERIIVPROC = ?*const fn (texture: GLuint, pname: GLenum, params: [*c]const GLint) callconv(.c) void;
pub const PFNGLTEXTUREPARAMETERIUIVPROC = ?*const fn (texture: GLuint, pname: GLenum, params: [*c]const GLuint) callconv(.c) void;
pub const PFNGLTEXTUREPARAMETERFPROC = ?*const fn (texture: GLuint, pname: GLenum, param: GLfloat) callconv(.c) void;
pub const PFNGLTEXTUREPARAMETERFVPROC = ?*const fn (texture: GLuint, pname: GLenum, param: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLTEXTUREPARAMETERIPROC = ?*const fn (texture: GLuint, pname: GLenum, param: GLint) callconv(.c) void;
pub const PFNGLTEXTUREPARAMETERIVPROC = ?*const fn (texture: GLuint, pname: GLenum, param: [*c]const GLint) callconv(.c) void;
pub const PFNGLTEXTURESTORAGE1DPROC = ?*const fn (texture: GLuint, levels: GLsizei, internalformat: GLenum, width: GLsizei) callconv(.c) void;
pub const PFNGLTEXTURESTORAGE2DPROC = ?*const fn (texture: GLuint, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLTEXTURESTORAGE2DMULTISAMPLEPROC = ?*const fn (texture: GLuint, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, fixedsamplelocations: GLboolean) callconv(.c) void;
pub const PFNGLTEXTURESTORAGE3DPROC = ?*const fn (texture: GLuint, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei) callconv(.c) void;
pub const PFNGLTEXTURESTORAGE3DMULTISAMPLEPROC = ?*const fn (texture: GLuint, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, fixedsamplelocations: GLboolean) callconv(.c) void;
pub const PFNGLTEXTURESUBIMAGE1DPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, width: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) callconv(.c) void;
pub const PFNGLTEXTURESUBIMAGE2DPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) callconv(.c) void;
pub const PFNGLTEXTURESUBIMAGE3DPROC = ?*const fn (texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) callconv(.c) void;
pub const PFNGLTEXTUREVIEWPROC = ?*const fn (texture: GLuint, target: GLenum, origtexture: GLuint, internalformat: GLenum, minlevel: GLuint, numlevels: GLuint, minlayer: GLuint, numlayers: GLuint) callconv(.c) void;
pub const PFNGLTRANSFORMFEEDBACKBUFFERBASEPROC = ?*const fn (xfb: GLuint, index: GLuint, buffer: GLuint) callconv(.c) void;
pub const PFNGLTRANSFORMFEEDBACKBUFFERRANGEPROC = ?*const fn (xfb: GLuint, index: GLuint, buffer: GLuint, offset: GLintptr, size: GLsizeiptr) callconv(.c) void;
pub const PFNGLTRANSFORMFEEDBACKVARYINGSPROC = ?*const fn (program: GLuint, count: GLsizei, varyings: [*c]const [*c]const GLchar, bufferMode: GLenum) callconv(.c) void;
pub const PFNGLUNIFORM1DPROC = ?*const fn (location: GLint, x: GLdouble) callconv(.c) void;
pub const PFNGLUNIFORM1DVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORM1FPROC = ?*const fn (location: GLint, v0: GLfloat) callconv(.c) void;
pub const PFNGLUNIFORM1FVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORM1IPROC = ?*const fn (location: GLint, v0: GLint) callconv(.c) void;
pub const PFNGLUNIFORM1IVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLUNIFORM1UIPROC = ?*const fn (location: GLint, v0: GLuint) callconv(.c) void;
pub const PFNGLUNIFORM1UIVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLUNIFORM2DPROC = ?*const fn (location: GLint, x: GLdouble, y: GLdouble) callconv(.c) void;
pub const PFNGLUNIFORM2DVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORM2FPROC = ?*const fn (location: GLint, v0: GLfloat, v1: GLfloat) callconv(.c) void;
pub const PFNGLUNIFORM2FVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORM2IPROC = ?*const fn (location: GLint, v0: GLint, v1: GLint) callconv(.c) void;
pub const PFNGLUNIFORM2IVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLUNIFORM2UIPROC = ?*const fn (location: GLint, v0: GLuint, v1: GLuint) callconv(.c) void;
pub const PFNGLUNIFORM2UIVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLUNIFORM3DPROC = ?*const fn (location: GLint, x: GLdouble, y: GLdouble, z: GLdouble) callconv(.c) void;
pub const PFNGLUNIFORM3DVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORM3FPROC = ?*const fn (location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) callconv(.c) void;
pub const PFNGLUNIFORM3FVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORM3IPROC = ?*const fn (location: GLint, v0: GLint, v1: GLint, v2: GLint) callconv(.c) void;
pub const PFNGLUNIFORM3IVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLUNIFORM3UIPROC = ?*const fn (location: GLint, v0: GLuint, v1: GLuint, v2: GLuint) callconv(.c) void;
pub const PFNGLUNIFORM3UIVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLUNIFORM4DPROC = ?*const fn (location: GLint, x: GLdouble, y: GLdouble, z: GLdouble, w: GLdouble) callconv(.c) void;
pub const PFNGLUNIFORM4DVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORM4FPROC = ?*const fn (location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat, v3: GLfloat) callconv(.c) void;
pub const PFNGLUNIFORM4FVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORM4IPROC = ?*const fn (location: GLint, v0: GLint, v1: GLint, v2: GLint, v3: GLint) callconv(.c) void;
pub const PFNGLUNIFORM4IVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLint) callconv(.c) void;
pub const PFNGLUNIFORM4UIPROC = ?*const fn (location: GLint, v0: GLuint, v1: GLuint, v2: GLuint, v3: GLuint) callconv(.c) void;
pub const PFNGLUNIFORM4UIVPROC = ?*const fn (location: GLint, count: GLsizei, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLUNIFORMBLOCKBINDINGPROC = ?*const fn (program: GLuint, uniformBlockIndex: GLuint, uniformBlockBinding: GLuint) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX2DVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX2FVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX2X3DVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX2X3FVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX2X4DVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX2X4FVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX3DVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX3FVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX3X2DVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX3X2FVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX3X4DVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX3X4FVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX4DVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX4FVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX4X2DVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX4X2FVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX4X3DVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLUNIFORMMATRIX4X3FVPROC = ?*const fn (location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLUNIFORMSUBROUTINESUIVPROC = ?*const fn (shadertype: GLenum, count: GLsizei, indices: [*c]const GLuint) callconv(.c) void;
pub const PFNGLUNMAPBUFFERPROC = ?*const fn (target: GLenum) callconv(.c) GLboolean;
pub const PFNGLUNMAPNAMEDBUFFERPROC = ?*const fn (buffer: GLuint) callconv(.c) GLboolean;
pub const PFNGLUSEPROGRAMPROC = ?*const fn (program: GLuint) callconv(.c) void;
pub const PFNGLUSEPROGRAMSTAGESPROC = ?*const fn (pipeline: GLuint, stages: GLbitfield, program: GLuint) callconv(.c) void;
pub const PFNGLVALIDATEPROGRAMPROC = ?*const fn (program: GLuint) callconv(.c) void;
pub const PFNGLVALIDATEPROGRAMPIPELINEPROC = ?*const fn (pipeline: GLuint) callconv(.c) void;
pub const PFNGLVERTEXARRAYATTRIBBINDINGPROC = ?*const fn (vaobj: GLuint, attribindex: GLuint, bindingindex: GLuint) callconv(.c) void;
pub const PFNGLVERTEXARRAYATTRIBFORMATPROC = ?*const fn (vaobj: GLuint, attribindex: GLuint, size: GLint, @"type": GLenum, normalized: GLboolean, relativeoffset: GLuint) callconv(.c) void;
pub const PFNGLVERTEXARRAYATTRIBIFORMATPROC = ?*const fn (vaobj: GLuint, attribindex: GLuint, size: GLint, @"type": GLenum, relativeoffset: GLuint) callconv(.c) void;
pub const PFNGLVERTEXARRAYATTRIBLFORMATPROC = ?*const fn (vaobj: GLuint, attribindex: GLuint, size: GLint, @"type": GLenum, relativeoffset: GLuint) callconv(.c) void;
pub const PFNGLVERTEXARRAYBINDINGDIVISORPROC = ?*const fn (vaobj: GLuint, bindingindex: GLuint, divisor: GLuint) callconv(.c) void;
pub const PFNGLVERTEXARRAYELEMENTBUFFERPROC = ?*const fn (vaobj: GLuint, buffer: GLuint) callconv(.c) void;
pub const PFNGLVERTEXARRAYVERTEXBUFFERPROC = ?*const fn (vaobj: GLuint, bindingindex: GLuint, buffer: GLuint, offset: GLintptr, stride: GLsizei) callconv(.c) void;
pub const PFNGLVERTEXARRAYVERTEXBUFFERSPROC = ?*const fn (vaobj: GLuint, first: GLuint, count: GLsizei, buffers: [*c]const GLuint, offsets: [*c]const GLintptr, strides: [*c]const GLsizei) callconv(.c) void;
pub const PFNGLVERTEXATTRIB1DPROC = ?*const fn (index: GLuint, x: GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIB1DVPROC = ?*const fn (index: GLuint, v: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIB1FPROC = ?*const fn (index: GLuint, x: GLfloat) callconv(.c) void;
pub const PFNGLVERTEXATTRIB1FVPROC = ?*const fn (index: GLuint, v: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLVERTEXATTRIB1SPROC = ?*const fn (index: GLuint, x: GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB1SVPROC = ?*const fn (index: GLuint, v: [*c]const GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB2DPROC = ?*const fn (index: GLuint, x: GLdouble, y: GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIB2DVPROC = ?*const fn (index: GLuint, v: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIB2FPROC = ?*const fn (index: GLuint, x: GLfloat, y: GLfloat) callconv(.c) void;
pub const PFNGLVERTEXATTRIB2FVPROC = ?*const fn (index: GLuint, v: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLVERTEXATTRIB2SPROC = ?*const fn (index: GLuint, x: GLshort, y: GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB2SVPROC = ?*const fn (index: GLuint, v: [*c]const GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB3DPROC = ?*const fn (index: GLuint, x: GLdouble, y: GLdouble, z: GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIB3DVPROC = ?*const fn (index: GLuint, v: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIB3FPROC = ?*const fn (index: GLuint, x: GLfloat, y: GLfloat, z: GLfloat) callconv(.c) void;
pub const PFNGLVERTEXATTRIB3FVPROC = ?*const fn (index: GLuint, v: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLVERTEXATTRIB3SPROC = ?*const fn (index: GLuint, x: GLshort, y: GLshort, z: GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB3SVPROC = ?*const fn (index: GLuint, v: [*c]const GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4NBVPROC = ?*const fn (index: GLuint, v: [*c]const GLbyte) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4NIVPROC = ?*const fn (index: GLuint, v: [*c]const GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4NSVPROC = ?*const fn (index: GLuint, v: [*c]const GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4NUBPROC = ?*const fn (index: GLuint, x: GLubyte, y: GLubyte, z: GLubyte, w: GLubyte) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4NUBVPROC = ?*const fn (index: GLuint, v: [*c]const GLubyte) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4NUIVPROC = ?*const fn (index: GLuint, v: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4NUSVPROC = ?*const fn (index: GLuint, v: [*c]const GLushort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4BVPROC = ?*const fn (index: GLuint, v: [*c]const GLbyte) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4DPROC = ?*const fn (index: GLuint, x: GLdouble, y: GLdouble, z: GLdouble, w: GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4DVPROC = ?*const fn (index: GLuint, v: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4FPROC = ?*const fn (index: GLuint, x: GLfloat, y: GLfloat, z: GLfloat, w: GLfloat) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4FVPROC = ?*const fn (index: GLuint, v: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4IVPROC = ?*const fn (index: GLuint, v: [*c]const GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4SPROC = ?*const fn (index: GLuint, x: GLshort, y: GLshort, z: GLshort, w: GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4SVPROC = ?*const fn (index: GLuint, v: [*c]const GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4UBVPROC = ?*const fn (index: GLuint, v: [*c]const GLubyte) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4UIVPROC = ?*const fn (index: GLuint, v: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIB4USVPROC = ?*const fn (index: GLuint, v: [*c]const GLushort) callconv(.c) void;
pub const PFNGLVERTEXATTRIBBINDINGPROC = ?*const fn (attribindex: GLuint, bindingindex: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBDIVISORPROC = ?*const fn (index: GLuint, divisor: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBFORMATPROC = ?*const fn (attribindex: GLuint, size: GLint, @"type": GLenum, normalized: GLboolean, relativeoffset: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI1IPROC = ?*const fn (index: GLuint, x: GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI1IVPROC = ?*const fn (index: GLuint, v: [*c]const GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI1UIPROC = ?*const fn (index: GLuint, x: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI1UIVPROC = ?*const fn (index: GLuint, v: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI2IPROC = ?*const fn (index: GLuint, x: GLint, y: GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI2IVPROC = ?*const fn (index: GLuint, v: [*c]const GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI2UIPROC = ?*const fn (index: GLuint, x: GLuint, y: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI2UIVPROC = ?*const fn (index: GLuint, v: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI3IPROC = ?*const fn (index: GLuint, x: GLint, y: GLint, z: GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI3IVPROC = ?*const fn (index: GLuint, v: [*c]const GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI3UIPROC = ?*const fn (index: GLuint, x: GLuint, y: GLuint, z: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI3UIVPROC = ?*const fn (index: GLuint, v: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI4BVPROC = ?*const fn (index: GLuint, v: [*c]const GLbyte) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI4IPROC = ?*const fn (index: GLuint, x: GLint, y: GLint, z: GLint, w: GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI4IVPROC = ?*const fn (index: GLuint, v: [*c]const GLint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI4SVPROC = ?*const fn (index: GLuint, v: [*c]const GLshort) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI4UBVPROC = ?*const fn (index: GLuint, v: [*c]const GLubyte) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI4UIPROC = ?*const fn (index: GLuint, x: GLuint, y: GLuint, z: GLuint, w: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI4UIVPROC = ?*const fn (index: GLuint, v: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBI4USVPROC = ?*const fn (index: GLuint, v: [*c]const GLushort) callconv(.c) void;
pub const PFNGLVERTEXATTRIBIFORMATPROC = ?*const fn (attribindex: GLuint, size: GLint, @"type": GLenum, relativeoffset: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBIPOINTERPROC = ?*const fn (index: GLuint, size: GLint, @"type": GLenum, stride: GLsizei, pointer: ?*const anyopaque) callconv(.c) void;
pub const PFNGLVERTEXATTRIBL1DPROC = ?*const fn (index: GLuint, x: GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIBL1DVPROC = ?*const fn (index: GLuint, v: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIBL2DPROC = ?*const fn (index: GLuint, x: GLdouble, y: GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIBL2DVPROC = ?*const fn (index: GLuint, v: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIBL3DPROC = ?*const fn (index: GLuint, x: GLdouble, y: GLdouble, z: GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIBL3DVPROC = ?*const fn (index: GLuint, v: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIBL4DPROC = ?*const fn (index: GLuint, x: GLdouble, y: GLdouble, z: GLdouble, w: GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIBL4DVPROC = ?*const fn (index: GLuint, v: [*c]const GLdouble) callconv(.c) void;
pub const PFNGLVERTEXATTRIBLFORMATPROC = ?*const fn (attribindex: GLuint, size: GLint, @"type": GLenum, relativeoffset: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBLPOINTERPROC = ?*const fn (index: GLuint, size: GLint, @"type": GLenum, stride: GLsizei, pointer: ?*const anyopaque) callconv(.c) void;
pub const PFNGLVERTEXATTRIBP1UIPROC = ?*const fn (index: GLuint, @"type": GLenum, normalized: GLboolean, value: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBP1UIVPROC = ?*const fn (index: GLuint, @"type": GLenum, normalized: GLboolean, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBP2UIPROC = ?*const fn (index: GLuint, @"type": GLenum, normalized: GLboolean, value: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBP2UIVPROC = ?*const fn (index: GLuint, @"type": GLenum, normalized: GLboolean, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBP3UIPROC = ?*const fn (index: GLuint, @"type": GLenum, normalized: GLboolean, value: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBP3UIVPROC = ?*const fn (index: GLuint, @"type": GLenum, normalized: GLboolean, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBP4UIPROC = ?*const fn (index: GLuint, @"type": GLenum, normalized: GLboolean, value: GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBP4UIVPROC = ?*const fn (index: GLuint, @"type": GLenum, normalized: GLboolean, value: [*c]const GLuint) callconv(.c) void;
pub const PFNGLVERTEXATTRIBPOINTERPROC = ?*const fn (index: GLuint, size: GLint, @"type": GLenum, normalized: GLboolean, stride: GLsizei, pointer: ?*const anyopaque) callconv(.c) void;
pub const PFNGLVERTEXBINDINGDIVISORPROC = ?*const fn (bindingindex: GLuint, divisor: GLuint) callconv(.c) void;
pub const PFNGLVIEWPORTPROC = ?*const fn (x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.c) void;
pub const PFNGLVIEWPORTARRAYVPROC = ?*const fn (first: GLuint, count: GLsizei, v: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLVIEWPORTINDEXEDFPROC = ?*const fn (index: GLuint, x: GLfloat, y: GLfloat, w: GLfloat, h: GLfloat) callconv(.c) void;
pub const PFNGLVIEWPORTINDEXEDFVPROC = ?*const fn (index: GLuint, v: [*c]const GLfloat) callconv(.c) void;
pub const PFNGLWAITSYNCPROC = ?*const fn (sync: GLsync, flags: GLbitfield, timeout: GLuint64) callconv(.c) void;
pub extern var glad_glActiveShaderProgram: PFNGLACTIVESHADERPROGRAMPROC;
pub extern var glad_glActiveTexture: PFNGLACTIVETEXTUREPROC;
pub extern var glad_glAttachShader: PFNGLATTACHSHADERPROC;
pub extern var glad_glBeginConditionalRender: PFNGLBEGINCONDITIONALRENDERPROC;
pub extern var glad_glBeginQuery: PFNGLBEGINQUERYPROC;
pub extern var glad_glBeginQueryIndexed: PFNGLBEGINQUERYINDEXEDPROC;
pub extern var glad_glBeginTransformFeedback: PFNGLBEGINTRANSFORMFEEDBACKPROC;
pub extern var glad_glBindAttribLocation: PFNGLBINDATTRIBLOCATIONPROC;
pub extern var glad_glBindBuffer: PFNGLBINDBUFFERPROC;
pub extern var glad_glBindBufferBase: PFNGLBINDBUFFERBASEPROC;
pub extern var glad_glBindBufferRange: PFNGLBINDBUFFERRANGEPROC;
pub extern var glad_glBindBuffersBase: PFNGLBINDBUFFERSBASEPROC;
pub extern var glad_glBindBuffersRange: PFNGLBINDBUFFERSRANGEPROC;
pub extern var glad_glBindFragDataLocation: PFNGLBINDFRAGDATALOCATIONPROC;
pub extern var glad_glBindFragDataLocationIndexed: PFNGLBINDFRAGDATALOCATIONINDEXEDPROC;
pub extern var glad_glBindFramebuffer: PFNGLBINDFRAMEBUFFERPROC;
pub extern var glad_glBindImageTexture: PFNGLBINDIMAGETEXTUREPROC;
pub extern var glad_glBindImageTextures: PFNGLBINDIMAGETEXTURESPROC;
pub extern var glad_glBindProgramPipeline: PFNGLBINDPROGRAMPIPELINEPROC;
pub extern var glad_glBindRenderbuffer: PFNGLBINDRENDERBUFFERPROC;
pub extern var glad_glBindSampler: PFNGLBINDSAMPLERPROC;
pub extern var glad_glBindSamplers: PFNGLBINDSAMPLERSPROC;
pub extern var glad_glBindTexture: PFNGLBINDTEXTUREPROC;
pub extern var glad_glBindTextureUnit: PFNGLBINDTEXTUREUNITPROC;
pub extern var glad_glBindTextures: PFNGLBINDTEXTURESPROC;
pub extern var glad_glBindTransformFeedback: PFNGLBINDTRANSFORMFEEDBACKPROC;
pub extern var glad_glBindVertexArray: PFNGLBINDVERTEXARRAYPROC;
pub extern var glad_glBindVertexBuffer: PFNGLBINDVERTEXBUFFERPROC;
pub extern var glad_glBindVertexBuffers: PFNGLBINDVERTEXBUFFERSPROC;
pub extern var glad_glBlendColor: PFNGLBLENDCOLORPROC;
pub extern var glad_glBlendEquation: PFNGLBLENDEQUATIONPROC;
pub extern var glad_glBlendEquationSeparate: PFNGLBLENDEQUATIONSEPARATEPROC;
pub extern var glad_glBlendEquationSeparatei: PFNGLBLENDEQUATIONSEPARATEIPROC;
pub extern var glad_glBlendEquationi: PFNGLBLENDEQUATIONIPROC;
pub extern var glad_glBlendFunc: PFNGLBLENDFUNCPROC;
pub extern var glad_glBlendFuncSeparate: PFNGLBLENDFUNCSEPARATEPROC;
pub extern var glad_glBlendFuncSeparatei: PFNGLBLENDFUNCSEPARATEIPROC;
pub extern var glad_glBlendFunci: PFNGLBLENDFUNCIPROC;
pub extern var glad_glBlitFramebuffer: PFNGLBLITFRAMEBUFFERPROC;
pub extern var glad_glBlitNamedFramebuffer: PFNGLBLITNAMEDFRAMEBUFFERPROC;
pub extern var glad_glBufferData: PFNGLBUFFERDATAPROC;
pub extern var glad_glBufferStorage: PFNGLBUFFERSTORAGEPROC;
pub extern var glad_glBufferSubData: PFNGLBUFFERSUBDATAPROC;
pub extern var glad_glCheckFramebufferStatus: PFNGLCHECKFRAMEBUFFERSTATUSPROC;
pub extern var glad_glCheckNamedFramebufferStatus: PFNGLCHECKNAMEDFRAMEBUFFERSTATUSPROC;
pub extern var glad_glClampColor: PFNGLCLAMPCOLORPROC;
pub extern var glad_glClear: PFNGLCLEARPROC;
pub extern var glad_glClearBufferData: PFNGLCLEARBUFFERDATAPROC;
pub extern var glad_glClearBufferSubData: PFNGLCLEARBUFFERSUBDATAPROC;
pub extern var glad_glClearBufferfi: PFNGLCLEARBUFFERFIPROC;
pub extern var glad_glClearBufferfv: PFNGLCLEARBUFFERFVPROC;
pub extern var glad_glClearBufferiv: PFNGLCLEARBUFFERIVPROC;
pub extern var glad_glClearBufferuiv: PFNGLCLEARBUFFERUIVPROC;
pub extern var glad_glClearColor: PFNGLCLEARCOLORPROC;
pub extern var glad_glClearDepth: PFNGLCLEARDEPTHPROC;
pub extern var glad_glClearDepthf: PFNGLCLEARDEPTHFPROC;
pub extern var glad_glClearNamedBufferData: PFNGLCLEARNAMEDBUFFERDATAPROC;
pub extern var glad_glClearNamedBufferSubData: PFNGLCLEARNAMEDBUFFERSUBDATAPROC;
pub extern var glad_glClearNamedFramebufferfi: PFNGLCLEARNAMEDFRAMEBUFFERFIPROC;
pub extern var glad_glClearNamedFramebufferfv: PFNGLCLEARNAMEDFRAMEBUFFERFVPROC;
pub extern var glad_glClearNamedFramebufferiv: PFNGLCLEARNAMEDFRAMEBUFFERIVPROC;
pub extern var glad_glClearNamedFramebufferuiv: PFNGLCLEARNAMEDFRAMEBUFFERUIVPROC;
pub extern var glad_glClearStencil: PFNGLCLEARSTENCILPROC;
pub extern var glad_glClearTexImage: PFNGLCLEARTEXIMAGEPROC;
pub extern var glad_glClearTexSubImage: PFNGLCLEARTEXSUBIMAGEPROC;
pub extern var glad_glClientWaitSync: PFNGLCLIENTWAITSYNCPROC;
pub extern var glad_glClipControl: PFNGLCLIPCONTROLPROC;
pub extern var glad_glColorMask: PFNGLCOLORMASKPROC;
pub extern var glad_glColorMaski: PFNGLCOLORMASKIPROC;
pub extern var glad_glCompileShader: PFNGLCOMPILESHADERPROC;
pub extern var glad_glCompressedTexImage1D: PFNGLCOMPRESSEDTEXIMAGE1DPROC;
pub extern var glad_glCompressedTexImage2D: PFNGLCOMPRESSEDTEXIMAGE2DPROC;
pub extern var glad_glCompressedTexImage3D: PFNGLCOMPRESSEDTEXIMAGE3DPROC;
pub extern var glad_glCompressedTexSubImage1D: PFNGLCOMPRESSEDTEXSUBIMAGE1DPROC;
pub extern var glad_glCompressedTexSubImage2D: PFNGLCOMPRESSEDTEXSUBIMAGE2DPROC;
pub extern var glad_glCompressedTexSubImage3D: PFNGLCOMPRESSEDTEXSUBIMAGE3DPROC;
pub extern var glad_glCompressedTextureSubImage1D: PFNGLCOMPRESSEDTEXTURESUBIMAGE1DPROC;
pub extern var glad_glCompressedTextureSubImage2D: PFNGLCOMPRESSEDTEXTURESUBIMAGE2DPROC;
pub extern var glad_glCompressedTextureSubImage3D: PFNGLCOMPRESSEDTEXTURESUBIMAGE3DPROC;
pub extern var glad_glCopyBufferSubData: PFNGLCOPYBUFFERSUBDATAPROC;
pub extern var glad_glCopyImageSubData: PFNGLCOPYIMAGESUBDATAPROC;
pub extern var glad_glCopyNamedBufferSubData: PFNGLCOPYNAMEDBUFFERSUBDATAPROC;
pub extern var glad_glCopyTexImage1D: PFNGLCOPYTEXIMAGE1DPROC;
pub extern var glad_glCopyTexImage2D: PFNGLCOPYTEXIMAGE2DPROC;
pub extern var glad_glCopyTexSubImage1D: PFNGLCOPYTEXSUBIMAGE1DPROC;
pub extern var glad_glCopyTexSubImage2D: PFNGLCOPYTEXSUBIMAGE2DPROC;
pub extern var glad_glCopyTexSubImage3D: PFNGLCOPYTEXSUBIMAGE3DPROC;
pub extern var glad_glCopyTextureSubImage1D: PFNGLCOPYTEXTURESUBIMAGE1DPROC;
pub extern var glad_glCopyTextureSubImage2D: PFNGLCOPYTEXTURESUBIMAGE2DPROC;
pub extern var glad_glCopyTextureSubImage3D: PFNGLCOPYTEXTURESUBIMAGE3DPROC;
pub extern var glad_glCreateBuffers: PFNGLCREATEBUFFERSPROC;
pub extern var glad_glCreateFramebuffers: PFNGLCREATEFRAMEBUFFERSPROC;
pub extern var glad_glCreateProgram: PFNGLCREATEPROGRAMPROC;
pub extern var glad_glCreateProgramPipelines: PFNGLCREATEPROGRAMPIPELINESPROC;
pub extern var glad_glCreateQueries: PFNGLCREATEQUERIESPROC;
pub extern var glad_glCreateRenderbuffers: PFNGLCREATERENDERBUFFERSPROC;
pub extern var glad_glCreateSamplers: PFNGLCREATESAMPLERSPROC;
pub extern var glad_glCreateShader: PFNGLCREATESHADERPROC;
pub extern var glad_glCreateShaderProgramv: PFNGLCREATESHADERPROGRAMVPROC;
pub extern var glad_glCreateTextures: PFNGLCREATETEXTURESPROC;
pub extern var glad_glCreateTransformFeedbacks: PFNGLCREATETRANSFORMFEEDBACKSPROC;
pub extern var glad_glCreateVertexArrays: PFNGLCREATEVERTEXARRAYSPROC;
pub extern var glad_glCullFace: PFNGLCULLFACEPROC;
pub extern var glad_glDebugMessageCallback: PFNGLDEBUGMESSAGECALLBACKPROC;
pub extern var glad_glDebugMessageControl: PFNGLDEBUGMESSAGECONTROLPROC;
pub extern var glad_glDebugMessageInsert: PFNGLDEBUGMESSAGEINSERTPROC;
pub extern var glad_glDeleteBuffers: PFNGLDELETEBUFFERSPROC;
pub extern var glad_glDeleteFramebuffers: PFNGLDELETEFRAMEBUFFERSPROC;
pub extern var glad_glDeleteProgram: PFNGLDELETEPROGRAMPROC;
pub extern var glad_glDeleteProgramPipelines: PFNGLDELETEPROGRAMPIPELINESPROC;
pub extern var glad_glDeleteQueries: PFNGLDELETEQUERIESPROC;
pub extern var glad_glDeleteRenderbuffers: PFNGLDELETERENDERBUFFERSPROC;
pub extern var glad_glDeleteSamplers: PFNGLDELETESAMPLERSPROC;
pub extern var glad_glDeleteShader: PFNGLDELETESHADERPROC;
pub extern var glad_glDeleteSync: PFNGLDELETESYNCPROC;
pub extern var glad_glDeleteTextures: PFNGLDELETETEXTURESPROC;
pub extern var glad_glDeleteTransformFeedbacks: PFNGLDELETETRANSFORMFEEDBACKSPROC;
pub extern var glad_glDeleteVertexArrays: PFNGLDELETEVERTEXARRAYSPROC;
pub extern var glad_glDepthFunc: PFNGLDEPTHFUNCPROC;
pub extern var glad_glDepthMask: PFNGLDEPTHMASKPROC;
pub extern var glad_glDepthRange: PFNGLDEPTHRANGEPROC;
pub extern var glad_glDepthRangeArrayv: PFNGLDEPTHRANGEARRAYVPROC;
pub extern var glad_glDepthRangeIndexed: PFNGLDEPTHRANGEINDEXEDPROC;
pub extern var glad_glDepthRangef: PFNGLDEPTHRANGEFPROC;
pub extern var glad_glDetachShader: PFNGLDETACHSHADERPROC;
pub extern var glad_glDisable: PFNGLDISABLEPROC;
pub extern var glad_glDisableVertexArrayAttrib: PFNGLDISABLEVERTEXARRAYATTRIBPROC;
pub extern var glad_glDisableVertexAttribArray: PFNGLDISABLEVERTEXATTRIBARRAYPROC;
pub extern var glad_glDisablei: PFNGLDISABLEIPROC;
pub extern var glad_glDispatchCompute: PFNGLDISPATCHCOMPUTEPROC;
pub extern var glad_glDispatchComputeIndirect: PFNGLDISPATCHCOMPUTEINDIRECTPROC;
pub extern var glad_glDrawArrays: PFNGLDRAWARRAYSPROC;
pub extern var glad_glDrawArraysIndirect: PFNGLDRAWARRAYSINDIRECTPROC;
pub extern var glad_glDrawArraysInstanced: PFNGLDRAWARRAYSINSTANCEDPROC;
pub extern var glad_glDrawArraysInstancedBaseInstance: PFNGLDRAWARRAYSINSTANCEDBASEINSTANCEPROC;
pub extern var glad_glDrawBuffer: PFNGLDRAWBUFFERPROC;
pub extern var glad_glDrawBuffers: PFNGLDRAWBUFFERSPROC;
pub extern var glad_glDrawElements: PFNGLDRAWELEMENTSPROC;
pub extern var glad_glDrawElementsBaseVertex: PFNGLDRAWELEMENTSBASEVERTEXPROC;
pub extern var glad_glDrawElementsIndirect: PFNGLDRAWELEMENTSINDIRECTPROC;
pub extern var glad_glDrawElementsInstanced: PFNGLDRAWELEMENTSINSTANCEDPROC;
pub extern var glad_glDrawElementsInstancedBaseInstance: PFNGLDRAWELEMENTSINSTANCEDBASEINSTANCEPROC;
pub extern var glad_glDrawElementsInstancedBaseVertex: PFNGLDRAWELEMENTSINSTANCEDBASEVERTEXPROC;
pub extern var glad_glDrawElementsInstancedBaseVertexBaseInstance: PFNGLDRAWELEMENTSINSTANCEDBASEVERTEXBASEINSTANCEPROC;
pub extern var glad_glDrawRangeElements: PFNGLDRAWRANGEELEMENTSPROC;
pub extern var glad_glDrawRangeElementsBaseVertex: PFNGLDRAWRANGEELEMENTSBASEVERTEXPROC;
pub extern var glad_glDrawTransformFeedback: PFNGLDRAWTRANSFORMFEEDBACKPROC;
pub extern var glad_glDrawTransformFeedbackInstanced: PFNGLDRAWTRANSFORMFEEDBACKINSTANCEDPROC;
pub extern var glad_glDrawTransformFeedbackStream: PFNGLDRAWTRANSFORMFEEDBACKSTREAMPROC;
pub extern var glad_glDrawTransformFeedbackStreamInstanced: PFNGLDRAWTRANSFORMFEEDBACKSTREAMINSTANCEDPROC;
pub extern var glad_glEnable: PFNGLENABLEPROC;
pub extern var glad_glEnableVertexArrayAttrib: PFNGLENABLEVERTEXARRAYATTRIBPROC;
pub extern var glad_glEnableVertexAttribArray: PFNGLENABLEVERTEXATTRIBARRAYPROC;
pub extern var glad_glEnablei: PFNGLENABLEIPROC;
pub extern var glad_glEndConditionalRender: PFNGLENDCONDITIONALRENDERPROC;
pub extern var glad_glEndQuery: PFNGLENDQUERYPROC;
pub extern var glad_glEndQueryIndexed: PFNGLENDQUERYINDEXEDPROC;
pub extern var glad_glEndTransformFeedback: PFNGLENDTRANSFORMFEEDBACKPROC;
pub extern var glad_glFenceSync: PFNGLFENCESYNCPROC;
pub extern var glad_glFinish: PFNGLFINISHPROC;
pub extern var glad_glFlush: PFNGLFLUSHPROC;
pub extern var glad_glFlushMappedBufferRange: PFNGLFLUSHMAPPEDBUFFERRANGEPROC;
pub extern var glad_glFlushMappedNamedBufferRange: PFNGLFLUSHMAPPEDNAMEDBUFFERRANGEPROC;
pub extern var glad_glFramebufferParameteri: PFNGLFRAMEBUFFERPARAMETERIPROC;
pub extern var glad_glFramebufferRenderbuffer: PFNGLFRAMEBUFFERRENDERBUFFERPROC;
pub extern var glad_glFramebufferTexture: PFNGLFRAMEBUFFERTEXTUREPROC;
pub extern var glad_glFramebufferTexture1D: PFNGLFRAMEBUFFERTEXTURE1DPROC;
pub extern var glad_glFramebufferTexture2D: PFNGLFRAMEBUFFERTEXTURE2DPROC;
pub extern var glad_glFramebufferTexture3D: PFNGLFRAMEBUFFERTEXTURE3DPROC;
pub extern var glad_glFramebufferTextureLayer: PFNGLFRAMEBUFFERTEXTURELAYERPROC;
pub extern var glad_glFrontFace: PFNGLFRONTFACEPROC;
pub extern var glad_glGenBuffers: PFNGLGENBUFFERSPROC;
pub extern var glad_glGenFramebuffers: PFNGLGENFRAMEBUFFERSPROC;
pub extern var glad_glGenProgramPipelines: PFNGLGENPROGRAMPIPELINESPROC;
pub extern var glad_glGenQueries: PFNGLGENQUERIESPROC;
pub extern var glad_glGenRenderbuffers: PFNGLGENRENDERBUFFERSPROC;
pub extern var glad_glGenSamplers: PFNGLGENSAMPLERSPROC;
pub extern var glad_glGenTextures: PFNGLGENTEXTURESPROC;
pub extern var glad_glGenTransformFeedbacks: PFNGLGENTRANSFORMFEEDBACKSPROC;
pub extern var glad_glGenVertexArrays: PFNGLGENVERTEXARRAYSPROC;
pub extern var glad_glGenerateMipmap: PFNGLGENERATEMIPMAPPROC;
pub extern var glad_glGenerateTextureMipmap: PFNGLGENERATETEXTUREMIPMAPPROC;
pub extern var glad_glGetActiveAtomicCounterBufferiv: PFNGLGETACTIVEATOMICCOUNTERBUFFERIVPROC;
pub extern var glad_glGetActiveAttrib: PFNGLGETACTIVEATTRIBPROC;
pub extern var glad_glGetActiveSubroutineName: PFNGLGETACTIVESUBROUTINENAMEPROC;
pub extern var glad_glGetActiveSubroutineUniformName: PFNGLGETACTIVESUBROUTINEUNIFORMNAMEPROC;
pub extern var glad_glGetActiveSubroutineUniformiv: PFNGLGETACTIVESUBROUTINEUNIFORMIVPROC;
pub extern var glad_glGetActiveUniform: PFNGLGETACTIVEUNIFORMPROC;
pub extern var glad_glGetActiveUniformBlockName: PFNGLGETACTIVEUNIFORMBLOCKNAMEPROC;
pub extern var glad_glGetActiveUniformBlockiv: PFNGLGETACTIVEUNIFORMBLOCKIVPROC;
pub extern var glad_glGetActiveUniformName: PFNGLGETACTIVEUNIFORMNAMEPROC;
pub extern var glad_glGetActiveUniformsiv: PFNGLGETACTIVEUNIFORMSIVPROC;
pub extern var glad_glGetAttachedShaders: PFNGLGETATTACHEDSHADERSPROC;
pub extern var glad_glGetAttribLocation: PFNGLGETATTRIBLOCATIONPROC;
pub extern var glad_glGetBooleani_v: PFNGLGETBOOLEANI_VPROC;
pub extern var glad_glGetBooleanv: PFNGLGETBOOLEANVPROC;
pub extern var glad_glGetBufferParameteri64v: PFNGLGETBUFFERPARAMETERI64VPROC;
pub extern var glad_glGetBufferParameteriv: PFNGLGETBUFFERPARAMETERIVPROC;
pub extern var glad_glGetBufferPointerv: PFNGLGETBUFFERPOINTERVPROC;
pub extern var glad_glGetBufferSubData: PFNGLGETBUFFERSUBDATAPROC;
pub extern var glad_glGetCompressedTexImage: PFNGLGETCOMPRESSEDTEXIMAGEPROC;
pub extern var glad_glGetCompressedTextureImage: PFNGLGETCOMPRESSEDTEXTUREIMAGEPROC;
pub extern var glad_glGetCompressedTextureSubImage: PFNGLGETCOMPRESSEDTEXTURESUBIMAGEPROC;
pub extern var glad_glGetDebugMessageLog: PFNGLGETDEBUGMESSAGELOGPROC;
pub extern var glad_glGetDoublei_v: PFNGLGETDOUBLEI_VPROC;
pub extern var glad_glGetDoublev: PFNGLGETDOUBLEVPROC;
pub extern var glad_glGetError: PFNGLGETERRORPROC;
pub extern var glad_glGetFloati_v: PFNGLGETFLOATI_VPROC;
pub extern var glad_glGetFloatv: PFNGLGETFLOATVPROC;
pub extern var glad_glGetFragDataIndex: PFNGLGETFRAGDATAINDEXPROC;
pub extern var glad_glGetFragDataLocation: PFNGLGETFRAGDATALOCATIONPROC;
pub extern var glad_glGetFramebufferAttachmentParameteriv: PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVPROC;
pub extern var glad_glGetFramebufferParameteriv: PFNGLGETFRAMEBUFFERPARAMETERIVPROC;
pub extern var glad_glGetGraphicsResetStatus: PFNGLGETGRAPHICSRESETSTATUSPROC;
pub extern var glad_glGetInteger64i_v: PFNGLGETINTEGER64I_VPROC;
pub extern var glad_glGetInteger64v: PFNGLGETINTEGER64VPROC;
pub extern var glad_glGetIntegeri_v: PFNGLGETINTEGERI_VPROC;
pub extern var glad_glGetIntegerv: PFNGLGETINTEGERVPROC;
pub extern var glad_glGetInternalformati64v: PFNGLGETINTERNALFORMATI64VPROC;
pub extern var glad_glGetInternalformativ: PFNGLGETINTERNALFORMATIVPROC;
pub extern var glad_glGetMultisamplefv: PFNGLGETMULTISAMPLEFVPROC;
pub extern var glad_glGetNamedBufferParameteri64v: PFNGLGETNAMEDBUFFERPARAMETERI64VPROC;
pub extern var glad_glGetNamedBufferParameteriv: PFNGLGETNAMEDBUFFERPARAMETERIVPROC;
pub extern var glad_glGetNamedBufferPointerv: PFNGLGETNAMEDBUFFERPOINTERVPROC;
pub extern var glad_glGetNamedBufferSubData: PFNGLGETNAMEDBUFFERSUBDATAPROC;
pub extern var glad_glGetNamedFramebufferAttachmentParameteriv: PFNGLGETNAMEDFRAMEBUFFERATTACHMENTPARAMETERIVPROC;
pub extern var glad_glGetNamedFramebufferParameteriv: PFNGLGETNAMEDFRAMEBUFFERPARAMETERIVPROC;
pub extern var glad_glGetNamedRenderbufferParameteriv: PFNGLGETNAMEDRENDERBUFFERPARAMETERIVPROC;
pub extern var glad_glGetObjectLabel: PFNGLGETOBJECTLABELPROC;
pub extern var glad_glGetObjectPtrLabel: PFNGLGETOBJECTPTRLABELPROC;
pub extern var glad_glGetPointerv: PFNGLGETPOINTERVPROC;
pub extern var glad_glGetProgramBinary: PFNGLGETPROGRAMBINARYPROC;
pub extern var glad_glGetProgramInfoLog: PFNGLGETPROGRAMINFOLOGPROC;
pub extern var glad_glGetProgramInterfaceiv: PFNGLGETPROGRAMINTERFACEIVPROC;
pub extern var glad_glGetProgramPipelineInfoLog: PFNGLGETPROGRAMPIPELINEINFOLOGPROC;
pub extern var glad_glGetProgramPipelineiv: PFNGLGETPROGRAMPIPELINEIVPROC;
pub extern var glad_glGetProgramResourceIndex: PFNGLGETPROGRAMRESOURCEINDEXPROC;
pub extern var glad_glGetProgramResourceLocation: PFNGLGETPROGRAMRESOURCELOCATIONPROC;
pub extern var glad_glGetProgramResourceLocationIndex: PFNGLGETPROGRAMRESOURCELOCATIONINDEXPROC;
pub extern var glad_glGetProgramResourceName: PFNGLGETPROGRAMRESOURCENAMEPROC;
pub extern var glad_glGetProgramResourceiv: PFNGLGETPROGRAMRESOURCEIVPROC;
pub extern var glad_glGetProgramStageiv: PFNGLGETPROGRAMSTAGEIVPROC;
pub extern var glad_glGetProgramiv: PFNGLGETPROGRAMIVPROC;
pub extern var glad_glGetQueryBufferObjecti64v: PFNGLGETQUERYBUFFEROBJECTI64VPROC;
pub extern var glad_glGetQueryBufferObjectiv: PFNGLGETQUERYBUFFEROBJECTIVPROC;
pub extern var glad_glGetQueryBufferObjectui64v: PFNGLGETQUERYBUFFEROBJECTUI64VPROC;
pub extern var glad_glGetQueryBufferObjectuiv: PFNGLGETQUERYBUFFEROBJECTUIVPROC;
pub extern var glad_glGetQueryIndexediv: PFNGLGETQUERYINDEXEDIVPROC;
pub extern var glad_glGetQueryObjecti64v: PFNGLGETQUERYOBJECTI64VPROC;
pub extern var glad_glGetQueryObjectiv: PFNGLGETQUERYOBJECTIVPROC;
pub extern var glad_glGetQueryObjectui64v: PFNGLGETQUERYOBJECTUI64VPROC;
pub extern var glad_glGetQueryObjectuiv: PFNGLGETQUERYOBJECTUIVPROC;
pub extern var glad_glGetQueryiv: PFNGLGETQUERYIVPROC;
pub extern var glad_glGetRenderbufferParameteriv: PFNGLGETRENDERBUFFERPARAMETERIVPROC;
pub extern var glad_glGetSamplerParameterIiv: PFNGLGETSAMPLERPARAMETERIIVPROC;
pub extern var glad_glGetSamplerParameterIuiv: PFNGLGETSAMPLERPARAMETERIUIVPROC;
pub extern var glad_glGetSamplerParameterfv: PFNGLGETSAMPLERPARAMETERFVPROC;
pub extern var glad_glGetSamplerParameteriv: PFNGLGETSAMPLERPARAMETERIVPROC;
pub extern var glad_glGetShaderInfoLog: PFNGLGETSHADERINFOLOGPROC;
pub extern var glad_glGetShaderPrecisionFormat: PFNGLGETSHADERPRECISIONFORMATPROC;
pub extern var glad_glGetShaderSource: PFNGLGETSHADERSOURCEPROC;
pub extern var glad_glGetShaderiv: PFNGLGETSHADERIVPROC;
pub extern var glad_glGetString: PFNGLGETSTRINGPROC;
pub extern var glad_glGetStringi: PFNGLGETSTRINGIPROC;
pub extern var glad_glGetSubroutineIndex: PFNGLGETSUBROUTINEINDEXPROC;
pub extern var glad_glGetSubroutineUniformLocation: PFNGLGETSUBROUTINEUNIFORMLOCATIONPROC;
pub extern var glad_glGetSynciv: PFNGLGETSYNCIVPROC;
pub extern var glad_glGetTexImage: PFNGLGETTEXIMAGEPROC;
pub extern var glad_glGetTexLevelParameterfv: PFNGLGETTEXLEVELPARAMETERFVPROC;
pub extern var glad_glGetTexLevelParameteriv: PFNGLGETTEXLEVELPARAMETERIVPROC;
pub extern var glad_glGetTexParameterIiv: PFNGLGETTEXPARAMETERIIVPROC;
pub extern var glad_glGetTexParameterIuiv: PFNGLGETTEXPARAMETERIUIVPROC;
pub extern var glad_glGetTexParameterfv: PFNGLGETTEXPARAMETERFVPROC;
pub extern var glad_glGetTexParameteriv: PFNGLGETTEXPARAMETERIVPROC;
pub extern var glad_glGetTextureImage: PFNGLGETTEXTUREIMAGEPROC;
pub extern var glad_glGetTextureLevelParameterfv: PFNGLGETTEXTURELEVELPARAMETERFVPROC;
pub extern var glad_glGetTextureLevelParameteriv: PFNGLGETTEXTURELEVELPARAMETERIVPROC;
pub extern var glad_glGetTextureParameterIiv: PFNGLGETTEXTUREPARAMETERIIVPROC;
pub extern var glad_glGetTextureParameterIuiv: PFNGLGETTEXTUREPARAMETERIUIVPROC;
pub extern var glad_glGetTextureParameterfv: PFNGLGETTEXTUREPARAMETERFVPROC;
pub extern var glad_glGetTextureParameteriv: PFNGLGETTEXTUREPARAMETERIVPROC;
pub extern var glad_glGetTextureSubImage: PFNGLGETTEXTURESUBIMAGEPROC;
pub extern var glad_glGetTransformFeedbackVarying: PFNGLGETTRANSFORMFEEDBACKVARYINGPROC;
pub extern var glad_glGetTransformFeedbacki64_v: PFNGLGETTRANSFORMFEEDBACKI64_VPROC;
pub extern var glad_glGetTransformFeedbacki_v: PFNGLGETTRANSFORMFEEDBACKI_VPROC;
pub extern var glad_glGetTransformFeedbackiv: PFNGLGETTRANSFORMFEEDBACKIVPROC;
pub extern var glad_glGetUniformBlockIndex: PFNGLGETUNIFORMBLOCKINDEXPROC;
pub extern var glad_glGetUniformIndices: PFNGLGETUNIFORMINDICESPROC;
pub extern var glad_glGetUniformLocation: PFNGLGETUNIFORMLOCATIONPROC;
pub extern var glad_glGetUniformSubroutineuiv: PFNGLGETUNIFORMSUBROUTINEUIVPROC;
pub extern var glad_glGetUniformdv: PFNGLGETUNIFORMDVPROC;
pub extern var glad_glGetUniformfv: PFNGLGETUNIFORMFVPROC;
pub extern var glad_glGetUniformiv: PFNGLGETUNIFORMIVPROC;
pub extern var glad_glGetUniformuiv: PFNGLGETUNIFORMUIVPROC;
pub extern var glad_glGetVertexArrayIndexed64iv: PFNGLGETVERTEXARRAYINDEXED64IVPROC;
pub extern var glad_glGetVertexArrayIndexediv: PFNGLGETVERTEXARRAYINDEXEDIVPROC;
pub extern var glad_glGetVertexArrayiv: PFNGLGETVERTEXARRAYIVPROC;
pub extern var glad_glGetVertexAttribIiv: PFNGLGETVERTEXATTRIBIIVPROC;
pub extern var glad_glGetVertexAttribIuiv: PFNGLGETVERTEXATTRIBIUIVPROC;
pub extern var glad_glGetVertexAttribLdv: PFNGLGETVERTEXATTRIBLDVPROC;
pub extern var glad_glGetVertexAttribPointerv: PFNGLGETVERTEXATTRIBPOINTERVPROC;
pub extern var glad_glGetVertexAttribdv: PFNGLGETVERTEXATTRIBDVPROC;
pub extern var glad_glGetVertexAttribfv: PFNGLGETVERTEXATTRIBFVPROC;
pub extern var glad_glGetVertexAttribiv: PFNGLGETVERTEXATTRIBIVPROC;
pub extern var glad_glGetnCompressedTexImage: PFNGLGETNCOMPRESSEDTEXIMAGEPROC;
pub extern var glad_glGetnTexImage: PFNGLGETNTEXIMAGEPROC;
pub extern var glad_glGetnUniformdv: PFNGLGETNUNIFORMDVPROC;
pub extern var glad_glGetnUniformfv: PFNGLGETNUNIFORMFVPROC;
pub extern var glad_glGetnUniformiv: PFNGLGETNUNIFORMIVPROC;
pub extern var glad_glGetnUniformuiv: PFNGLGETNUNIFORMUIVPROC;
pub extern var glad_glHint: PFNGLHINTPROC;
pub extern var glad_glInvalidateBufferData: PFNGLINVALIDATEBUFFERDATAPROC;
pub extern var glad_glInvalidateBufferSubData: PFNGLINVALIDATEBUFFERSUBDATAPROC;
pub extern var glad_glInvalidateFramebuffer: PFNGLINVALIDATEFRAMEBUFFERPROC;
pub extern var glad_glInvalidateNamedFramebufferData: PFNGLINVALIDATENAMEDFRAMEBUFFERDATAPROC;
pub extern var glad_glInvalidateNamedFramebufferSubData: PFNGLINVALIDATENAMEDFRAMEBUFFERSUBDATAPROC;
pub extern var glad_glInvalidateSubFramebuffer: PFNGLINVALIDATESUBFRAMEBUFFERPROC;
pub extern var glad_glInvalidateTexImage: PFNGLINVALIDATETEXIMAGEPROC;
pub extern var glad_glInvalidateTexSubImage: PFNGLINVALIDATETEXSUBIMAGEPROC;
pub extern var glad_glIsBuffer: PFNGLISBUFFERPROC;
pub extern var glad_glIsEnabled: PFNGLISENABLEDPROC;
pub extern var glad_glIsEnabledi: PFNGLISENABLEDIPROC;
pub extern var glad_glIsFramebuffer: PFNGLISFRAMEBUFFERPROC;
pub extern var glad_glIsProgram: PFNGLISPROGRAMPROC;
pub extern var glad_glIsProgramPipeline: PFNGLISPROGRAMPIPELINEPROC;
pub extern var glad_glIsQuery: PFNGLISQUERYPROC;
pub extern var glad_glIsRenderbuffer: PFNGLISRENDERBUFFERPROC;
pub extern var glad_glIsSampler: PFNGLISSAMPLERPROC;
pub extern var glad_glIsShader: PFNGLISSHADERPROC;
pub extern var glad_glIsSync: PFNGLISSYNCPROC;
pub extern var glad_glIsTexture: PFNGLISTEXTUREPROC;
pub extern var glad_glIsTransformFeedback: PFNGLISTRANSFORMFEEDBACKPROC;
pub extern var glad_glIsVertexArray: PFNGLISVERTEXARRAYPROC;
pub extern var glad_glLineWidth: PFNGLLINEWIDTHPROC;
pub extern var glad_glLinkProgram: PFNGLLINKPROGRAMPROC;
pub extern var glad_glLogicOp: PFNGLLOGICOPPROC;
pub extern var glad_glMapBuffer: PFNGLMAPBUFFERPROC;
pub extern var glad_glMapBufferRange: PFNGLMAPBUFFERRANGEPROC;
pub extern var glad_glMapNamedBuffer: PFNGLMAPNAMEDBUFFERPROC;
pub extern var glad_glMapNamedBufferRange: PFNGLMAPNAMEDBUFFERRANGEPROC;
pub extern var glad_glMemoryBarrier: PFNGLMEMORYBARRIERPROC;
pub extern var glad_glMemoryBarrierByRegion: PFNGLMEMORYBARRIERBYREGIONPROC;
pub extern var glad_glMinSampleShading: PFNGLMINSAMPLESHADINGPROC;
pub extern var glad_glMultiDrawArrays: PFNGLMULTIDRAWARRAYSPROC;
pub extern var glad_glMultiDrawArraysIndirect: PFNGLMULTIDRAWARRAYSINDIRECTPROC;
pub extern var glad_glMultiDrawArraysIndirectCount: PFNGLMULTIDRAWARRAYSINDIRECTCOUNTPROC;
pub extern var glad_glMultiDrawElements: PFNGLMULTIDRAWELEMENTSPROC;
pub extern var glad_glMultiDrawElementsBaseVertex: PFNGLMULTIDRAWELEMENTSBASEVERTEXPROC;
pub extern var glad_glMultiDrawElementsIndirect: PFNGLMULTIDRAWELEMENTSINDIRECTPROC;
pub extern var glad_glMultiDrawElementsIndirectCount: PFNGLMULTIDRAWELEMENTSINDIRECTCOUNTPROC;
pub extern var glad_glNamedBufferData: PFNGLNAMEDBUFFERDATAPROC;
pub extern var glad_glNamedBufferStorage: PFNGLNAMEDBUFFERSTORAGEPROC;
pub extern var glad_glNamedBufferSubData: PFNGLNAMEDBUFFERSUBDATAPROC;
pub extern var glad_glNamedFramebufferDrawBuffer: PFNGLNAMEDFRAMEBUFFERDRAWBUFFERPROC;
pub extern var glad_glNamedFramebufferDrawBuffers: PFNGLNAMEDFRAMEBUFFERDRAWBUFFERSPROC;
pub extern var glad_glNamedFramebufferParameteri: PFNGLNAMEDFRAMEBUFFERPARAMETERIPROC;
pub extern var glad_glNamedFramebufferReadBuffer: PFNGLNAMEDFRAMEBUFFERREADBUFFERPROC;
pub extern var glad_glNamedFramebufferRenderbuffer: PFNGLNAMEDFRAMEBUFFERRENDERBUFFERPROC;
pub extern var glad_glNamedFramebufferTexture: PFNGLNAMEDFRAMEBUFFERTEXTUREPROC;
pub extern var glad_glNamedFramebufferTextureLayer: PFNGLNAMEDFRAMEBUFFERTEXTURELAYERPROC;
pub extern var glad_glNamedRenderbufferStorage: PFNGLNAMEDRENDERBUFFERSTORAGEPROC;
pub extern var glad_glNamedRenderbufferStorageMultisample: PFNGLNAMEDRENDERBUFFERSTORAGEMULTISAMPLEPROC;
pub extern var glad_glObjectLabel: PFNGLOBJECTLABELPROC;
pub extern var glad_glObjectPtrLabel: PFNGLOBJECTPTRLABELPROC;
pub extern var glad_glPatchParameterfv: PFNGLPATCHPARAMETERFVPROC;
pub extern var glad_glPatchParameteri: PFNGLPATCHPARAMETERIPROC;
pub extern var glad_glPauseTransformFeedback: PFNGLPAUSETRANSFORMFEEDBACKPROC;
pub extern var glad_glPixelStoref: PFNGLPIXELSTOREFPROC;
pub extern var glad_glPixelStorei: PFNGLPIXELSTOREIPROC;
pub extern var glad_glPointParameterf: PFNGLPOINTPARAMETERFPROC;
pub extern var glad_glPointParameterfv: PFNGLPOINTPARAMETERFVPROC;
pub extern var glad_glPointParameteri: PFNGLPOINTPARAMETERIPROC;
pub extern var glad_glPointParameteriv: PFNGLPOINTPARAMETERIVPROC;
pub extern var glad_glPointSize: PFNGLPOINTSIZEPROC;
pub extern var glad_glPolygonMode: PFNGLPOLYGONMODEPROC;
pub extern var glad_glPolygonOffset: PFNGLPOLYGONOFFSETPROC;
pub extern var glad_glPolygonOffsetClamp: PFNGLPOLYGONOFFSETCLAMPPROC;
pub extern var glad_glPopDebugGroup: PFNGLPOPDEBUGGROUPPROC;
pub extern var glad_glPrimitiveRestartIndex: PFNGLPRIMITIVERESTARTINDEXPROC;
pub extern var glad_glProgramBinary: PFNGLPROGRAMBINARYPROC;
pub extern var glad_glProgramParameteri: PFNGLPROGRAMPARAMETERIPROC;
pub extern var glad_glProgramUniform1d: PFNGLPROGRAMUNIFORM1DPROC;
pub extern var glad_glProgramUniform1dv: PFNGLPROGRAMUNIFORM1DVPROC;
pub extern var glad_glProgramUniform1f: PFNGLPROGRAMUNIFORM1FPROC;
pub extern var glad_glProgramUniform1fv: PFNGLPROGRAMUNIFORM1FVPROC;
pub extern var glad_glProgramUniform1i: PFNGLPROGRAMUNIFORM1IPROC;
pub extern var glad_glProgramUniform1iv: PFNGLPROGRAMUNIFORM1IVPROC;
pub extern var glad_glProgramUniform1ui: PFNGLPROGRAMUNIFORM1UIPROC;
pub extern var glad_glProgramUniform1uiv: PFNGLPROGRAMUNIFORM1UIVPROC;
pub extern var glad_glProgramUniform2d: PFNGLPROGRAMUNIFORM2DPROC;
pub extern var glad_glProgramUniform2dv: PFNGLPROGRAMUNIFORM2DVPROC;
pub extern var glad_glProgramUniform2f: PFNGLPROGRAMUNIFORM2FPROC;
pub extern var glad_glProgramUniform2fv: PFNGLPROGRAMUNIFORM2FVPROC;
pub extern var glad_glProgramUniform2i: PFNGLPROGRAMUNIFORM2IPROC;
pub extern var glad_glProgramUniform2iv: PFNGLPROGRAMUNIFORM2IVPROC;
pub extern var glad_glProgramUniform2ui: PFNGLPROGRAMUNIFORM2UIPROC;
pub extern var glad_glProgramUniform2uiv: PFNGLPROGRAMUNIFORM2UIVPROC;
pub extern var glad_glProgramUniform3d: PFNGLPROGRAMUNIFORM3DPROC;
pub extern var glad_glProgramUniform3dv: PFNGLPROGRAMUNIFORM3DVPROC;
pub extern var glad_glProgramUniform3f: PFNGLPROGRAMUNIFORM3FPROC;
pub extern var glad_glProgramUniform3fv: PFNGLPROGRAMUNIFORM3FVPROC;
pub extern var glad_glProgramUniform3i: PFNGLPROGRAMUNIFORM3IPROC;
pub extern var glad_glProgramUniform3iv: PFNGLPROGRAMUNIFORM3IVPROC;
pub extern var glad_glProgramUniform3ui: PFNGLPROGRAMUNIFORM3UIPROC;
pub extern var glad_glProgramUniform3uiv: PFNGLPROGRAMUNIFORM3UIVPROC;
pub extern var glad_glProgramUniform4d: PFNGLPROGRAMUNIFORM4DPROC;
pub extern var glad_glProgramUniform4dv: PFNGLPROGRAMUNIFORM4DVPROC;
pub extern var glad_glProgramUniform4f: PFNGLPROGRAMUNIFORM4FPROC;
pub extern var glad_glProgramUniform4fv: PFNGLPROGRAMUNIFORM4FVPROC;
pub extern var glad_glProgramUniform4i: PFNGLPROGRAMUNIFORM4IPROC;
pub extern var glad_glProgramUniform4iv: PFNGLPROGRAMUNIFORM4IVPROC;
pub extern var glad_glProgramUniform4ui: PFNGLPROGRAMUNIFORM4UIPROC;
pub extern var glad_glProgramUniform4uiv: PFNGLPROGRAMUNIFORM4UIVPROC;
pub extern var glad_glProgramUniformMatrix2dv: PFNGLPROGRAMUNIFORMMATRIX2DVPROC;
pub extern var glad_glProgramUniformMatrix2fv: PFNGLPROGRAMUNIFORMMATRIX2FVPROC;
pub extern var glad_glProgramUniformMatrix2x3dv: PFNGLPROGRAMUNIFORMMATRIX2X3DVPROC;
pub extern var glad_glProgramUniformMatrix2x3fv: PFNGLPROGRAMUNIFORMMATRIX2X3FVPROC;
pub extern var glad_glProgramUniformMatrix2x4dv: PFNGLPROGRAMUNIFORMMATRIX2X4DVPROC;
pub extern var glad_glProgramUniformMatrix2x4fv: PFNGLPROGRAMUNIFORMMATRIX2X4FVPROC;
pub extern var glad_glProgramUniformMatrix3dv: PFNGLPROGRAMUNIFORMMATRIX3DVPROC;
pub extern var glad_glProgramUniformMatrix3fv: PFNGLPROGRAMUNIFORMMATRIX3FVPROC;
pub extern var glad_glProgramUniformMatrix3x2dv: PFNGLPROGRAMUNIFORMMATRIX3X2DVPROC;
pub extern var glad_glProgramUniformMatrix3x2fv: PFNGLPROGRAMUNIFORMMATRIX3X2FVPROC;
pub extern var glad_glProgramUniformMatrix3x4dv: PFNGLPROGRAMUNIFORMMATRIX3X4DVPROC;
pub extern var glad_glProgramUniformMatrix3x4fv: PFNGLPROGRAMUNIFORMMATRIX3X4FVPROC;
pub extern var glad_glProgramUniformMatrix4dv: PFNGLPROGRAMUNIFORMMATRIX4DVPROC;
pub extern var glad_glProgramUniformMatrix4fv: PFNGLPROGRAMUNIFORMMATRIX4FVPROC;
pub extern var glad_glProgramUniformMatrix4x2dv: PFNGLPROGRAMUNIFORMMATRIX4X2DVPROC;
pub extern var glad_glProgramUniformMatrix4x2fv: PFNGLPROGRAMUNIFORMMATRIX4X2FVPROC;
pub extern var glad_glProgramUniformMatrix4x3dv: PFNGLPROGRAMUNIFORMMATRIX4X3DVPROC;
pub extern var glad_glProgramUniformMatrix4x3fv: PFNGLPROGRAMUNIFORMMATRIX4X3FVPROC;
pub extern var glad_glProvokingVertex: PFNGLPROVOKINGVERTEXPROC;
pub extern var glad_glPushDebugGroup: PFNGLPUSHDEBUGGROUPPROC;
pub extern var glad_glQueryCounter: PFNGLQUERYCOUNTERPROC;
pub extern var glad_glReadBuffer: PFNGLREADBUFFERPROC;
pub extern var glad_glReadPixels: PFNGLREADPIXELSPROC;
pub extern var glad_glReadnPixels: PFNGLREADNPIXELSPROC;
pub extern var glad_glReleaseShaderCompiler: PFNGLRELEASESHADERCOMPILERPROC;
pub extern var glad_glRenderbufferStorage: PFNGLRENDERBUFFERSTORAGEPROC;
pub extern var glad_glRenderbufferStorageMultisample: PFNGLRENDERBUFFERSTORAGEMULTISAMPLEPROC;
pub extern var glad_glResumeTransformFeedback: PFNGLRESUMETRANSFORMFEEDBACKPROC;
pub extern var glad_glSampleCoverage: PFNGLSAMPLECOVERAGEPROC;
pub extern var glad_glSampleMaski: PFNGLSAMPLEMASKIPROC;
pub extern var glad_glSamplerParameterIiv: PFNGLSAMPLERPARAMETERIIVPROC;
pub extern var glad_glSamplerParameterIuiv: PFNGLSAMPLERPARAMETERIUIVPROC;
pub extern var glad_glSamplerParameterf: PFNGLSAMPLERPARAMETERFPROC;
pub extern var glad_glSamplerParameterfv: PFNGLSAMPLERPARAMETERFVPROC;
pub extern var glad_glSamplerParameteri: PFNGLSAMPLERPARAMETERIPROC;
pub extern var glad_glSamplerParameteriv: PFNGLSAMPLERPARAMETERIVPROC;
pub extern var glad_glScissor: PFNGLSCISSORPROC;
pub extern var glad_glScissorArrayv: PFNGLSCISSORARRAYVPROC;
pub extern var glad_glScissorIndexed: PFNGLSCISSORINDEXEDPROC;
pub extern var glad_glScissorIndexedv: PFNGLSCISSORINDEXEDVPROC;
pub extern var glad_glShaderBinary: PFNGLSHADERBINARYPROC;
pub extern var glad_glShaderSource: PFNGLSHADERSOURCEPROC;
pub extern var glad_glShaderStorageBlockBinding: PFNGLSHADERSTORAGEBLOCKBINDINGPROC;
pub extern var glad_glSpecializeShader: PFNGLSPECIALIZESHADERPROC;
pub extern var glad_glStencilFunc: PFNGLSTENCILFUNCPROC;
pub extern var glad_glStencilFuncSeparate: PFNGLSTENCILFUNCSEPARATEPROC;
pub extern var glad_glStencilMask: PFNGLSTENCILMASKPROC;
pub extern var glad_glStencilMaskSeparate: PFNGLSTENCILMASKSEPARATEPROC;
pub extern var glad_glStencilOp: PFNGLSTENCILOPPROC;
pub extern var glad_glStencilOpSeparate: PFNGLSTENCILOPSEPARATEPROC;
pub extern var glad_glTexBuffer: PFNGLTEXBUFFERPROC;
pub extern var glad_glTexBufferRange: PFNGLTEXBUFFERRANGEPROC;
pub extern var glad_glTexImage1D: PFNGLTEXIMAGE1DPROC;
pub extern var glad_glTexImage2D: PFNGLTEXIMAGE2DPROC;
pub extern var glad_glTexImage2DMultisample: PFNGLTEXIMAGE2DMULTISAMPLEPROC;
pub extern var glad_glTexImage3D: PFNGLTEXIMAGE3DPROC;
pub extern var glad_glTexImage3DMultisample: PFNGLTEXIMAGE3DMULTISAMPLEPROC;
pub extern var glad_glTexParameterIiv: PFNGLTEXPARAMETERIIVPROC;
pub extern var glad_glTexParameterIuiv: PFNGLTEXPARAMETERIUIVPROC;
pub extern var glad_glTexParameterf: PFNGLTEXPARAMETERFPROC;
pub extern var glad_glTexParameterfv: PFNGLTEXPARAMETERFVPROC;
pub extern var glad_glTexParameteri: PFNGLTEXPARAMETERIPROC;
pub extern var glad_glTexParameteriv: PFNGLTEXPARAMETERIVPROC;
pub extern var glad_glTexStorage1D: PFNGLTEXSTORAGE1DPROC;
pub extern var glad_glTexStorage2D: PFNGLTEXSTORAGE2DPROC;
pub extern var glad_glTexStorage2DMultisample: PFNGLTEXSTORAGE2DMULTISAMPLEPROC;
pub extern var glad_glTexStorage3D: PFNGLTEXSTORAGE3DPROC;
pub extern var glad_glTexStorage3DMultisample: PFNGLTEXSTORAGE3DMULTISAMPLEPROC;
pub extern var glad_glTexSubImage1D: PFNGLTEXSUBIMAGE1DPROC;
pub extern var glad_glTexSubImage2D: PFNGLTEXSUBIMAGE2DPROC;
pub extern var glad_glTexSubImage3D: PFNGLTEXSUBIMAGE3DPROC;
pub extern var glad_glTextureBarrier: PFNGLTEXTUREBARRIERPROC;
pub extern var glad_glTextureBuffer: PFNGLTEXTUREBUFFERPROC;
pub extern var glad_glTextureBufferRange: PFNGLTEXTUREBUFFERRANGEPROC;
pub extern var glad_glTextureParameterIiv: PFNGLTEXTUREPARAMETERIIVPROC;
pub extern var glad_glTextureParameterIuiv: PFNGLTEXTUREPARAMETERIUIVPROC;
pub extern var glad_glTextureParameterf: PFNGLTEXTUREPARAMETERFPROC;
pub extern var glad_glTextureParameterfv: PFNGLTEXTUREPARAMETERFVPROC;
pub extern var glad_glTextureParameteri: PFNGLTEXTUREPARAMETERIPROC;
pub extern var glad_glTextureParameteriv: PFNGLTEXTUREPARAMETERIVPROC;
pub extern var glad_glTextureStorage1D: PFNGLTEXTURESTORAGE1DPROC;
pub extern var glad_glTextureStorage2D: PFNGLTEXTURESTORAGE2DPROC;
pub extern var glad_glTextureStorage2DMultisample: PFNGLTEXTURESTORAGE2DMULTISAMPLEPROC;
pub extern var glad_glTextureStorage3D: PFNGLTEXTURESTORAGE3DPROC;
pub extern var glad_glTextureStorage3DMultisample: PFNGLTEXTURESTORAGE3DMULTISAMPLEPROC;
pub extern var glad_glTextureSubImage1D: PFNGLTEXTURESUBIMAGE1DPROC;
pub extern var glad_glTextureSubImage2D: PFNGLTEXTURESUBIMAGE2DPROC;
pub extern var glad_glTextureSubImage3D: PFNGLTEXTURESUBIMAGE3DPROC;
pub extern var glad_glTextureView: PFNGLTEXTUREVIEWPROC;
pub extern var glad_glTransformFeedbackBufferBase: PFNGLTRANSFORMFEEDBACKBUFFERBASEPROC;
pub extern var glad_glTransformFeedbackBufferRange: PFNGLTRANSFORMFEEDBACKBUFFERRANGEPROC;
pub extern var glad_glTransformFeedbackVaryings: PFNGLTRANSFORMFEEDBACKVARYINGSPROC;
pub extern var glad_glUniform1d: PFNGLUNIFORM1DPROC;
pub extern var glad_glUniform1dv: PFNGLUNIFORM1DVPROC;
pub extern var glad_glUniform1f: PFNGLUNIFORM1FPROC;
pub extern var glad_glUniform1fv: PFNGLUNIFORM1FVPROC;
pub extern var glad_glUniform1i: PFNGLUNIFORM1IPROC;
pub extern var glad_glUniform1iv: PFNGLUNIFORM1IVPROC;
pub extern var glad_glUniform1ui: PFNGLUNIFORM1UIPROC;
pub extern var glad_glUniform1uiv: PFNGLUNIFORM1UIVPROC;
pub extern var glad_glUniform2d: PFNGLUNIFORM2DPROC;
pub extern var glad_glUniform2dv: PFNGLUNIFORM2DVPROC;
pub extern var glad_glUniform2f: PFNGLUNIFORM2FPROC;
pub extern var glad_glUniform2fv: PFNGLUNIFORM2FVPROC;
pub extern var glad_glUniform2i: PFNGLUNIFORM2IPROC;
pub extern var glad_glUniform2iv: PFNGLUNIFORM2IVPROC;
pub extern var glad_glUniform2ui: PFNGLUNIFORM2UIPROC;
pub extern var glad_glUniform2uiv: PFNGLUNIFORM2UIVPROC;
pub extern var glad_glUniform3d: PFNGLUNIFORM3DPROC;
pub extern var glad_glUniform3dv: PFNGLUNIFORM3DVPROC;
pub extern var glad_glUniform3f: PFNGLUNIFORM3FPROC;
pub extern var glad_glUniform3fv: PFNGLUNIFORM3FVPROC;
pub extern var glad_glUniform3i: PFNGLUNIFORM3IPROC;
pub extern var glad_glUniform3iv: PFNGLUNIFORM3IVPROC;
pub extern var glad_glUniform3ui: PFNGLUNIFORM3UIPROC;
pub extern var glad_glUniform3uiv: PFNGLUNIFORM3UIVPROC;
pub extern var glad_glUniform4d: PFNGLUNIFORM4DPROC;
pub extern var glad_glUniform4dv: PFNGLUNIFORM4DVPROC;
pub extern var glad_glUniform4f: PFNGLUNIFORM4FPROC;
pub extern var glad_glUniform4fv: PFNGLUNIFORM4FVPROC;
pub extern var glad_glUniform4i: PFNGLUNIFORM4IPROC;
pub extern var glad_glUniform4iv: PFNGLUNIFORM4IVPROC;
pub extern var glad_glUniform4ui: PFNGLUNIFORM4UIPROC;
pub extern var glad_glUniform4uiv: PFNGLUNIFORM4UIVPROC;
pub extern var glad_glUniformBlockBinding: PFNGLUNIFORMBLOCKBINDINGPROC;
pub extern var glad_glUniformMatrix2dv: PFNGLUNIFORMMATRIX2DVPROC;
pub extern var glad_glUniformMatrix2fv: PFNGLUNIFORMMATRIX2FVPROC;
pub extern var glad_glUniformMatrix2x3dv: PFNGLUNIFORMMATRIX2X3DVPROC;
pub extern var glad_glUniformMatrix2x3fv: PFNGLUNIFORMMATRIX2X3FVPROC;
pub extern var glad_glUniformMatrix2x4dv: PFNGLUNIFORMMATRIX2X4DVPROC;
pub extern var glad_glUniformMatrix2x4fv: PFNGLUNIFORMMATRIX2X4FVPROC;
pub extern var glad_glUniformMatrix3dv: PFNGLUNIFORMMATRIX3DVPROC;
pub extern var glad_glUniformMatrix3fv: PFNGLUNIFORMMATRIX3FVPROC;
pub extern var glad_glUniformMatrix3x2dv: PFNGLUNIFORMMATRIX3X2DVPROC;
pub extern var glad_glUniformMatrix3x2fv: PFNGLUNIFORMMATRIX3X2FVPROC;
pub extern var glad_glUniformMatrix3x4dv: PFNGLUNIFORMMATRIX3X4DVPROC;
pub extern var glad_glUniformMatrix3x4fv: PFNGLUNIFORMMATRIX3X4FVPROC;
pub extern var glad_glUniformMatrix4dv: PFNGLUNIFORMMATRIX4DVPROC;
pub extern var glad_glUniformMatrix4fv: PFNGLUNIFORMMATRIX4FVPROC;
pub extern var glad_glUniformMatrix4x2dv: PFNGLUNIFORMMATRIX4X2DVPROC;
pub extern var glad_glUniformMatrix4x2fv: PFNGLUNIFORMMATRIX4X2FVPROC;
pub extern var glad_glUniformMatrix4x3dv: PFNGLUNIFORMMATRIX4X3DVPROC;
pub extern var glad_glUniformMatrix4x3fv: PFNGLUNIFORMMATRIX4X3FVPROC;
pub extern var glad_glUniformSubroutinesuiv: PFNGLUNIFORMSUBROUTINESUIVPROC;
pub extern var glad_glUnmapBuffer: PFNGLUNMAPBUFFERPROC;
pub extern var glad_glUnmapNamedBuffer: PFNGLUNMAPNAMEDBUFFERPROC;
pub extern var glad_glUseProgram: PFNGLUSEPROGRAMPROC;
pub extern var glad_glUseProgramStages: PFNGLUSEPROGRAMSTAGESPROC;
pub extern var glad_glValidateProgram: PFNGLVALIDATEPROGRAMPROC;
pub extern var glad_glValidateProgramPipeline: PFNGLVALIDATEPROGRAMPIPELINEPROC;
pub extern var glad_glVertexArrayAttribBinding: PFNGLVERTEXARRAYATTRIBBINDINGPROC;
pub extern var glad_glVertexArrayAttribFormat: PFNGLVERTEXARRAYATTRIBFORMATPROC;
pub extern var glad_glVertexArrayAttribIFormat: PFNGLVERTEXARRAYATTRIBIFORMATPROC;
pub extern var glad_glVertexArrayAttribLFormat: PFNGLVERTEXARRAYATTRIBLFORMATPROC;
pub extern var glad_glVertexArrayBindingDivisor: PFNGLVERTEXARRAYBINDINGDIVISORPROC;
pub extern var glad_glVertexArrayElementBuffer: PFNGLVERTEXARRAYELEMENTBUFFERPROC;
pub extern var glad_glVertexArrayVertexBuffer: PFNGLVERTEXARRAYVERTEXBUFFERPROC;
pub extern var glad_glVertexArrayVertexBuffers: PFNGLVERTEXARRAYVERTEXBUFFERSPROC;
pub extern var glad_glVertexAttrib1d: PFNGLVERTEXATTRIB1DPROC;
pub extern var glad_glVertexAttrib1dv: PFNGLVERTEXATTRIB1DVPROC;
pub extern var glad_glVertexAttrib1f: PFNGLVERTEXATTRIB1FPROC;
pub extern var glad_glVertexAttrib1fv: PFNGLVERTEXATTRIB1FVPROC;
pub extern var glad_glVertexAttrib1s: PFNGLVERTEXATTRIB1SPROC;
pub extern var glad_glVertexAttrib1sv: PFNGLVERTEXATTRIB1SVPROC;
pub extern var glad_glVertexAttrib2d: PFNGLVERTEXATTRIB2DPROC;
pub extern var glad_glVertexAttrib2dv: PFNGLVERTEXATTRIB2DVPROC;
pub extern var glad_glVertexAttrib2f: PFNGLVERTEXATTRIB2FPROC;
pub extern var glad_glVertexAttrib2fv: PFNGLVERTEXATTRIB2FVPROC;
pub extern var glad_glVertexAttrib2s: PFNGLVERTEXATTRIB2SPROC;
pub extern var glad_glVertexAttrib2sv: PFNGLVERTEXATTRIB2SVPROC;
pub extern var glad_glVertexAttrib3d: PFNGLVERTEXATTRIB3DPROC;
pub extern var glad_glVertexAttrib3dv: PFNGLVERTEXATTRIB3DVPROC;
pub extern var glad_glVertexAttrib3f: PFNGLVERTEXATTRIB3FPROC;
pub extern var glad_glVertexAttrib3fv: PFNGLVERTEXATTRIB3FVPROC;
pub extern var glad_glVertexAttrib3s: PFNGLVERTEXATTRIB3SPROC;
pub extern var glad_glVertexAttrib3sv: PFNGLVERTEXATTRIB3SVPROC;
pub extern var glad_glVertexAttrib4Nbv: PFNGLVERTEXATTRIB4NBVPROC;
pub extern var glad_glVertexAttrib4Niv: PFNGLVERTEXATTRIB4NIVPROC;
pub extern var glad_glVertexAttrib4Nsv: PFNGLVERTEXATTRIB4NSVPROC;
pub extern var glad_glVertexAttrib4Nub: PFNGLVERTEXATTRIB4NUBPROC;
pub extern var glad_glVertexAttrib4Nubv: PFNGLVERTEXATTRIB4NUBVPROC;
pub extern var glad_glVertexAttrib4Nuiv: PFNGLVERTEXATTRIB4NUIVPROC;
pub extern var glad_glVertexAttrib4Nusv: PFNGLVERTEXATTRIB4NUSVPROC;
pub extern var glad_glVertexAttrib4bv: PFNGLVERTEXATTRIB4BVPROC;
pub extern var glad_glVertexAttrib4d: PFNGLVERTEXATTRIB4DPROC;
pub extern var glad_glVertexAttrib4dv: PFNGLVERTEXATTRIB4DVPROC;
pub extern var glad_glVertexAttrib4f: PFNGLVERTEXATTRIB4FPROC;
pub extern var glad_glVertexAttrib4fv: PFNGLVERTEXATTRIB4FVPROC;
pub extern var glad_glVertexAttrib4iv: PFNGLVERTEXATTRIB4IVPROC;
pub extern var glad_glVertexAttrib4s: PFNGLVERTEXATTRIB4SPROC;
pub extern var glad_glVertexAttrib4sv: PFNGLVERTEXATTRIB4SVPROC;
pub extern var glad_glVertexAttrib4ubv: PFNGLVERTEXATTRIB4UBVPROC;
pub extern var glad_glVertexAttrib4uiv: PFNGLVERTEXATTRIB4UIVPROC;
pub extern var glad_glVertexAttrib4usv: PFNGLVERTEXATTRIB4USVPROC;
pub extern var glad_glVertexAttribBinding: PFNGLVERTEXATTRIBBINDINGPROC;
pub extern var glad_glVertexAttribDivisor: PFNGLVERTEXATTRIBDIVISORPROC;
pub extern var glad_glVertexAttribFormat: PFNGLVERTEXATTRIBFORMATPROC;
pub extern var glad_glVertexAttribI1i: PFNGLVERTEXATTRIBI1IPROC;
pub extern var glad_glVertexAttribI1iv: PFNGLVERTEXATTRIBI1IVPROC;
pub extern var glad_glVertexAttribI1ui: PFNGLVERTEXATTRIBI1UIPROC;
pub extern var glad_glVertexAttribI1uiv: PFNGLVERTEXATTRIBI1UIVPROC;
pub extern var glad_glVertexAttribI2i: PFNGLVERTEXATTRIBI2IPROC;
pub extern var glad_glVertexAttribI2iv: PFNGLVERTEXATTRIBI2IVPROC;
pub extern var glad_glVertexAttribI2ui: PFNGLVERTEXATTRIBI2UIPROC;
pub extern var glad_glVertexAttribI2uiv: PFNGLVERTEXATTRIBI2UIVPROC;
pub extern var glad_glVertexAttribI3i: PFNGLVERTEXATTRIBI3IPROC;
pub extern var glad_glVertexAttribI3iv: PFNGLVERTEXATTRIBI3IVPROC;
pub extern var glad_glVertexAttribI3ui: PFNGLVERTEXATTRIBI3UIPROC;
pub extern var glad_glVertexAttribI3uiv: PFNGLVERTEXATTRIBI3UIVPROC;
pub extern var glad_glVertexAttribI4bv: PFNGLVERTEXATTRIBI4BVPROC;
pub extern var glad_glVertexAttribI4i: PFNGLVERTEXATTRIBI4IPROC;
pub extern var glad_glVertexAttribI4iv: PFNGLVERTEXATTRIBI4IVPROC;
pub extern var glad_glVertexAttribI4sv: PFNGLVERTEXATTRIBI4SVPROC;
pub extern var glad_glVertexAttribI4ubv: PFNGLVERTEXATTRIBI4UBVPROC;
pub extern var glad_glVertexAttribI4ui: PFNGLVERTEXATTRIBI4UIPROC;
pub extern var glad_glVertexAttribI4uiv: PFNGLVERTEXATTRIBI4UIVPROC;
pub extern var glad_glVertexAttribI4usv: PFNGLVERTEXATTRIBI4USVPROC;
pub extern var glad_glVertexAttribIFormat: PFNGLVERTEXATTRIBIFORMATPROC;
pub extern var glad_glVertexAttribIPointer: PFNGLVERTEXATTRIBIPOINTERPROC;
pub extern var glad_glVertexAttribL1d: PFNGLVERTEXATTRIBL1DPROC;
pub extern var glad_glVertexAttribL1dv: PFNGLVERTEXATTRIBL1DVPROC;
pub extern var glad_glVertexAttribL2d: PFNGLVERTEXATTRIBL2DPROC;
pub extern var glad_glVertexAttribL2dv: PFNGLVERTEXATTRIBL2DVPROC;
pub extern var glad_glVertexAttribL3d: PFNGLVERTEXATTRIBL3DPROC;
pub extern var glad_glVertexAttribL3dv: PFNGLVERTEXATTRIBL3DVPROC;
pub extern var glad_glVertexAttribL4d: PFNGLVERTEXATTRIBL4DPROC;
pub extern var glad_glVertexAttribL4dv: PFNGLVERTEXATTRIBL4DVPROC;
pub extern var glad_glVertexAttribLFormat: PFNGLVERTEXATTRIBLFORMATPROC;
pub extern var glad_glVertexAttribLPointer: PFNGLVERTEXATTRIBLPOINTERPROC;
pub extern var glad_glVertexAttribP1ui: PFNGLVERTEXATTRIBP1UIPROC;
pub extern var glad_glVertexAttribP1uiv: PFNGLVERTEXATTRIBP1UIVPROC;
pub extern var glad_glVertexAttribP2ui: PFNGLVERTEXATTRIBP2UIPROC;
pub extern var glad_glVertexAttribP2uiv: PFNGLVERTEXATTRIBP2UIVPROC;
pub extern var glad_glVertexAttribP3ui: PFNGLVERTEXATTRIBP3UIPROC;
pub extern var glad_glVertexAttribP3uiv: PFNGLVERTEXATTRIBP3UIVPROC;
pub extern var glad_glVertexAttribP4ui: PFNGLVERTEXATTRIBP4UIPROC;
pub extern var glad_glVertexAttribP4uiv: PFNGLVERTEXATTRIBP4UIVPROC;
pub extern var glad_glVertexAttribPointer: PFNGLVERTEXATTRIBPOINTERPROC;
pub extern var glad_glVertexBindingDivisor: PFNGLVERTEXBINDINGDIVISORPROC;
pub extern var glad_glViewport: PFNGLVIEWPORTPROC;
pub extern var glad_glViewportArrayv: PFNGLVIEWPORTARRAYVPROC;
pub extern var glad_glViewportIndexedf: PFNGLVIEWPORTINDEXEDFPROC;
pub extern var glad_glViewportIndexedfv: PFNGLVIEWPORTINDEXEDFVPROC;
pub extern var glad_glWaitSync: PFNGLWAITSYNCPROC;
pub extern fn gladLoadGLUserPtr(load: GLADuserptrloadfunc, userptr: ?*anyopaque) c_int;
pub extern fn gladLoadGL(load: GLADloadfunc) c_int;

pub const __VERSION__ = "Aro aro-zig";
pub const __Aro__ = "";
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const __STDC_EMBED_NOT_FOUND__ = @as(c_int, 0);
pub const __STDC_EMBED_FOUND__ = @as(c_int, 1);
pub const __STDC_EMBED_EMPTY__ = @as(c_int, 2);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __GNUC__ = @as(c_int, 7);
pub const __GNUC_MINOR__ = @as(c_int, 1);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 0);
pub const __ARO_EMULATE_NO__ = @as(c_int, 0);
pub const __ARO_EMULATE_CLANG__ = @as(c_int, 1);
pub const __ARO_EMULATE_GCC__ = @as(c_int, 2);
pub const __ARO_EMULATE_MSVC__ = @as(c_int, 3);
pub const __ARO_EMULATE__ = __ARO_EMULATE_GCC__;
pub inline fn __building_module(x: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &x;
    return @as(c_int, 0);
}
pub const _WIN32 = @as(c_int, 1);
pub const _WIN64 = @as(c_int, 1);
pub const WIN32 = @as(c_int, 1);
pub const __WIN32 = @as(c_int, 1);
pub const __WIN32__ = @as(c_int, 1);
pub const WINNT = @as(c_int, 1);
pub const __WINNT = @as(c_int, 1);
pub const __WINNT__ = @as(c_int, 1);
pub const WIN64 = @as(c_int, 1);
pub const __WIN64 = @as(c_int, 1);
pub const __WIN64__ = @as(c_int, 1);
pub const __MINGW64__ = @as(c_int, 1);
pub const __MSVCRT__ = @as(c_int, 1);
pub const __MINGW32__ = @as(c_int, 1);
pub const __declspec = @compileError("unable to translate C expr: unexpected token '__attribute__'"); // <builtin>:34:9
pub const _cdecl = @compileError("unable to translate macro: undefined identifier `__cdecl__`"); // <builtin>:35:9
pub const __cdecl = @compileError("unable to translate macro: undefined identifier `__cdecl__`"); // <builtin>:36:9
pub const _stdcall = @compileError("unable to translate macro: undefined identifier `__stdcall__`"); // <builtin>:37:9
pub const __stdcall = @compileError("unable to translate macro: undefined identifier `__stdcall__`"); // <builtin>:38:9
pub const _fastcall = @compileError("unable to translate macro: undefined identifier `__fastcall__`"); // <builtin>:39:9
pub const __fastcall = @compileError("unable to translate macro: undefined identifier `__fastcall__`"); // <builtin>:40:9
pub const _thiscall = @compileError("unable to translate macro: undefined identifier `__thiscall__`"); // <builtin>:41:9
pub const __thiscall = @compileError("unable to translate macro: undefined identifier `__thiscall__`"); // <builtin>:42:9
pub const unix = @as(c_int, 1);
pub const __unix = @as(c_int, 1);
pub const __unix__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `address_space`"); // <builtin>:53:9
pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `address_space`"); // <builtin>:54:9
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __VAES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __VPCLMULQDQ__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __GFNI__ = @as(c_int, 1);
pub const __SHA__ = @as(c_int, 1);
pub const __SHA512__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __CLWB__ = @as(c_int, 1);
pub const __SHSTK__ = @as(c_int, 1);
pub const __SM3__ = @as(c_int, 1);
pub const __SM4__ = @as(c_int, 1);
pub const __RDPID__ = @as(c_int, 1);
pub const __WAITPKG__ = @as(c_int, 1);
pub const __MOVDIRI__ = @as(c_int, 1);
pub const __MOVDIR64B__ = @as(c_int, 1);
pub const __PTWRITE__ = @as(c_int, 1);
pub const __INVPCID__ = @as(c_int, 1);
pub const __HRESET__ = @as(c_int, 1);
pub const __CMPCCXADD__ = @as(c_int, 1);
pub const __AVXIFMA__ = @as(c_int, 1);
pub const __AVXNECONVERT__ = @as(c_int, 1);
pub const __AVXVNNI__ = @as(c_int, 1);
pub const __AVXVNNIINT16__ = @as(c_int, 1);
pub const __AVXVNNIINT8__ = @as(c_int, 1);
pub const __SERIALIZE__ = @as(c_int, 1);
pub const __CRC32__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __ATOMIC_BOOL_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_WINT_T_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_SHORT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_INT_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_LLONG_LOCK_FREE = @as(c_int, 1);
pub const __ATOMIC_POINTER_LOCK_FREE = @as(c_int, 1);
pub const __WCHAR_UNSIGNED__ = @as(c_int, 1);
pub const __WINT_UNSIGNED__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 8);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SCHAR_WIDTH__ = @as(c_int, 8);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_MAX__ = @as(c_long, 2147483647);
pub const __LONG_WIDTH__ = @as(c_int, 32);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __LONG_LONG_WIDTH__ = @as(c_int, 64);
pub const __WCHAR_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 16);
pub const __WINT_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __WINT_WIDTH__ = @as(c_int, 16);
pub const __INTMAX_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIG_ATOMIC_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __BITINT_MAXWIDTH__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 10);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 4);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 2);
pub const __SIZEOF_WINT_T__ = @as(c_int, 2);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTPTR_TYPE__ = c_longlong;
pub const __UINTPTR_TYPE__ = c_ulonglong;
pub const __INTMAX_TYPE__ = c_longlong;
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`"); // <builtin>:183:9
pub const __INTMAX_C = __helpers.LL_SUFFIX;
pub const __UINTMAX_TYPE__ = c_ulonglong;
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`"); // <builtin>:186:9
pub const __UINTMAX_C = __helpers.ULL_SUFFIX;
pub const __PTRDIFF_TYPE__ = c_longlong;
pub const __SIZE_TYPE__ = c_ulonglong;
pub const __WCHAR_TYPE__ = c_ushort;
pub const __WINT_TYPE__ = c_ushort;
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub inline fn __INT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub inline fn __INT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub inline fn __INT32_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT64_TYPE__ = c_longlong;
pub const __INT64_FMTd__ = "lld";
pub const __INT64_FMTi__ = "lli";
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `LL`"); // <builtin>:212:9
pub const __INT64_C = __helpers.LL_SUFFIX;
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub inline fn __UINT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub inline fn __UINT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`"); // <builtin>:237:9
pub const __UINT32_C = __helpers.U_SUFFIX;
pub const __UINT32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulonglong;
pub const __UINT64_FMTo__ = "llo";
pub const __UINT64_FMTu__ = "llu";
pub const __UINT64_FMTx__ = "llx";
pub const __UINT64_FMTX__ = "llX";
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `ULL`"); // <builtin>:246:9
pub const __UINT64_C = __helpers.ULL_SUFFIX;
pub const __UINT64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const __INT64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const INT_LEAST8_FMTd__ = "hhd";
pub const INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const UINT_LEAST8_FMTo__ = "hho";
pub const UINT_LEAST8_FMTu__ = "hhu";
pub const UINT_LEAST8_FMTx__ = "hhx";
pub const UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const INT_FAST8_FMTd__ = "hhd";
pub const INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const UINT_FAST8_FMTo__ = "hho";
pub const UINT_FAST8_FMTu__ = "hhu";
pub const UINT_FAST8_FMTx__ = "hhx";
pub const UINT_FAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const INT_LEAST16_FMTd__ = "hd";
pub const INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_LEAST16_FMTo__ = "ho";
pub const UINT_LEAST16_FMTu__ = "hu";
pub const UINT_LEAST16_FMTx__ = "hx";
pub const UINT_LEAST16_FMTX__ = "hX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const INT_FAST16_FMTd__ = "hd";
pub const INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT_FAST16_FMTo__ = "ho";
pub const UINT_FAST16_FMTu__ = "hu";
pub const UINT_FAST16_FMTx__ = "hx";
pub const UINT_FAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const INT_LEAST32_FMTd__ = "d";
pub const INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_LEAST32_FMTo__ = "o";
pub const UINT_LEAST32_FMTu__ = "u";
pub const UINT_LEAST32_FMTx__ = "x";
pub const UINT_LEAST32_FMTX__ = "X";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const INT_FAST32_FMTd__ = "d";
pub const INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = __helpers.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const UINT_FAST32_FMTo__ = "o";
pub const UINT_FAST32_FMTu__ = "u";
pub const UINT_FAST32_FMTx__ = "x";
pub const UINT_FAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_longlong;
pub const __INT_LEAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const INT_LEAST64_FMTd__ = "lld";
pub const INT_LEAST64_FMTi__ = "lli";
pub const __UINT_LEAST64_TYPE__ = c_ulonglong;
pub const __UINT_LEAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const UINT_LEAST64_FMTo__ = "llo";
pub const UINT_LEAST64_FMTu__ = "llu";
pub const UINT_LEAST64_FMTx__ = "llx";
pub const UINT_LEAST64_FMTX__ = "llX";
pub const __INT_FAST64_TYPE__ = c_longlong;
pub const __INT_FAST64_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const INT_FAST64_FMTd__ = "lld";
pub const INT_FAST64_FMTi__ = "lli";
pub const __UINT_FAST64_TYPE__ = c_ulonglong;
pub const __UINT_FAST64_MAX__ = @as(c_ulonglong, 18446744073709551615);
pub const UINT_FAST64_FMTo__ = "llo";
pub const UINT_FAST64_FMTu__ = "llu";
pub const UINT_FAST64_FMTx__ = "llx";
pub const UINT_FAST64_FMTX__ = "llX";
pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
pub const __FLT16_HAS_DENORM__ = "";
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
pub const __FLT16_HAS_INFINITY__ = "";
pub const __FLT16_HAS_QUIET_NAN__ = "";
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_HAS_DENORM__ = "";
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = "";
pub const __FLT_HAS_QUIET_NAN__ = "";
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_HAS_DENORM__ = "";
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = "";
pub const __DBL_HAS_QUIET_NAN__ = "";
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_HAS_DENORM__ = "";
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = "";
pub const __LDBL_HAS_QUIET_NAN__ = "";
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __FLT_EVAL_METHOD__ = @as(c_int, 0);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __pic__ = @as(c_int, 2);
pub const __PIC__ = @as(c_int, 2);
pub const __MSVCRT_VERSION__ = @as(c_int, 0xE00);
pub const _WIN32_WINNT = @as(c_int, 0x0a00);
pub const GLAD_GL_H_ = "";
pub const __gl_h_ = @as(c_int, 1);
pub const __gl3_h_ = @as(c_int, 1);
pub const __glext_h_ = @as(c_int, 1);
pub const __gl3ext_h_ = @as(c_int, 1);
pub const GLAD_GL = "";
pub const GLAD_PLATFORM_H_ = "";
pub const GLAD_PLATFORM_WIN32 = @as(c_int, 1);
pub const GLAD_PLATFORM_APPLE = @as(c_int, 0);
pub const GLAD_PLATFORM_EMSCRIPTEN = @as(c_int, 0);
pub const GLAD_PLATFORM_UWP = @as(c_int, 0);
pub const GLAD_GNUC_EXTENSION = @compileError("unable to translate C expr: unexpected token '__extension__'"); // C:\Users\ianb5\Desktop\Github\irec\DVAP\lib\GLAD\include\\glad/gl.h:113:11
pub const GLAD_UNUSED = __helpers.DISCARD;
pub const GLAD_API_CALL = @compileError("unable to translate C expr: unexpected token 'extern'"); // C:\Users\ianb5\Desktop\Github\irec\DVAP\lib\GLAD\include\\glad/gl.h:142:13
pub const GLAD_API_PTR = @compileError("unable to translate C expr: unexpected token '__stdcall'"); // C:\Users\ianb5\Desktop\Github\irec\DVAP\lib\GLAD\include\\glad/gl.h:149:11
pub const GLAPI = GLAD_API_CALL;
pub const GLAPIENTRY = GLAD_API_PTR;
pub inline fn GLAD_MAKE_VERSION(major: anytype, minor: anytype) @TypeOf((major * @as(c_int, 10000)) + minor) {
    _ = &major;
    _ = &minor;
    return (major * @as(c_int, 10000)) + minor;
}
pub inline fn GLAD_VERSION_MAJOR(version: anytype) @TypeOf(__helpers.div(version, @as(c_int, 10000))) {
    _ = &version;
    return __helpers.div(version, @as(c_int, 10000));
}
pub inline fn GLAD_VERSION_MINOR(version: anytype) @TypeOf(__helpers.rem(version, @as(c_int, 10000))) {
    _ = &version;
    return __helpers.rem(version, @as(c_int, 10000));
}
pub const GLAD_GENERATOR_VERSION = "2.0.8";
pub const GL_ACTIVE_ATOMIC_COUNTER_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x92D9, .hex);
pub const GL_ACTIVE_ATTRIBUTES = __helpers.promoteIntLiteral(c_int, 0x8B89, .hex);
pub const GL_ACTIVE_ATTRIBUTE_MAX_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8B8A, .hex);
pub const GL_ACTIVE_PROGRAM = __helpers.promoteIntLiteral(c_int, 0x8259, .hex);
pub const GL_ACTIVE_RESOURCES = __helpers.promoteIntLiteral(c_int, 0x92F5, .hex);
pub const GL_ACTIVE_SUBROUTINES = __helpers.promoteIntLiteral(c_int, 0x8DE5, .hex);
pub const GL_ACTIVE_SUBROUTINE_MAX_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8E48, .hex);
pub const GL_ACTIVE_SUBROUTINE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x8DE6, .hex);
pub const GL_ACTIVE_SUBROUTINE_UNIFORM_LOCATIONS = __helpers.promoteIntLiteral(c_int, 0x8E47, .hex);
pub const GL_ACTIVE_SUBROUTINE_UNIFORM_MAX_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8E49, .hex);
pub const GL_ACTIVE_TEXTURE = __helpers.promoteIntLiteral(c_int, 0x84E0, .hex);
pub const GL_ACTIVE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x8B86, .hex);
pub const GL_ACTIVE_UNIFORM_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x8A36, .hex);
pub const GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8A35, .hex);
pub const GL_ACTIVE_UNIFORM_MAX_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8B87, .hex);
pub const GL_ACTIVE_VARIABLES = __helpers.promoteIntLiteral(c_int, 0x9305, .hex);
pub const GL_ALIASED_LINE_WIDTH_RANGE = __helpers.promoteIntLiteral(c_int, 0x846E, .hex);
pub const GL_ALL_BARRIER_BITS = __helpers.promoteIntLiteral(c_int, 0xFFFFFFFF, .hex);
pub const GL_ALL_SHADER_BITS = __helpers.promoteIntLiteral(c_int, 0xFFFFFFFF, .hex);
pub const GL_ALPHA = @as(c_int, 0x1906);
pub const GL_ALREADY_SIGNALED = __helpers.promoteIntLiteral(c_int, 0x911A, .hex);
pub const GL_ALWAYS = @as(c_int, 0x0207);
pub const GL_AND = @as(c_int, 0x1501);
pub const GL_AND_INVERTED = @as(c_int, 0x1504);
pub const GL_AND_REVERSE = @as(c_int, 0x1502);
pub const GL_ANY_SAMPLES_PASSED = __helpers.promoteIntLiteral(c_int, 0x8C2F, .hex);
pub const GL_ANY_SAMPLES_PASSED_CONSERVATIVE = __helpers.promoteIntLiteral(c_int, 0x8D6A, .hex);
pub const GL_ARRAY_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8892, .hex);
pub const GL_ARRAY_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8894, .hex);
pub const GL_ARRAY_SIZE = __helpers.promoteIntLiteral(c_int, 0x92FB, .hex);
pub const GL_ARRAY_STRIDE = __helpers.promoteIntLiteral(c_int, 0x92FE, .hex);
pub const GL_ATOMIC_COUNTER_BARRIER_BIT = @as(c_int, 0x00001000);
pub const GL_ATOMIC_COUNTER_BUFFER = __helpers.promoteIntLiteral(c_int, 0x92C0, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_ACTIVE_ATOMIC_COUNTERS = __helpers.promoteIntLiteral(c_int, 0x92C5, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_ACTIVE_ATOMIC_COUNTER_INDICES = __helpers.promoteIntLiteral(c_int, 0x92C6, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x92C1, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_DATA_SIZE = __helpers.promoteIntLiteral(c_int, 0x92C4, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_INDEX = __helpers.promoteIntLiteral(c_int, 0x9301, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_COMPUTE_SHADER = __helpers.promoteIntLiteral(c_int, 0x90ED, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_FRAGMENT_SHADER = __helpers.promoteIntLiteral(c_int, 0x92CB, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_GEOMETRY_SHADER = __helpers.promoteIntLiteral(c_int, 0x92CA, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_TESS_CONTROL_SHADER = __helpers.promoteIntLiteral(c_int, 0x92C8, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_TESS_EVALUATION_SHADER = __helpers.promoteIntLiteral(c_int, 0x92C9, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_REFERENCED_BY_VERTEX_SHADER = __helpers.promoteIntLiteral(c_int, 0x92C7, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_SIZE = __helpers.promoteIntLiteral(c_int, 0x92C3, .hex);
pub const GL_ATOMIC_COUNTER_BUFFER_START = __helpers.promoteIntLiteral(c_int, 0x92C2, .hex);
pub const GL_ATTACHED_SHADERS = __helpers.promoteIntLiteral(c_int, 0x8B85, .hex);
pub const GL_AUTO_GENERATE_MIPMAP = __helpers.promoteIntLiteral(c_int, 0x8295, .hex);
pub const GL_BACK = @as(c_int, 0x0405);
pub const GL_BACK_LEFT = @as(c_int, 0x0402);
pub const GL_BACK_RIGHT = @as(c_int, 0x0403);
pub const GL_BGR = __helpers.promoteIntLiteral(c_int, 0x80E0, .hex);
pub const GL_BGRA = __helpers.promoteIntLiteral(c_int, 0x80E1, .hex);
pub const GL_BGRA_INTEGER = __helpers.promoteIntLiteral(c_int, 0x8D9B, .hex);
pub const GL_BGR_INTEGER = __helpers.promoteIntLiteral(c_int, 0x8D9A, .hex);
pub const GL_BLEND = @as(c_int, 0x0BE2);
pub const GL_BLEND_COLOR = __helpers.promoteIntLiteral(c_int, 0x8005, .hex);
pub const GL_BLEND_DST = @as(c_int, 0x0BE0);
pub const GL_BLEND_DST_ALPHA = __helpers.promoteIntLiteral(c_int, 0x80CA, .hex);
pub const GL_BLEND_DST_RGB = __helpers.promoteIntLiteral(c_int, 0x80C8, .hex);
pub const GL_BLEND_EQUATION = __helpers.promoteIntLiteral(c_int, 0x8009, .hex);
pub const GL_BLEND_EQUATION_ALPHA = __helpers.promoteIntLiteral(c_int, 0x883D, .hex);
pub const GL_BLEND_EQUATION_RGB = __helpers.promoteIntLiteral(c_int, 0x8009, .hex);
pub const GL_BLEND_SRC = @as(c_int, 0x0BE1);
pub const GL_BLEND_SRC_ALPHA = __helpers.promoteIntLiteral(c_int, 0x80CB, .hex);
pub const GL_BLEND_SRC_RGB = __helpers.promoteIntLiteral(c_int, 0x80C9, .hex);
pub const GL_BLOCK_INDEX = __helpers.promoteIntLiteral(c_int, 0x92FD, .hex);
pub const GL_BLUE = @as(c_int, 0x1905);
pub const GL_BLUE_INTEGER = __helpers.promoteIntLiteral(c_int, 0x8D96, .hex);
pub const GL_BOOL = __helpers.promoteIntLiteral(c_int, 0x8B56, .hex);
pub const GL_BOOL_VEC2 = __helpers.promoteIntLiteral(c_int, 0x8B57, .hex);
pub const GL_BOOL_VEC3 = __helpers.promoteIntLiteral(c_int, 0x8B58, .hex);
pub const GL_BOOL_VEC4 = __helpers.promoteIntLiteral(c_int, 0x8B59, .hex);
pub const GL_BUFFER = __helpers.promoteIntLiteral(c_int, 0x82E0, .hex);
pub const GL_BUFFER_ACCESS = __helpers.promoteIntLiteral(c_int, 0x88BB, .hex);
pub const GL_BUFFER_ACCESS_FLAGS = __helpers.promoteIntLiteral(c_int, 0x911F, .hex);
pub const GL_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x9302, .hex);
pub const GL_BUFFER_DATA_SIZE = __helpers.promoteIntLiteral(c_int, 0x9303, .hex);
pub const GL_BUFFER_IMMUTABLE_STORAGE = __helpers.promoteIntLiteral(c_int, 0x821F, .hex);
pub const GL_BUFFER_MAPPED = __helpers.promoteIntLiteral(c_int, 0x88BC, .hex);
pub const GL_BUFFER_MAP_LENGTH = __helpers.promoteIntLiteral(c_int, 0x9120, .hex);
pub const GL_BUFFER_MAP_OFFSET = __helpers.promoteIntLiteral(c_int, 0x9121, .hex);
pub const GL_BUFFER_MAP_POINTER = __helpers.promoteIntLiteral(c_int, 0x88BD, .hex);
pub const GL_BUFFER_SIZE = __helpers.promoteIntLiteral(c_int, 0x8764, .hex);
pub const GL_BUFFER_STORAGE_FLAGS = __helpers.promoteIntLiteral(c_int, 0x8220, .hex);
pub const GL_BUFFER_UPDATE_BARRIER_BIT = @as(c_int, 0x00000200);
pub const GL_BUFFER_USAGE = __helpers.promoteIntLiteral(c_int, 0x8765, .hex);
pub const GL_BUFFER_VARIABLE = __helpers.promoteIntLiteral(c_int, 0x92E5, .hex);
pub const GL_BYTE = @as(c_int, 0x1400);
pub const GL_CAVEAT_SUPPORT = __helpers.promoteIntLiteral(c_int, 0x82B8, .hex);
pub const GL_CCW = @as(c_int, 0x0901);
pub const GL_CLAMP_READ_COLOR = __helpers.promoteIntLiteral(c_int, 0x891C, .hex);
pub const GL_CLAMP_TO_BORDER = __helpers.promoteIntLiteral(c_int, 0x812D, .hex);
pub const GL_CLAMP_TO_EDGE = __helpers.promoteIntLiteral(c_int, 0x812F, .hex);
pub const GL_CLEAR = @as(c_int, 0x1500);
pub const GL_CLEAR_BUFFER = __helpers.promoteIntLiteral(c_int, 0x82B4, .hex);
pub const GL_CLEAR_TEXTURE = __helpers.promoteIntLiteral(c_int, 0x9365, .hex);
pub const GL_CLIENT_MAPPED_BUFFER_BARRIER_BIT = @as(c_int, 0x00004000);
pub const GL_CLIENT_STORAGE_BIT = @as(c_int, 0x0200);
pub const GL_CLIPPING_INPUT_PRIMITIVES = __helpers.promoteIntLiteral(c_int, 0x82F6, .hex);
pub const GL_CLIPPING_OUTPUT_PRIMITIVES = __helpers.promoteIntLiteral(c_int, 0x82F7, .hex);
pub const GL_CLIP_DEPTH_MODE = __helpers.promoteIntLiteral(c_int, 0x935D, .hex);
pub const GL_CLIP_DISTANCE0 = @as(c_int, 0x3000);
pub const GL_CLIP_DISTANCE1 = @as(c_int, 0x3001);
pub const GL_CLIP_DISTANCE2 = @as(c_int, 0x3002);
pub const GL_CLIP_DISTANCE3 = @as(c_int, 0x3003);
pub const GL_CLIP_DISTANCE4 = @as(c_int, 0x3004);
pub const GL_CLIP_DISTANCE5 = @as(c_int, 0x3005);
pub const GL_CLIP_DISTANCE6 = @as(c_int, 0x3006);
pub const GL_CLIP_DISTANCE7 = @as(c_int, 0x3007);
pub const GL_CLIP_ORIGIN = __helpers.promoteIntLiteral(c_int, 0x935C, .hex);
pub const GL_COLOR = @as(c_int, 0x1800);
pub const GL_COLOR_ATTACHMENT0 = __helpers.promoteIntLiteral(c_int, 0x8CE0, .hex);
pub const GL_COLOR_ATTACHMENT1 = __helpers.promoteIntLiteral(c_int, 0x8CE1, .hex);
pub const GL_COLOR_ATTACHMENT10 = __helpers.promoteIntLiteral(c_int, 0x8CEA, .hex);
pub const GL_COLOR_ATTACHMENT11 = __helpers.promoteIntLiteral(c_int, 0x8CEB, .hex);
pub const GL_COLOR_ATTACHMENT12 = __helpers.promoteIntLiteral(c_int, 0x8CEC, .hex);
pub const GL_COLOR_ATTACHMENT13 = __helpers.promoteIntLiteral(c_int, 0x8CED, .hex);
pub const GL_COLOR_ATTACHMENT14 = __helpers.promoteIntLiteral(c_int, 0x8CEE, .hex);
pub const GL_COLOR_ATTACHMENT15 = __helpers.promoteIntLiteral(c_int, 0x8CEF, .hex);
pub const GL_COLOR_ATTACHMENT16 = __helpers.promoteIntLiteral(c_int, 0x8CF0, .hex);
pub const GL_COLOR_ATTACHMENT17 = __helpers.promoteIntLiteral(c_int, 0x8CF1, .hex);
pub const GL_COLOR_ATTACHMENT18 = __helpers.promoteIntLiteral(c_int, 0x8CF2, .hex);
pub const GL_COLOR_ATTACHMENT19 = __helpers.promoteIntLiteral(c_int, 0x8CF3, .hex);
pub const GL_COLOR_ATTACHMENT2 = __helpers.promoteIntLiteral(c_int, 0x8CE2, .hex);
pub const GL_COLOR_ATTACHMENT20 = __helpers.promoteIntLiteral(c_int, 0x8CF4, .hex);
pub const GL_COLOR_ATTACHMENT21 = __helpers.promoteIntLiteral(c_int, 0x8CF5, .hex);
pub const GL_COLOR_ATTACHMENT22 = __helpers.promoteIntLiteral(c_int, 0x8CF6, .hex);
pub const GL_COLOR_ATTACHMENT23 = __helpers.promoteIntLiteral(c_int, 0x8CF7, .hex);
pub const GL_COLOR_ATTACHMENT24 = __helpers.promoteIntLiteral(c_int, 0x8CF8, .hex);
pub const GL_COLOR_ATTACHMENT25 = __helpers.promoteIntLiteral(c_int, 0x8CF9, .hex);
pub const GL_COLOR_ATTACHMENT26 = __helpers.promoteIntLiteral(c_int, 0x8CFA, .hex);
pub const GL_COLOR_ATTACHMENT27 = __helpers.promoteIntLiteral(c_int, 0x8CFB, .hex);
pub const GL_COLOR_ATTACHMENT28 = __helpers.promoteIntLiteral(c_int, 0x8CFC, .hex);
pub const GL_COLOR_ATTACHMENT29 = __helpers.promoteIntLiteral(c_int, 0x8CFD, .hex);
pub const GL_COLOR_ATTACHMENT3 = __helpers.promoteIntLiteral(c_int, 0x8CE3, .hex);
pub const GL_COLOR_ATTACHMENT30 = __helpers.promoteIntLiteral(c_int, 0x8CFE, .hex);
pub const GL_COLOR_ATTACHMENT31 = __helpers.promoteIntLiteral(c_int, 0x8CFF, .hex);
pub const GL_COLOR_ATTACHMENT4 = __helpers.promoteIntLiteral(c_int, 0x8CE4, .hex);
pub const GL_COLOR_ATTACHMENT5 = __helpers.promoteIntLiteral(c_int, 0x8CE5, .hex);
pub const GL_COLOR_ATTACHMENT6 = __helpers.promoteIntLiteral(c_int, 0x8CE6, .hex);
pub const GL_COLOR_ATTACHMENT7 = __helpers.promoteIntLiteral(c_int, 0x8CE7, .hex);
pub const GL_COLOR_ATTACHMENT8 = __helpers.promoteIntLiteral(c_int, 0x8CE8, .hex);
pub const GL_COLOR_ATTACHMENT9 = __helpers.promoteIntLiteral(c_int, 0x8CE9, .hex);
pub const GL_COLOR_BUFFER_BIT = @as(c_int, 0x00004000);
pub const GL_COLOR_CLEAR_VALUE = @as(c_int, 0x0C22);
pub const GL_COLOR_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8283, .hex);
pub const GL_COLOR_ENCODING = __helpers.promoteIntLiteral(c_int, 0x8296, .hex);
pub const GL_COLOR_LOGIC_OP = @as(c_int, 0x0BF2);
pub const GL_COLOR_RENDERABLE = __helpers.promoteIntLiteral(c_int, 0x8286, .hex);
pub const GL_COLOR_WRITEMASK = @as(c_int, 0x0C23);
pub const GL_COMMAND_BARRIER_BIT = @as(c_int, 0x00000040);
pub const GL_COMPARE_REF_TO_TEXTURE = __helpers.promoteIntLiteral(c_int, 0x884E, .hex);
pub const GL_COMPATIBLE_SUBROUTINES = __helpers.promoteIntLiteral(c_int, 0x8E4B, .hex);
pub const GL_COMPILE_STATUS = __helpers.promoteIntLiteral(c_int, 0x8B81, .hex);
pub const GL_COMPRESSED_R11_EAC = __helpers.promoteIntLiteral(c_int, 0x9270, .hex);
pub const GL_COMPRESSED_RED = __helpers.promoteIntLiteral(c_int, 0x8225, .hex);
pub const GL_COMPRESSED_RED_RGTC1 = __helpers.promoteIntLiteral(c_int, 0x8DBB, .hex);
pub const GL_COMPRESSED_RG = __helpers.promoteIntLiteral(c_int, 0x8226, .hex);
pub const GL_COMPRESSED_RG11_EAC = __helpers.promoteIntLiteral(c_int, 0x9272, .hex);
pub const GL_COMPRESSED_RGB = __helpers.promoteIntLiteral(c_int, 0x84ED, .hex);
pub const GL_COMPRESSED_RGB8_ETC2 = __helpers.promoteIntLiteral(c_int, 0x9274, .hex);
pub const GL_COMPRESSED_RGB8_PUNCHTHROUGH_ALPHA1_ETC2 = __helpers.promoteIntLiteral(c_int, 0x9276, .hex);
pub const GL_COMPRESSED_RGBA = __helpers.promoteIntLiteral(c_int, 0x84EE, .hex);
pub const GL_COMPRESSED_RGBA8_ETC2_EAC = __helpers.promoteIntLiteral(c_int, 0x9278, .hex);
pub const GL_COMPRESSED_RGBA_BPTC_UNORM = __helpers.promoteIntLiteral(c_int, 0x8E8C, .hex);
pub const GL_COMPRESSED_RGB_BPTC_SIGNED_FLOAT = __helpers.promoteIntLiteral(c_int, 0x8E8E, .hex);
pub const GL_COMPRESSED_RGB_BPTC_UNSIGNED_FLOAT = __helpers.promoteIntLiteral(c_int, 0x8E8F, .hex);
pub const GL_COMPRESSED_RG_RGTC2 = __helpers.promoteIntLiteral(c_int, 0x8DBD, .hex);
pub const GL_COMPRESSED_SIGNED_R11_EAC = __helpers.promoteIntLiteral(c_int, 0x9271, .hex);
pub const GL_COMPRESSED_SIGNED_RED_RGTC1 = __helpers.promoteIntLiteral(c_int, 0x8DBC, .hex);
pub const GL_COMPRESSED_SIGNED_RG11_EAC = __helpers.promoteIntLiteral(c_int, 0x9273, .hex);
pub const GL_COMPRESSED_SIGNED_RG_RGTC2 = __helpers.promoteIntLiteral(c_int, 0x8DBE, .hex);
pub const GL_COMPRESSED_SRGB = __helpers.promoteIntLiteral(c_int, 0x8C48, .hex);
pub const GL_COMPRESSED_SRGB8_ALPHA8_ETC2_EAC = __helpers.promoteIntLiteral(c_int, 0x9279, .hex);
pub const GL_COMPRESSED_SRGB8_ETC2 = __helpers.promoteIntLiteral(c_int, 0x9275, .hex);
pub const GL_COMPRESSED_SRGB8_PUNCHTHROUGH_ALPHA1_ETC2 = __helpers.promoteIntLiteral(c_int, 0x9277, .hex);
pub const GL_COMPRESSED_SRGB_ALPHA = __helpers.promoteIntLiteral(c_int, 0x8C49, .hex);
pub const GL_COMPRESSED_SRGB_ALPHA_BPTC_UNORM = __helpers.promoteIntLiteral(c_int, 0x8E8D, .hex);
pub const GL_COMPRESSED_TEXTURE_FORMATS = __helpers.promoteIntLiteral(c_int, 0x86A3, .hex);
pub const GL_COMPUTE_SHADER = __helpers.promoteIntLiteral(c_int, 0x91B9, .hex);
pub const GL_COMPUTE_SHADER_BIT = @as(c_int, 0x00000020);
pub const GL_COMPUTE_SHADER_INVOCATIONS = __helpers.promoteIntLiteral(c_int, 0x82F5, .hex);
pub const GL_COMPUTE_SUBROUTINE = __helpers.promoteIntLiteral(c_int, 0x92ED, .hex);
pub const GL_COMPUTE_SUBROUTINE_UNIFORM = __helpers.promoteIntLiteral(c_int, 0x92F3, .hex);
pub const GL_COMPUTE_TEXTURE = __helpers.promoteIntLiteral(c_int, 0x82A0, .hex);
pub const GL_COMPUTE_WORK_GROUP_SIZE = __helpers.promoteIntLiteral(c_int, 0x8267, .hex);
pub const GL_CONDITION_SATISFIED = __helpers.promoteIntLiteral(c_int, 0x911C, .hex);
pub const GL_CONSTANT_ALPHA = __helpers.promoteIntLiteral(c_int, 0x8003, .hex);
pub const GL_CONSTANT_COLOR = __helpers.promoteIntLiteral(c_int, 0x8001, .hex);
pub const GL_CONTEXT_COMPATIBILITY_PROFILE_BIT = @as(c_int, 0x00000002);
pub const GL_CONTEXT_CORE_PROFILE_BIT = @as(c_int, 0x00000001);
pub const GL_CONTEXT_FLAGS = __helpers.promoteIntLiteral(c_int, 0x821E, .hex);
pub const GL_CONTEXT_FLAG_DEBUG_BIT = @as(c_int, 0x00000002);
pub const GL_CONTEXT_FLAG_FORWARD_COMPATIBLE_BIT = @as(c_int, 0x00000001);
pub const GL_CONTEXT_FLAG_NO_ERROR_BIT = @as(c_int, 0x00000008);
pub const GL_CONTEXT_FLAG_ROBUST_ACCESS_BIT = @as(c_int, 0x00000004);
pub const GL_CONTEXT_LOST = @as(c_int, 0x0507);
pub const GL_CONTEXT_PROFILE_MASK = __helpers.promoteIntLiteral(c_int, 0x9126, .hex);
pub const GL_CONTEXT_RELEASE_BEHAVIOR = __helpers.promoteIntLiteral(c_int, 0x82FB, .hex);
pub const GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH = __helpers.promoteIntLiteral(c_int, 0x82FC, .hex);
pub const GL_COPY = @as(c_int, 0x1503);
pub const GL_COPY_INVERTED = @as(c_int, 0x150C);
pub const GL_COPY_READ_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8F36, .hex);
pub const GL_COPY_READ_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8F36, .hex);
pub const GL_COPY_WRITE_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8F37, .hex);
pub const GL_COPY_WRITE_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8F37, .hex);
pub const GL_CULL_FACE = @as(c_int, 0x0B44);
pub const GL_CULL_FACE_MODE = @as(c_int, 0x0B45);
pub const GL_CURRENT_PROGRAM = __helpers.promoteIntLiteral(c_int, 0x8B8D, .hex);
pub const GL_CURRENT_QUERY = __helpers.promoteIntLiteral(c_int, 0x8865, .hex);
pub const GL_CURRENT_VERTEX_ATTRIB = __helpers.promoteIntLiteral(c_int, 0x8626, .hex);
pub const GL_CW = @as(c_int, 0x0900);
pub const GL_DEBUG_CALLBACK_FUNCTION = __helpers.promoteIntLiteral(c_int, 0x8244, .hex);
pub const GL_DEBUG_CALLBACK_USER_PARAM = __helpers.promoteIntLiteral(c_int, 0x8245, .hex);
pub const GL_DEBUG_GROUP_STACK_DEPTH = __helpers.promoteIntLiteral(c_int, 0x826D, .hex);
pub const GL_DEBUG_LOGGED_MESSAGES = __helpers.promoteIntLiteral(c_int, 0x9145, .hex);
pub const GL_DEBUG_NEXT_LOGGED_MESSAGE_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8243, .hex);
pub const GL_DEBUG_OUTPUT = __helpers.promoteIntLiteral(c_int, 0x92E0, .hex);
pub const GL_DEBUG_OUTPUT_SYNCHRONOUS = __helpers.promoteIntLiteral(c_int, 0x8242, .hex);
pub const GL_DEBUG_SEVERITY_HIGH = __helpers.promoteIntLiteral(c_int, 0x9146, .hex);
pub const GL_DEBUG_SEVERITY_LOW = __helpers.promoteIntLiteral(c_int, 0x9148, .hex);
pub const GL_DEBUG_SEVERITY_MEDIUM = __helpers.promoteIntLiteral(c_int, 0x9147, .hex);
pub const GL_DEBUG_SEVERITY_NOTIFICATION = __helpers.promoteIntLiteral(c_int, 0x826B, .hex);
pub const GL_DEBUG_SOURCE_API = __helpers.promoteIntLiteral(c_int, 0x8246, .hex);
pub const GL_DEBUG_SOURCE_APPLICATION = __helpers.promoteIntLiteral(c_int, 0x824A, .hex);
pub const GL_DEBUG_SOURCE_OTHER = __helpers.promoteIntLiteral(c_int, 0x824B, .hex);
pub const GL_DEBUG_SOURCE_SHADER_COMPILER = __helpers.promoteIntLiteral(c_int, 0x8248, .hex);
pub const GL_DEBUG_SOURCE_THIRD_PARTY = __helpers.promoteIntLiteral(c_int, 0x8249, .hex);
pub const GL_DEBUG_SOURCE_WINDOW_SYSTEM = __helpers.promoteIntLiteral(c_int, 0x8247, .hex);
pub const GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR = __helpers.promoteIntLiteral(c_int, 0x824D, .hex);
pub const GL_DEBUG_TYPE_ERROR = __helpers.promoteIntLiteral(c_int, 0x824C, .hex);
pub const GL_DEBUG_TYPE_MARKER = __helpers.promoteIntLiteral(c_int, 0x8268, .hex);
pub const GL_DEBUG_TYPE_OTHER = __helpers.promoteIntLiteral(c_int, 0x8251, .hex);
pub const GL_DEBUG_TYPE_PERFORMANCE = __helpers.promoteIntLiteral(c_int, 0x8250, .hex);
pub const GL_DEBUG_TYPE_POP_GROUP = __helpers.promoteIntLiteral(c_int, 0x826A, .hex);
pub const GL_DEBUG_TYPE_PORTABILITY = __helpers.promoteIntLiteral(c_int, 0x824F, .hex);
pub const GL_DEBUG_TYPE_PUSH_GROUP = __helpers.promoteIntLiteral(c_int, 0x8269, .hex);
pub const GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR = __helpers.promoteIntLiteral(c_int, 0x824E, .hex);
pub const GL_DECR = @as(c_int, 0x1E03);
pub const GL_DECR_WRAP = __helpers.promoteIntLiteral(c_int, 0x8508, .hex);
pub const GL_DELETE_STATUS = __helpers.promoteIntLiteral(c_int, 0x8B80, .hex);
pub const GL_DEPTH = @as(c_int, 0x1801);
pub const GL_DEPTH24_STENCIL8 = __helpers.promoteIntLiteral(c_int, 0x88F0, .hex);
pub const GL_DEPTH32F_STENCIL8 = __helpers.promoteIntLiteral(c_int, 0x8CAD, .hex);
pub const GL_DEPTH_ATTACHMENT = __helpers.promoteIntLiteral(c_int, 0x8D00, .hex);
pub const GL_DEPTH_BUFFER_BIT = @as(c_int, 0x00000100);
pub const GL_DEPTH_CLAMP = __helpers.promoteIntLiteral(c_int, 0x864F, .hex);
pub const GL_DEPTH_CLEAR_VALUE = @as(c_int, 0x0B73);
pub const GL_DEPTH_COMPONENT = @as(c_int, 0x1902);
pub const GL_DEPTH_COMPONENT16 = __helpers.promoteIntLiteral(c_int, 0x81A5, .hex);
pub const GL_DEPTH_COMPONENT24 = __helpers.promoteIntLiteral(c_int, 0x81A6, .hex);
pub const GL_DEPTH_COMPONENT32 = __helpers.promoteIntLiteral(c_int, 0x81A7, .hex);
pub const GL_DEPTH_COMPONENT32F = __helpers.promoteIntLiteral(c_int, 0x8CAC, .hex);
pub const GL_DEPTH_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8284, .hex);
pub const GL_DEPTH_FUNC = @as(c_int, 0x0B74);
pub const GL_DEPTH_RANGE = @as(c_int, 0x0B70);
pub const GL_DEPTH_RENDERABLE = __helpers.promoteIntLiteral(c_int, 0x8287, .hex);
pub const GL_DEPTH_STENCIL = __helpers.promoteIntLiteral(c_int, 0x84F9, .hex);
pub const GL_DEPTH_STENCIL_ATTACHMENT = __helpers.promoteIntLiteral(c_int, 0x821A, .hex);
pub const GL_DEPTH_STENCIL_TEXTURE_MODE = __helpers.promoteIntLiteral(c_int, 0x90EA, .hex);
pub const GL_DEPTH_TEST = @as(c_int, 0x0B71);
pub const GL_DEPTH_WRITEMASK = @as(c_int, 0x0B72);
pub const GL_DISPATCH_INDIRECT_BUFFER = __helpers.promoteIntLiteral(c_int, 0x90EE, .hex);
pub const GL_DISPATCH_INDIRECT_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x90EF, .hex);
pub const GL_DITHER = @as(c_int, 0x0BD0);
pub const GL_DONT_CARE = @as(c_int, 0x1100);
pub const GL_DOUBLE = @as(c_int, 0x140A);
pub const GL_DOUBLEBUFFER = @as(c_int, 0x0C32);
pub const GL_DOUBLE_MAT2 = __helpers.promoteIntLiteral(c_int, 0x8F46, .hex);
pub const GL_DOUBLE_MAT2x3 = __helpers.promoteIntLiteral(c_int, 0x8F49, .hex);
pub const GL_DOUBLE_MAT2x4 = __helpers.promoteIntLiteral(c_int, 0x8F4A, .hex);
pub const GL_DOUBLE_MAT3 = __helpers.promoteIntLiteral(c_int, 0x8F47, .hex);
pub const GL_DOUBLE_MAT3x2 = __helpers.promoteIntLiteral(c_int, 0x8F4B, .hex);
pub const GL_DOUBLE_MAT3x4 = __helpers.promoteIntLiteral(c_int, 0x8F4C, .hex);
pub const GL_DOUBLE_MAT4 = __helpers.promoteIntLiteral(c_int, 0x8F48, .hex);
pub const GL_DOUBLE_MAT4x2 = __helpers.promoteIntLiteral(c_int, 0x8F4D, .hex);
pub const GL_DOUBLE_MAT4x3 = __helpers.promoteIntLiteral(c_int, 0x8F4E, .hex);
pub const GL_DOUBLE_VEC2 = __helpers.promoteIntLiteral(c_int, 0x8FFC, .hex);
pub const GL_DOUBLE_VEC3 = __helpers.promoteIntLiteral(c_int, 0x8FFD, .hex);
pub const GL_DOUBLE_VEC4 = __helpers.promoteIntLiteral(c_int, 0x8FFE, .hex);
pub const GL_DRAW_BUFFER = @as(c_int, 0x0C01);
pub const GL_DRAW_BUFFER0 = __helpers.promoteIntLiteral(c_int, 0x8825, .hex);
pub const GL_DRAW_BUFFER1 = __helpers.promoteIntLiteral(c_int, 0x8826, .hex);
pub const GL_DRAW_BUFFER10 = __helpers.promoteIntLiteral(c_int, 0x882F, .hex);
pub const GL_DRAW_BUFFER11 = __helpers.promoteIntLiteral(c_int, 0x8830, .hex);
pub const GL_DRAW_BUFFER12 = __helpers.promoteIntLiteral(c_int, 0x8831, .hex);
pub const GL_DRAW_BUFFER13 = __helpers.promoteIntLiteral(c_int, 0x8832, .hex);
pub const GL_DRAW_BUFFER14 = __helpers.promoteIntLiteral(c_int, 0x8833, .hex);
pub const GL_DRAW_BUFFER15 = __helpers.promoteIntLiteral(c_int, 0x8834, .hex);
pub const GL_DRAW_BUFFER2 = __helpers.promoteIntLiteral(c_int, 0x8827, .hex);
pub const GL_DRAW_BUFFER3 = __helpers.promoteIntLiteral(c_int, 0x8828, .hex);
pub const GL_DRAW_BUFFER4 = __helpers.promoteIntLiteral(c_int, 0x8829, .hex);
pub const GL_DRAW_BUFFER5 = __helpers.promoteIntLiteral(c_int, 0x882A, .hex);
pub const GL_DRAW_BUFFER6 = __helpers.promoteIntLiteral(c_int, 0x882B, .hex);
pub const GL_DRAW_BUFFER7 = __helpers.promoteIntLiteral(c_int, 0x882C, .hex);
pub const GL_DRAW_BUFFER8 = __helpers.promoteIntLiteral(c_int, 0x882D, .hex);
pub const GL_DRAW_BUFFER9 = __helpers.promoteIntLiteral(c_int, 0x882E, .hex);
pub const GL_DRAW_FRAMEBUFFER = __helpers.promoteIntLiteral(c_int, 0x8CA9, .hex);
pub const GL_DRAW_FRAMEBUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8CA6, .hex);
pub const GL_DRAW_INDIRECT_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8F3F, .hex);
pub const GL_DRAW_INDIRECT_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8F43, .hex);
pub const GL_DST_ALPHA = @as(c_int, 0x0304);
pub const GL_DST_COLOR = @as(c_int, 0x0306);
pub const GL_DYNAMIC_COPY = __helpers.promoteIntLiteral(c_int, 0x88EA, .hex);
pub const GL_DYNAMIC_DRAW = __helpers.promoteIntLiteral(c_int, 0x88E8, .hex);
pub const GL_DYNAMIC_READ = __helpers.promoteIntLiteral(c_int, 0x88E9, .hex);
pub const GL_DYNAMIC_STORAGE_BIT = @as(c_int, 0x0100);
pub const GL_ELEMENT_ARRAY_BARRIER_BIT = @as(c_int, 0x00000002);
pub const GL_ELEMENT_ARRAY_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8893, .hex);
pub const GL_ELEMENT_ARRAY_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8895, .hex);
pub const GL_EQUAL = @as(c_int, 0x0202);
pub const GL_EQUIV = @as(c_int, 0x1509);
pub const GL_EXTENSIONS = @as(c_int, 0x1F03);
pub const GL_FALSE = @as(c_int, 0);
pub const GL_FASTEST = @as(c_int, 0x1101);
pub const GL_FILL = @as(c_int, 0x1B02);
pub const GL_FILTER = __helpers.promoteIntLiteral(c_int, 0x829A, .hex);
pub const GL_FIRST_VERTEX_CONVENTION = __helpers.promoteIntLiteral(c_int, 0x8E4D, .hex);
pub const GL_FIXED = @as(c_int, 0x140C);
pub const GL_FIXED_ONLY = __helpers.promoteIntLiteral(c_int, 0x891D, .hex);
pub const GL_FLOAT = @as(c_int, 0x1406);
pub const GL_FLOAT_32_UNSIGNED_INT_24_8_REV = __helpers.promoteIntLiteral(c_int, 0x8DAD, .hex);
pub const GL_FLOAT_MAT2 = __helpers.promoteIntLiteral(c_int, 0x8B5A, .hex);
pub const GL_FLOAT_MAT2x3 = __helpers.promoteIntLiteral(c_int, 0x8B65, .hex);
pub const GL_FLOAT_MAT2x4 = __helpers.promoteIntLiteral(c_int, 0x8B66, .hex);
pub const GL_FLOAT_MAT3 = __helpers.promoteIntLiteral(c_int, 0x8B5B, .hex);
pub const GL_FLOAT_MAT3x2 = __helpers.promoteIntLiteral(c_int, 0x8B67, .hex);
pub const GL_FLOAT_MAT3x4 = __helpers.promoteIntLiteral(c_int, 0x8B68, .hex);
pub const GL_FLOAT_MAT4 = __helpers.promoteIntLiteral(c_int, 0x8B5C, .hex);
pub const GL_FLOAT_MAT4x2 = __helpers.promoteIntLiteral(c_int, 0x8B69, .hex);
pub const GL_FLOAT_MAT4x3 = __helpers.promoteIntLiteral(c_int, 0x8B6A, .hex);
pub const GL_FLOAT_VEC2 = __helpers.promoteIntLiteral(c_int, 0x8B50, .hex);
pub const GL_FLOAT_VEC3 = __helpers.promoteIntLiteral(c_int, 0x8B51, .hex);
pub const GL_FLOAT_VEC4 = __helpers.promoteIntLiteral(c_int, 0x8B52, .hex);
pub const GL_FRACTIONAL_EVEN = __helpers.promoteIntLiteral(c_int, 0x8E7C, .hex);
pub const GL_FRACTIONAL_ODD = __helpers.promoteIntLiteral(c_int, 0x8E7B, .hex);
pub const GL_FRAGMENT_INTERPOLATION_OFFSET_BITS = __helpers.promoteIntLiteral(c_int, 0x8E5D, .hex);
pub const GL_FRAGMENT_SHADER = __helpers.promoteIntLiteral(c_int, 0x8B30, .hex);
pub const GL_FRAGMENT_SHADER_BIT = @as(c_int, 0x00000002);
pub const GL_FRAGMENT_SHADER_DERIVATIVE_HINT = __helpers.promoteIntLiteral(c_int, 0x8B8B, .hex);
pub const GL_FRAGMENT_SHADER_INVOCATIONS = __helpers.promoteIntLiteral(c_int, 0x82F4, .hex);
pub const GL_FRAGMENT_SUBROUTINE = __helpers.promoteIntLiteral(c_int, 0x92EC, .hex);
pub const GL_FRAGMENT_SUBROUTINE_UNIFORM = __helpers.promoteIntLiteral(c_int, 0x92F2, .hex);
pub const GL_FRAGMENT_TEXTURE = __helpers.promoteIntLiteral(c_int, 0x829F, .hex);
pub const GL_FRAMEBUFFER = __helpers.promoteIntLiteral(c_int, 0x8D40, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE = __helpers.promoteIntLiteral(c_int, 0x8215, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE = __helpers.promoteIntLiteral(c_int, 0x8214, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING = __helpers.promoteIntLiteral(c_int, 0x8210, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE = __helpers.promoteIntLiteral(c_int, 0x8211, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE = __helpers.promoteIntLiteral(c_int, 0x8216, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE = __helpers.promoteIntLiteral(c_int, 0x8213, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_LAYERED = __helpers.promoteIntLiteral(c_int, 0x8DA7, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME = __helpers.promoteIntLiteral(c_int, 0x8CD1, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE = __helpers.promoteIntLiteral(c_int, 0x8CD0, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE = __helpers.promoteIntLiteral(c_int, 0x8212, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE = __helpers.promoteIntLiteral(c_int, 0x8217, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE = __helpers.promoteIntLiteral(c_int, 0x8CD3, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER = __helpers.promoteIntLiteral(c_int, 0x8CD4, .hex);
pub const GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL = __helpers.promoteIntLiteral(c_int, 0x8CD2, .hex);
pub const GL_FRAMEBUFFER_BARRIER_BIT = @as(c_int, 0x00000400);
pub const GL_FRAMEBUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8CA6, .hex);
pub const GL_FRAMEBUFFER_BLEND = __helpers.promoteIntLiteral(c_int, 0x828B, .hex);
pub const GL_FRAMEBUFFER_COMPLETE = __helpers.promoteIntLiteral(c_int, 0x8CD5, .hex);
pub const GL_FRAMEBUFFER_DEFAULT = __helpers.promoteIntLiteral(c_int, 0x8218, .hex);
pub const GL_FRAMEBUFFER_DEFAULT_FIXED_SAMPLE_LOCATIONS = __helpers.promoteIntLiteral(c_int, 0x9314, .hex);
pub const GL_FRAMEBUFFER_DEFAULT_HEIGHT = __helpers.promoteIntLiteral(c_int, 0x9311, .hex);
pub const GL_FRAMEBUFFER_DEFAULT_LAYERS = __helpers.promoteIntLiteral(c_int, 0x9312, .hex);
pub const GL_FRAMEBUFFER_DEFAULT_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x9313, .hex);
pub const GL_FRAMEBUFFER_DEFAULT_WIDTH = __helpers.promoteIntLiteral(c_int, 0x9310, .hex);
pub const GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT = __helpers.promoteIntLiteral(c_int, 0x8CD6, .hex);
pub const GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8CDB, .hex);
pub const GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS = __helpers.promoteIntLiteral(c_int, 0x8DA8, .hex);
pub const GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT = __helpers.promoteIntLiteral(c_int, 0x8CD7, .hex);
pub const GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x8D56, .hex);
pub const GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8CDC, .hex);
pub const GL_FRAMEBUFFER_RENDERABLE = __helpers.promoteIntLiteral(c_int, 0x8289, .hex);
pub const GL_FRAMEBUFFER_RENDERABLE_LAYERED = __helpers.promoteIntLiteral(c_int, 0x828A, .hex);
pub const GL_FRAMEBUFFER_SRGB = __helpers.promoteIntLiteral(c_int, 0x8DB9, .hex);
pub const GL_FRAMEBUFFER_UNDEFINED = __helpers.promoteIntLiteral(c_int, 0x8219, .hex);
pub const GL_FRAMEBUFFER_UNSUPPORTED = __helpers.promoteIntLiteral(c_int, 0x8CDD, .hex);
pub const GL_FRONT = @as(c_int, 0x0404);
pub const GL_FRONT_AND_BACK = @as(c_int, 0x0408);
pub const GL_FRONT_FACE = @as(c_int, 0x0B46);
pub const GL_FRONT_LEFT = @as(c_int, 0x0400);
pub const GL_FRONT_RIGHT = @as(c_int, 0x0401);
pub const GL_FULL_SUPPORT = __helpers.promoteIntLiteral(c_int, 0x82B7, .hex);
pub const GL_FUNC_ADD = __helpers.promoteIntLiteral(c_int, 0x8006, .hex);
pub const GL_FUNC_REVERSE_SUBTRACT = __helpers.promoteIntLiteral(c_int, 0x800B, .hex);
pub const GL_FUNC_SUBTRACT = __helpers.promoteIntLiteral(c_int, 0x800A, .hex);
pub const GL_GEOMETRY_INPUT_TYPE = __helpers.promoteIntLiteral(c_int, 0x8917, .hex);
pub const GL_GEOMETRY_OUTPUT_TYPE = __helpers.promoteIntLiteral(c_int, 0x8918, .hex);
pub const GL_GEOMETRY_SHADER = __helpers.promoteIntLiteral(c_int, 0x8DD9, .hex);
pub const GL_GEOMETRY_SHADER_BIT = @as(c_int, 0x00000004);
pub const GL_GEOMETRY_SHADER_INVOCATIONS = __helpers.promoteIntLiteral(c_int, 0x887F, .hex);
pub const GL_GEOMETRY_SHADER_PRIMITIVES_EMITTED = __helpers.promoteIntLiteral(c_int, 0x82F3, .hex);
pub const GL_GEOMETRY_SUBROUTINE = __helpers.promoteIntLiteral(c_int, 0x92EB, .hex);
pub const GL_GEOMETRY_SUBROUTINE_UNIFORM = __helpers.promoteIntLiteral(c_int, 0x92F1, .hex);
pub const GL_GEOMETRY_TEXTURE = __helpers.promoteIntLiteral(c_int, 0x829E, .hex);
pub const GL_GEOMETRY_VERTICES_OUT = __helpers.promoteIntLiteral(c_int, 0x8916, .hex);
pub const GL_GEQUAL = @as(c_int, 0x0206);
pub const GL_GET_TEXTURE_IMAGE_FORMAT = __helpers.promoteIntLiteral(c_int, 0x8291, .hex);
pub const GL_GET_TEXTURE_IMAGE_TYPE = __helpers.promoteIntLiteral(c_int, 0x8292, .hex);
pub const GL_GREATER = @as(c_int, 0x0204);
pub const GL_GREEN = @as(c_int, 0x1904);
pub const GL_GREEN_INTEGER = __helpers.promoteIntLiteral(c_int, 0x8D95, .hex);
pub const GL_GUILTY_CONTEXT_RESET = __helpers.promoteIntLiteral(c_int, 0x8253, .hex);
pub const GL_HALF_FLOAT = @as(c_int, 0x140B);
pub const GL_HIGH_FLOAT = __helpers.promoteIntLiteral(c_int, 0x8DF2, .hex);
pub const GL_HIGH_INT = __helpers.promoteIntLiteral(c_int, 0x8DF5, .hex);
pub const GL_IMAGE_1D = __helpers.promoteIntLiteral(c_int, 0x904C, .hex);
pub const GL_IMAGE_1D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9052, .hex);
pub const GL_IMAGE_2D = __helpers.promoteIntLiteral(c_int, 0x904D, .hex);
pub const GL_IMAGE_2D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9053, .hex);
pub const GL_IMAGE_2D_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x9055, .hex);
pub const GL_IMAGE_2D_MULTISAMPLE_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9056, .hex);
pub const GL_IMAGE_2D_RECT = __helpers.promoteIntLiteral(c_int, 0x904F, .hex);
pub const GL_IMAGE_3D = __helpers.promoteIntLiteral(c_int, 0x904E, .hex);
pub const GL_IMAGE_BINDING_ACCESS = __helpers.promoteIntLiteral(c_int, 0x8F3E, .hex);
pub const GL_IMAGE_BINDING_FORMAT = __helpers.promoteIntLiteral(c_int, 0x906E, .hex);
pub const GL_IMAGE_BINDING_LAYER = __helpers.promoteIntLiteral(c_int, 0x8F3D, .hex);
pub const GL_IMAGE_BINDING_LAYERED = __helpers.promoteIntLiteral(c_int, 0x8F3C, .hex);
pub const GL_IMAGE_BINDING_LEVEL = __helpers.promoteIntLiteral(c_int, 0x8F3B, .hex);
pub const GL_IMAGE_BINDING_NAME = __helpers.promoteIntLiteral(c_int, 0x8F3A, .hex);
pub const GL_IMAGE_BUFFER = __helpers.promoteIntLiteral(c_int, 0x9051, .hex);
pub const GL_IMAGE_CLASS_10_10_10_2 = __helpers.promoteIntLiteral(c_int, 0x82C3, .hex);
pub const GL_IMAGE_CLASS_11_11_10 = __helpers.promoteIntLiteral(c_int, 0x82C2, .hex);
pub const GL_IMAGE_CLASS_1_X_16 = __helpers.promoteIntLiteral(c_int, 0x82BE, .hex);
pub const GL_IMAGE_CLASS_1_X_32 = __helpers.promoteIntLiteral(c_int, 0x82BB, .hex);
pub const GL_IMAGE_CLASS_1_X_8 = __helpers.promoteIntLiteral(c_int, 0x82C1, .hex);
pub const GL_IMAGE_CLASS_2_X_16 = __helpers.promoteIntLiteral(c_int, 0x82BD, .hex);
pub const GL_IMAGE_CLASS_2_X_32 = __helpers.promoteIntLiteral(c_int, 0x82BA, .hex);
pub const GL_IMAGE_CLASS_2_X_8 = __helpers.promoteIntLiteral(c_int, 0x82C0, .hex);
pub const GL_IMAGE_CLASS_4_X_16 = __helpers.promoteIntLiteral(c_int, 0x82BC, .hex);
pub const GL_IMAGE_CLASS_4_X_32 = __helpers.promoteIntLiteral(c_int, 0x82B9, .hex);
pub const GL_IMAGE_CLASS_4_X_8 = __helpers.promoteIntLiteral(c_int, 0x82BF, .hex);
pub const GL_IMAGE_COMPATIBILITY_CLASS = __helpers.promoteIntLiteral(c_int, 0x82A8, .hex);
pub const GL_IMAGE_CUBE = __helpers.promoteIntLiteral(c_int, 0x9050, .hex);
pub const GL_IMAGE_CUBE_MAP_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9054, .hex);
pub const GL_IMAGE_FORMAT_COMPATIBILITY_BY_CLASS = __helpers.promoteIntLiteral(c_int, 0x90C9, .hex);
pub const GL_IMAGE_FORMAT_COMPATIBILITY_BY_SIZE = __helpers.promoteIntLiteral(c_int, 0x90C8, .hex);
pub const GL_IMAGE_FORMAT_COMPATIBILITY_TYPE = __helpers.promoteIntLiteral(c_int, 0x90C7, .hex);
pub const GL_IMAGE_PIXEL_FORMAT = __helpers.promoteIntLiteral(c_int, 0x82A9, .hex);
pub const GL_IMAGE_PIXEL_TYPE = __helpers.promoteIntLiteral(c_int, 0x82AA, .hex);
pub const GL_IMAGE_TEXEL_SIZE = __helpers.promoteIntLiteral(c_int, 0x82A7, .hex);
pub const GL_IMPLEMENTATION_COLOR_READ_FORMAT = __helpers.promoteIntLiteral(c_int, 0x8B9B, .hex);
pub const GL_IMPLEMENTATION_COLOR_READ_TYPE = __helpers.promoteIntLiteral(c_int, 0x8B9A, .hex);
pub const GL_INCR = @as(c_int, 0x1E02);
pub const GL_INCR_WRAP = __helpers.promoteIntLiteral(c_int, 0x8507, .hex);
pub const GL_INFO_LOG_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8B84, .hex);
pub const GL_INNOCENT_CONTEXT_RESET = __helpers.promoteIntLiteral(c_int, 0x8254, .hex);
pub const GL_INT = @as(c_int, 0x1404);
pub const GL_INTERLEAVED_ATTRIBS = __helpers.promoteIntLiteral(c_int, 0x8C8C, .hex);
pub const GL_INTERNALFORMAT_ALPHA_SIZE = __helpers.promoteIntLiteral(c_int, 0x8274, .hex);
pub const GL_INTERNALFORMAT_ALPHA_TYPE = __helpers.promoteIntLiteral(c_int, 0x827B, .hex);
pub const GL_INTERNALFORMAT_BLUE_SIZE = __helpers.promoteIntLiteral(c_int, 0x8273, .hex);
pub const GL_INTERNALFORMAT_BLUE_TYPE = __helpers.promoteIntLiteral(c_int, 0x827A, .hex);
pub const GL_INTERNALFORMAT_DEPTH_SIZE = __helpers.promoteIntLiteral(c_int, 0x8275, .hex);
pub const GL_INTERNALFORMAT_DEPTH_TYPE = __helpers.promoteIntLiteral(c_int, 0x827C, .hex);
pub const GL_INTERNALFORMAT_GREEN_SIZE = __helpers.promoteIntLiteral(c_int, 0x8272, .hex);
pub const GL_INTERNALFORMAT_GREEN_TYPE = __helpers.promoteIntLiteral(c_int, 0x8279, .hex);
pub const GL_INTERNALFORMAT_PREFERRED = __helpers.promoteIntLiteral(c_int, 0x8270, .hex);
pub const GL_INTERNALFORMAT_RED_SIZE = __helpers.promoteIntLiteral(c_int, 0x8271, .hex);
pub const GL_INTERNALFORMAT_RED_TYPE = __helpers.promoteIntLiteral(c_int, 0x8278, .hex);
pub const GL_INTERNALFORMAT_SHARED_SIZE = __helpers.promoteIntLiteral(c_int, 0x8277, .hex);
pub const GL_INTERNALFORMAT_STENCIL_SIZE = __helpers.promoteIntLiteral(c_int, 0x8276, .hex);
pub const GL_INTERNALFORMAT_STENCIL_TYPE = __helpers.promoteIntLiteral(c_int, 0x827D, .hex);
pub const GL_INTERNALFORMAT_SUPPORTED = __helpers.promoteIntLiteral(c_int, 0x826F, .hex);
pub const GL_INT_2_10_10_10_REV = __helpers.promoteIntLiteral(c_int, 0x8D9F, .hex);
pub const GL_INT_IMAGE_1D = __helpers.promoteIntLiteral(c_int, 0x9057, .hex);
pub const GL_INT_IMAGE_1D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x905D, .hex);
pub const GL_INT_IMAGE_2D = __helpers.promoteIntLiteral(c_int, 0x9058, .hex);
pub const GL_INT_IMAGE_2D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x905E, .hex);
pub const GL_INT_IMAGE_2D_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x9060, .hex);
pub const GL_INT_IMAGE_2D_MULTISAMPLE_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9061, .hex);
pub const GL_INT_IMAGE_2D_RECT = __helpers.promoteIntLiteral(c_int, 0x905A, .hex);
pub const GL_INT_IMAGE_3D = __helpers.promoteIntLiteral(c_int, 0x9059, .hex);
pub const GL_INT_IMAGE_BUFFER = __helpers.promoteIntLiteral(c_int, 0x905C, .hex);
pub const GL_INT_IMAGE_CUBE = __helpers.promoteIntLiteral(c_int, 0x905B, .hex);
pub const GL_INT_IMAGE_CUBE_MAP_ARRAY = __helpers.promoteIntLiteral(c_int, 0x905F, .hex);
pub const GL_INT_SAMPLER_1D = __helpers.promoteIntLiteral(c_int, 0x8DC9, .hex);
pub const GL_INT_SAMPLER_1D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8DCE, .hex);
pub const GL_INT_SAMPLER_2D = __helpers.promoteIntLiteral(c_int, 0x8DCA, .hex);
pub const GL_INT_SAMPLER_2D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8DCF, .hex);
pub const GL_INT_SAMPLER_2D_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x9109, .hex);
pub const GL_INT_SAMPLER_2D_MULTISAMPLE_ARRAY = __helpers.promoteIntLiteral(c_int, 0x910C, .hex);
pub const GL_INT_SAMPLER_2D_RECT = __helpers.promoteIntLiteral(c_int, 0x8DCD, .hex);
pub const GL_INT_SAMPLER_3D = __helpers.promoteIntLiteral(c_int, 0x8DCB, .hex);
pub const GL_INT_SAMPLER_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8DD0, .hex);
pub const GL_INT_SAMPLER_CUBE = __helpers.promoteIntLiteral(c_int, 0x8DCC, .hex);
pub const GL_INT_SAMPLER_CUBE_MAP_ARRAY = __helpers.promoteIntLiteral(c_int, 0x900E, .hex);
pub const GL_INT_VEC2 = __helpers.promoteIntLiteral(c_int, 0x8B53, .hex);
pub const GL_INT_VEC3 = __helpers.promoteIntLiteral(c_int, 0x8B54, .hex);
pub const GL_INT_VEC4 = __helpers.promoteIntLiteral(c_int, 0x8B55, .hex);
pub const GL_INVALID_ENUM = @as(c_int, 0x0500);
pub const GL_INVALID_FRAMEBUFFER_OPERATION = @as(c_int, 0x0506);
pub const GL_INVALID_INDEX = __helpers.promoteIntLiteral(c_int, 0xFFFFFFFF, .hex);
pub const GL_INVALID_OPERATION = @as(c_int, 0x0502);
pub const GL_INVALID_VALUE = @as(c_int, 0x0501);
pub const GL_INVERT = @as(c_int, 0x150A);
pub const GL_ISOLINES = __helpers.promoteIntLiteral(c_int, 0x8E7A, .hex);
pub const GL_IS_PER_PATCH = __helpers.promoteIntLiteral(c_int, 0x92E7, .hex);
pub const GL_IS_ROW_MAJOR = __helpers.promoteIntLiteral(c_int, 0x9300, .hex);
pub const GL_KEEP = @as(c_int, 0x1E00);
pub const GL_LAST_VERTEX_CONVENTION = __helpers.promoteIntLiteral(c_int, 0x8E4E, .hex);
pub const GL_LAYER_PROVOKING_VERTEX = __helpers.promoteIntLiteral(c_int, 0x825E, .hex);
pub const GL_LEFT = @as(c_int, 0x0406);
pub const GL_LEQUAL = @as(c_int, 0x0203);
pub const GL_LESS = @as(c_int, 0x0201);
pub const GL_LINE = @as(c_int, 0x1B01);
pub const GL_LINEAR = @as(c_int, 0x2601);
pub const GL_LINEAR_MIPMAP_LINEAR = @as(c_int, 0x2703);
pub const GL_LINEAR_MIPMAP_NEAREST = @as(c_int, 0x2701);
pub const GL_LINES = @as(c_int, 0x0001);
pub const GL_LINES_ADJACENCY = @as(c_int, 0x000A);
pub const GL_LINE_LOOP = @as(c_int, 0x0002);
pub const GL_LINE_SMOOTH = @as(c_int, 0x0B20);
pub const GL_LINE_SMOOTH_HINT = @as(c_int, 0x0C52);
pub const GL_LINE_STRIP = @as(c_int, 0x0003);
pub const GL_LINE_STRIP_ADJACENCY = @as(c_int, 0x000B);
pub const GL_LINE_WIDTH = @as(c_int, 0x0B21);
pub const GL_LINE_WIDTH_GRANULARITY = @as(c_int, 0x0B23);
pub const GL_LINE_WIDTH_RANGE = @as(c_int, 0x0B22);
pub const GL_LINK_STATUS = __helpers.promoteIntLiteral(c_int, 0x8B82, .hex);
pub const GL_LOCATION = __helpers.promoteIntLiteral(c_int, 0x930E, .hex);
pub const GL_LOCATION_COMPONENT = __helpers.promoteIntLiteral(c_int, 0x934A, .hex);
pub const GL_LOCATION_INDEX = __helpers.promoteIntLiteral(c_int, 0x930F, .hex);
pub const GL_LOGIC_OP_MODE = @as(c_int, 0x0BF0);
pub const GL_LOSE_CONTEXT_ON_RESET = __helpers.promoteIntLiteral(c_int, 0x8252, .hex);
pub const GL_LOWER_LEFT = __helpers.promoteIntLiteral(c_int, 0x8CA1, .hex);
pub const GL_LOW_FLOAT = __helpers.promoteIntLiteral(c_int, 0x8DF0, .hex);
pub const GL_LOW_INT = __helpers.promoteIntLiteral(c_int, 0x8DF3, .hex);
pub const GL_MAJOR_VERSION = __helpers.promoteIntLiteral(c_int, 0x821B, .hex);
pub const GL_MANUAL_GENERATE_MIPMAP = __helpers.promoteIntLiteral(c_int, 0x8294, .hex);
pub const GL_MAP_COHERENT_BIT = @as(c_int, 0x0080);
pub const GL_MAP_FLUSH_EXPLICIT_BIT = @as(c_int, 0x0010);
pub const GL_MAP_INVALIDATE_BUFFER_BIT = @as(c_int, 0x0008);
pub const GL_MAP_INVALIDATE_RANGE_BIT = @as(c_int, 0x0004);
pub const GL_MAP_PERSISTENT_BIT = @as(c_int, 0x0040);
pub const GL_MAP_READ_BIT = @as(c_int, 0x0001);
pub const GL_MAP_UNSYNCHRONIZED_BIT = @as(c_int, 0x0020);
pub const GL_MAP_WRITE_BIT = @as(c_int, 0x0002);
pub const GL_MATRIX_STRIDE = __helpers.promoteIntLiteral(c_int, 0x92FF, .hex);
pub const GL_MAX = __helpers.promoteIntLiteral(c_int, 0x8008, .hex);
pub const GL_MAX_3D_TEXTURE_SIZE = __helpers.promoteIntLiteral(c_int, 0x8073, .hex);
pub const GL_MAX_ARRAY_TEXTURE_LAYERS = __helpers.promoteIntLiteral(c_int, 0x88FF, .hex);
pub const GL_MAX_ATOMIC_COUNTER_BUFFER_BINDINGS = __helpers.promoteIntLiteral(c_int, 0x92DC, .hex);
pub const GL_MAX_ATOMIC_COUNTER_BUFFER_SIZE = __helpers.promoteIntLiteral(c_int, 0x92D8, .hex);
pub const GL_MAX_CLIP_DISTANCES = @as(c_int, 0x0D32);
pub const GL_MAX_COLOR_ATTACHMENTS = __helpers.promoteIntLiteral(c_int, 0x8CDF, .hex);
pub const GL_MAX_COLOR_TEXTURE_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x910E, .hex);
pub const GL_MAX_COMBINED_ATOMIC_COUNTERS = __helpers.promoteIntLiteral(c_int, 0x92D7, .hex);
pub const GL_MAX_COMBINED_ATOMIC_COUNTER_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x92D1, .hex);
pub const GL_MAX_COMBINED_CLIP_AND_CULL_DISTANCES = __helpers.promoteIntLiteral(c_int, 0x82FA, .hex);
pub const GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8266, .hex);
pub const GL_MAX_COMBINED_DIMENSIONS = __helpers.promoteIntLiteral(c_int, 0x8282, .hex);
pub const GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8A33, .hex);
pub const GL_MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8A32, .hex);
pub const GL_MAX_COMBINED_IMAGE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x90CF, .hex);
pub const GL_MAX_COMBINED_IMAGE_UNITS_AND_FRAGMENT_OUTPUTS = __helpers.promoteIntLiteral(c_int, 0x8F39, .hex);
pub const GL_MAX_COMBINED_SHADER_OUTPUT_RESOURCES = __helpers.promoteIntLiteral(c_int, 0x8F39, .hex);
pub const GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x90DC, .hex);
pub const GL_MAX_COMBINED_TESS_CONTROL_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8E1E, .hex);
pub const GL_MAX_COMBINED_TESS_EVALUATION_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8E1F, .hex);
pub const GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS = __helpers.promoteIntLiteral(c_int, 0x8B4D, .hex);
pub const GL_MAX_COMBINED_UNIFORM_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x8A2E, .hex);
pub const GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8A31, .hex);
pub const GL_MAX_COMPUTE_ATOMIC_COUNTERS = __helpers.promoteIntLiteral(c_int, 0x8265, .hex);
pub const GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x8264, .hex);
pub const GL_MAX_COMPUTE_IMAGE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x91BD, .hex);
pub const GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x90DB, .hex);
pub const GL_MAX_COMPUTE_SHARED_MEMORY_SIZE = __helpers.promoteIntLiteral(c_int, 0x8262, .hex);
pub const GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS = __helpers.promoteIntLiteral(c_int, 0x91BC, .hex);
pub const GL_MAX_COMPUTE_UNIFORM_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x91BB, .hex);
pub const GL_MAX_COMPUTE_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8263, .hex);
pub const GL_MAX_COMPUTE_WORK_GROUP_COUNT = __helpers.promoteIntLiteral(c_int, 0x91BE, .hex);
pub const GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS = __helpers.promoteIntLiteral(c_int, 0x90EB, .hex);
pub const GL_MAX_COMPUTE_WORK_GROUP_SIZE = __helpers.promoteIntLiteral(c_int, 0x91BF, .hex);
pub const GL_MAX_CUBE_MAP_TEXTURE_SIZE = __helpers.promoteIntLiteral(c_int, 0x851C, .hex);
pub const GL_MAX_CULL_DISTANCES = __helpers.promoteIntLiteral(c_int, 0x82F9, .hex);
pub const GL_MAX_DEBUG_GROUP_STACK_DEPTH = __helpers.promoteIntLiteral(c_int, 0x826C, .hex);
pub const GL_MAX_DEBUG_LOGGED_MESSAGES = __helpers.promoteIntLiteral(c_int, 0x9144, .hex);
pub const GL_MAX_DEBUG_MESSAGE_LENGTH = __helpers.promoteIntLiteral(c_int, 0x9143, .hex);
pub const GL_MAX_DEPTH = __helpers.promoteIntLiteral(c_int, 0x8280, .hex);
pub const GL_MAX_DEPTH_TEXTURE_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x910F, .hex);
pub const GL_MAX_DRAW_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x8824, .hex);
pub const GL_MAX_DUAL_SOURCE_DRAW_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x88FC, .hex);
pub const GL_MAX_ELEMENTS_INDICES = __helpers.promoteIntLiteral(c_int, 0x80E9, .hex);
pub const GL_MAX_ELEMENTS_VERTICES = __helpers.promoteIntLiteral(c_int, 0x80E8, .hex);
pub const GL_MAX_ELEMENT_INDEX = __helpers.promoteIntLiteral(c_int, 0x8D6B, .hex);
pub const GL_MAX_FRAGMENT_ATOMIC_COUNTERS = __helpers.promoteIntLiteral(c_int, 0x92D6, .hex);
pub const GL_MAX_FRAGMENT_ATOMIC_COUNTER_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x92D0, .hex);
pub const GL_MAX_FRAGMENT_IMAGE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x90CE, .hex);
pub const GL_MAX_FRAGMENT_INPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x9125, .hex);
pub const GL_MAX_FRAGMENT_INTERPOLATION_OFFSET = __helpers.promoteIntLiteral(c_int, 0x8E5C, .hex);
pub const GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x90DA, .hex);
pub const GL_MAX_FRAGMENT_UNIFORM_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x8A2D, .hex);
pub const GL_MAX_FRAGMENT_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8B49, .hex);
pub const GL_MAX_FRAGMENT_UNIFORM_VECTORS = __helpers.promoteIntLiteral(c_int, 0x8DFD, .hex);
pub const GL_MAX_FRAMEBUFFER_HEIGHT = __helpers.promoteIntLiteral(c_int, 0x9316, .hex);
pub const GL_MAX_FRAMEBUFFER_LAYERS = __helpers.promoteIntLiteral(c_int, 0x9317, .hex);
pub const GL_MAX_FRAMEBUFFER_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x9318, .hex);
pub const GL_MAX_FRAMEBUFFER_WIDTH = __helpers.promoteIntLiteral(c_int, 0x9315, .hex);
pub const GL_MAX_GEOMETRY_ATOMIC_COUNTERS = __helpers.promoteIntLiteral(c_int, 0x92D5, .hex);
pub const GL_MAX_GEOMETRY_ATOMIC_COUNTER_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x92CF, .hex);
pub const GL_MAX_GEOMETRY_IMAGE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x90CD, .hex);
pub const GL_MAX_GEOMETRY_INPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x9123, .hex);
pub const GL_MAX_GEOMETRY_OUTPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x9124, .hex);
pub const GL_MAX_GEOMETRY_OUTPUT_VERTICES = __helpers.promoteIntLiteral(c_int, 0x8DE0, .hex);
pub const GL_MAX_GEOMETRY_SHADER_INVOCATIONS = __helpers.promoteIntLiteral(c_int, 0x8E5A, .hex);
pub const GL_MAX_GEOMETRY_SHADER_STORAGE_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x90D7, .hex);
pub const GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS = __helpers.promoteIntLiteral(c_int, 0x8C29, .hex);
pub const GL_MAX_GEOMETRY_TOTAL_OUTPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8DE1, .hex);
pub const GL_MAX_GEOMETRY_UNIFORM_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x8A2C, .hex);
pub const GL_MAX_GEOMETRY_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8DDF, .hex);
pub const GL_MAX_HEIGHT = __helpers.promoteIntLiteral(c_int, 0x827F, .hex);
pub const GL_MAX_IMAGE_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x906D, .hex);
pub const GL_MAX_IMAGE_UNITS = __helpers.promoteIntLiteral(c_int, 0x8F38, .hex);
pub const GL_MAX_INTEGER_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x9110, .hex);
pub const GL_MAX_LABEL_LENGTH = __helpers.promoteIntLiteral(c_int, 0x82E8, .hex);
pub const GL_MAX_LAYERS = __helpers.promoteIntLiteral(c_int, 0x8281, .hex);
pub const GL_MAX_NAME_LENGTH = __helpers.promoteIntLiteral(c_int, 0x92F6, .hex);
pub const GL_MAX_NUM_ACTIVE_VARIABLES = __helpers.promoteIntLiteral(c_int, 0x92F7, .hex);
pub const GL_MAX_NUM_COMPATIBLE_SUBROUTINES = __helpers.promoteIntLiteral(c_int, 0x92F8, .hex);
pub const GL_MAX_PATCH_VERTICES = __helpers.promoteIntLiteral(c_int, 0x8E7D, .hex);
pub const GL_MAX_PROGRAM_TEXEL_OFFSET = __helpers.promoteIntLiteral(c_int, 0x8905, .hex);
pub const GL_MAX_PROGRAM_TEXTURE_GATHER_OFFSET = __helpers.promoteIntLiteral(c_int, 0x8E5F, .hex);
pub const GL_MAX_RECTANGLE_TEXTURE_SIZE = __helpers.promoteIntLiteral(c_int, 0x84F8, .hex);
pub const GL_MAX_RENDERBUFFER_SIZE = __helpers.promoteIntLiteral(c_int, 0x84E8, .hex);
pub const GL_MAX_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x8D57, .hex);
pub const GL_MAX_SAMPLE_MASK_WORDS = __helpers.promoteIntLiteral(c_int, 0x8E59, .hex);
pub const GL_MAX_SERVER_WAIT_TIMEOUT = __helpers.promoteIntLiteral(c_int, 0x9111, .hex);
pub const GL_MAX_SHADER_STORAGE_BLOCK_SIZE = __helpers.promoteIntLiteral(c_int, 0x90DE, .hex);
pub const GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS = __helpers.promoteIntLiteral(c_int, 0x90DD, .hex);
pub const GL_MAX_SUBROUTINES = __helpers.promoteIntLiteral(c_int, 0x8DE7, .hex);
pub const GL_MAX_SUBROUTINE_UNIFORM_LOCATIONS = __helpers.promoteIntLiteral(c_int, 0x8DE8, .hex);
pub const GL_MAX_TESS_CONTROL_ATOMIC_COUNTERS = __helpers.promoteIntLiteral(c_int, 0x92D3, .hex);
pub const GL_MAX_TESS_CONTROL_ATOMIC_COUNTER_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x92CD, .hex);
pub const GL_MAX_TESS_CONTROL_IMAGE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x90CB, .hex);
pub const GL_MAX_TESS_CONTROL_INPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x886C, .hex);
pub const GL_MAX_TESS_CONTROL_OUTPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8E83, .hex);
pub const GL_MAX_TESS_CONTROL_SHADER_STORAGE_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x90D8, .hex);
pub const GL_MAX_TESS_CONTROL_TEXTURE_IMAGE_UNITS = __helpers.promoteIntLiteral(c_int, 0x8E81, .hex);
pub const GL_MAX_TESS_CONTROL_TOTAL_OUTPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8E85, .hex);
pub const GL_MAX_TESS_CONTROL_UNIFORM_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x8E89, .hex);
pub const GL_MAX_TESS_CONTROL_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8E7F, .hex);
pub const GL_MAX_TESS_EVALUATION_ATOMIC_COUNTERS = __helpers.promoteIntLiteral(c_int, 0x92D4, .hex);
pub const GL_MAX_TESS_EVALUATION_ATOMIC_COUNTER_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x92CE, .hex);
pub const GL_MAX_TESS_EVALUATION_IMAGE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x90CC, .hex);
pub const GL_MAX_TESS_EVALUATION_INPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x886D, .hex);
pub const GL_MAX_TESS_EVALUATION_OUTPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8E86, .hex);
pub const GL_MAX_TESS_EVALUATION_SHADER_STORAGE_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x90D9, .hex);
pub const GL_MAX_TESS_EVALUATION_TEXTURE_IMAGE_UNITS = __helpers.promoteIntLiteral(c_int, 0x8E82, .hex);
pub const GL_MAX_TESS_EVALUATION_UNIFORM_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x8E8A, .hex);
pub const GL_MAX_TESS_EVALUATION_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8E80, .hex);
pub const GL_MAX_TESS_GEN_LEVEL = __helpers.promoteIntLiteral(c_int, 0x8E7E, .hex);
pub const GL_MAX_TESS_PATCH_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8E84, .hex);
pub const GL_MAX_TEXTURE_BUFFER_SIZE = __helpers.promoteIntLiteral(c_int, 0x8C2B, .hex);
pub const GL_MAX_TEXTURE_IMAGE_UNITS = __helpers.promoteIntLiteral(c_int, 0x8872, .hex);
pub const GL_MAX_TEXTURE_LOD_BIAS = __helpers.promoteIntLiteral(c_int, 0x84FD, .hex);
pub const GL_MAX_TEXTURE_MAX_ANISOTROPY = __helpers.promoteIntLiteral(c_int, 0x84FF, .hex);
pub const GL_MAX_TEXTURE_SIZE = @as(c_int, 0x0D33);
pub const GL_MAX_TRANSFORM_FEEDBACK_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x8E70, .hex);
pub const GL_MAX_TRANSFORM_FEEDBACK_INTERLEAVED_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8C8A, .hex);
pub const GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_ATTRIBS = __helpers.promoteIntLiteral(c_int, 0x8C8B, .hex);
pub const GL_MAX_TRANSFORM_FEEDBACK_SEPARATE_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8C80, .hex);
pub const GL_MAX_UNIFORM_BLOCK_SIZE = __helpers.promoteIntLiteral(c_int, 0x8A30, .hex);
pub const GL_MAX_UNIFORM_BUFFER_BINDINGS = __helpers.promoteIntLiteral(c_int, 0x8A2F, .hex);
pub const GL_MAX_UNIFORM_LOCATIONS = __helpers.promoteIntLiteral(c_int, 0x826E, .hex);
pub const GL_MAX_VARYING_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8B4B, .hex);
pub const GL_MAX_VARYING_FLOATS = __helpers.promoteIntLiteral(c_int, 0x8B4B, .hex);
pub const GL_MAX_VARYING_VECTORS = __helpers.promoteIntLiteral(c_int, 0x8DFC, .hex);
pub const GL_MAX_VERTEX_ATOMIC_COUNTERS = __helpers.promoteIntLiteral(c_int, 0x92D2, .hex);
pub const GL_MAX_VERTEX_ATOMIC_COUNTER_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x92CC, .hex);
pub const GL_MAX_VERTEX_ATTRIBS = __helpers.promoteIntLiteral(c_int, 0x8869, .hex);
pub const GL_MAX_VERTEX_ATTRIB_BINDINGS = __helpers.promoteIntLiteral(c_int, 0x82DA, .hex);
pub const GL_MAX_VERTEX_ATTRIB_RELATIVE_OFFSET = __helpers.promoteIntLiteral(c_int, 0x82D9, .hex);
pub const GL_MAX_VERTEX_ATTRIB_STRIDE = __helpers.promoteIntLiteral(c_int, 0x82E5, .hex);
pub const GL_MAX_VERTEX_IMAGE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x90CA, .hex);
pub const GL_MAX_VERTEX_OUTPUT_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x9122, .hex);
pub const GL_MAX_VERTEX_SHADER_STORAGE_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x90D6, .hex);
pub const GL_MAX_VERTEX_STREAMS = __helpers.promoteIntLiteral(c_int, 0x8E71, .hex);
pub const GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS = __helpers.promoteIntLiteral(c_int, 0x8B4C, .hex);
pub const GL_MAX_VERTEX_UNIFORM_BLOCKS = __helpers.promoteIntLiteral(c_int, 0x8A2B, .hex);
pub const GL_MAX_VERTEX_UNIFORM_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8B4A, .hex);
pub const GL_MAX_VERTEX_UNIFORM_VECTORS = __helpers.promoteIntLiteral(c_int, 0x8DFB, .hex);
pub const GL_MAX_VIEWPORTS = __helpers.promoteIntLiteral(c_int, 0x825B, .hex);
pub const GL_MAX_VIEWPORT_DIMS = @as(c_int, 0x0D3A);
pub const GL_MAX_WIDTH = __helpers.promoteIntLiteral(c_int, 0x827E, .hex);
pub const GL_MEDIUM_FLOAT = __helpers.promoteIntLiteral(c_int, 0x8DF1, .hex);
pub const GL_MEDIUM_INT = __helpers.promoteIntLiteral(c_int, 0x8DF4, .hex);
pub const GL_MIN = __helpers.promoteIntLiteral(c_int, 0x8007, .hex);
pub const GL_MINOR_VERSION = __helpers.promoteIntLiteral(c_int, 0x821C, .hex);
pub const GL_MIN_FRAGMENT_INTERPOLATION_OFFSET = __helpers.promoteIntLiteral(c_int, 0x8E5B, .hex);
pub const GL_MIN_MAP_BUFFER_ALIGNMENT = __helpers.promoteIntLiteral(c_int, 0x90BC, .hex);
pub const GL_MIN_PROGRAM_TEXEL_OFFSET = __helpers.promoteIntLiteral(c_int, 0x8904, .hex);
pub const GL_MIN_PROGRAM_TEXTURE_GATHER_OFFSET = __helpers.promoteIntLiteral(c_int, 0x8E5E, .hex);
pub const GL_MIN_SAMPLE_SHADING_VALUE = __helpers.promoteIntLiteral(c_int, 0x8C37, .hex);
pub const GL_MIPMAP = __helpers.promoteIntLiteral(c_int, 0x8293, .hex);
pub const GL_MIRRORED_REPEAT = __helpers.promoteIntLiteral(c_int, 0x8370, .hex);
pub const GL_MIRROR_CLAMP_TO_EDGE = __helpers.promoteIntLiteral(c_int, 0x8743, .hex);
pub const GL_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x809D, .hex);
pub const GL_NAME_LENGTH = __helpers.promoteIntLiteral(c_int, 0x92F9, .hex);
pub const GL_NAND = @as(c_int, 0x150E);
pub const GL_NEAREST = @as(c_int, 0x2600);
pub const GL_NEAREST_MIPMAP_LINEAR = @as(c_int, 0x2702);
pub const GL_NEAREST_MIPMAP_NEAREST = @as(c_int, 0x2700);
pub const GL_NEGATIVE_ONE_TO_ONE = __helpers.promoteIntLiteral(c_int, 0x935E, .hex);
pub const GL_NEVER = @as(c_int, 0x0200);
pub const GL_NICEST = @as(c_int, 0x1102);
pub const GL_NONE = @as(c_int, 0);
pub const GL_NOOP = @as(c_int, 0x1505);
pub const GL_NOR = @as(c_int, 0x1508);
pub const GL_NOTEQUAL = @as(c_int, 0x0205);
pub const GL_NO_ERROR = @as(c_int, 0);
pub const GL_NO_RESET_NOTIFICATION = __helpers.promoteIntLiteral(c_int, 0x8261, .hex);
pub const GL_NUM_ACTIVE_VARIABLES = __helpers.promoteIntLiteral(c_int, 0x9304, .hex);
pub const GL_NUM_COMPATIBLE_SUBROUTINES = __helpers.promoteIntLiteral(c_int, 0x8E4A, .hex);
pub const GL_NUM_COMPRESSED_TEXTURE_FORMATS = __helpers.promoteIntLiteral(c_int, 0x86A2, .hex);
pub const GL_NUM_EXTENSIONS = __helpers.promoteIntLiteral(c_int, 0x821D, .hex);
pub const GL_NUM_PROGRAM_BINARY_FORMATS = __helpers.promoteIntLiteral(c_int, 0x87FE, .hex);
pub const GL_NUM_SAMPLE_COUNTS = __helpers.promoteIntLiteral(c_int, 0x9380, .hex);
pub const GL_NUM_SHADER_BINARY_FORMATS = __helpers.promoteIntLiteral(c_int, 0x8DF9, .hex);
pub const GL_NUM_SHADING_LANGUAGE_VERSIONS = __helpers.promoteIntLiteral(c_int, 0x82E9, .hex);
pub const GL_NUM_SPIR_V_EXTENSIONS = __helpers.promoteIntLiteral(c_int, 0x9554, .hex);
pub const GL_OBJECT_TYPE = __helpers.promoteIntLiteral(c_int, 0x9112, .hex);
pub const GL_OFFSET = __helpers.promoteIntLiteral(c_int, 0x92FC, .hex);
pub const GL_ONE = @as(c_int, 1);
pub const GL_ONE_MINUS_CONSTANT_ALPHA = __helpers.promoteIntLiteral(c_int, 0x8004, .hex);
pub const GL_ONE_MINUS_CONSTANT_COLOR = __helpers.promoteIntLiteral(c_int, 0x8002, .hex);
pub const GL_ONE_MINUS_DST_ALPHA = @as(c_int, 0x0305);
pub const GL_ONE_MINUS_DST_COLOR = @as(c_int, 0x0307);
pub const GL_ONE_MINUS_SRC1_ALPHA = __helpers.promoteIntLiteral(c_int, 0x88FB, .hex);
pub const GL_ONE_MINUS_SRC1_COLOR = __helpers.promoteIntLiteral(c_int, 0x88FA, .hex);
pub const GL_ONE_MINUS_SRC_ALPHA = @as(c_int, 0x0303);
pub const GL_ONE_MINUS_SRC_COLOR = @as(c_int, 0x0301);
pub const GL_OR = @as(c_int, 0x1507);
pub const GL_OR_INVERTED = @as(c_int, 0x150D);
pub const GL_OR_REVERSE = @as(c_int, 0x150B);
pub const GL_OUT_OF_MEMORY = @as(c_int, 0x0505);
pub const GL_PACK_ALIGNMENT = @as(c_int, 0x0D05);
pub const GL_PACK_COMPRESSED_BLOCK_DEPTH = __helpers.promoteIntLiteral(c_int, 0x912D, .hex);
pub const GL_PACK_COMPRESSED_BLOCK_HEIGHT = __helpers.promoteIntLiteral(c_int, 0x912C, .hex);
pub const GL_PACK_COMPRESSED_BLOCK_SIZE = __helpers.promoteIntLiteral(c_int, 0x912E, .hex);
pub const GL_PACK_COMPRESSED_BLOCK_WIDTH = __helpers.promoteIntLiteral(c_int, 0x912B, .hex);
pub const GL_PACK_IMAGE_HEIGHT = __helpers.promoteIntLiteral(c_int, 0x806C, .hex);
pub const GL_PACK_LSB_FIRST = @as(c_int, 0x0D01);
pub const GL_PACK_ROW_LENGTH = @as(c_int, 0x0D02);
pub const GL_PACK_SKIP_IMAGES = __helpers.promoteIntLiteral(c_int, 0x806B, .hex);
pub const GL_PACK_SKIP_PIXELS = @as(c_int, 0x0D04);
pub const GL_PACK_SKIP_ROWS = @as(c_int, 0x0D03);
pub const GL_PACK_SWAP_BYTES = @as(c_int, 0x0D00);
pub const GL_PARAMETER_BUFFER = __helpers.promoteIntLiteral(c_int, 0x80EE, .hex);
pub const GL_PARAMETER_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x80EF, .hex);
pub const GL_PATCHES = @as(c_int, 0x000E);
pub const GL_PATCH_DEFAULT_INNER_LEVEL = __helpers.promoteIntLiteral(c_int, 0x8E73, .hex);
pub const GL_PATCH_DEFAULT_OUTER_LEVEL = __helpers.promoteIntLiteral(c_int, 0x8E74, .hex);
pub const GL_PATCH_VERTICES = __helpers.promoteIntLiteral(c_int, 0x8E72, .hex);
pub const GL_PIXEL_BUFFER_BARRIER_BIT = @as(c_int, 0x00000080);
pub const GL_PIXEL_PACK_BUFFER = __helpers.promoteIntLiteral(c_int, 0x88EB, .hex);
pub const GL_PIXEL_PACK_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x88ED, .hex);
pub const GL_PIXEL_UNPACK_BUFFER = __helpers.promoteIntLiteral(c_int, 0x88EC, .hex);
pub const GL_PIXEL_UNPACK_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x88EF, .hex);
pub const GL_POINT = @as(c_int, 0x1B00);
pub const GL_POINTS = @as(c_int, 0x0000);
pub const GL_POINT_FADE_THRESHOLD_SIZE = __helpers.promoteIntLiteral(c_int, 0x8128, .hex);
pub const GL_POINT_SIZE = @as(c_int, 0x0B11);
pub const GL_POINT_SIZE_GRANULARITY = @as(c_int, 0x0B13);
pub const GL_POINT_SIZE_RANGE = @as(c_int, 0x0B12);
pub const GL_POINT_SPRITE_COORD_ORIGIN = __helpers.promoteIntLiteral(c_int, 0x8CA0, .hex);
pub const GL_POLYGON_MODE = @as(c_int, 0x0B40);
pub const GL_POLYGON_OFFSET_CLAMP = __helpers.promoteIntLiteral(c_int, 0x8E1B, .hex);
pub const GL_POLYGON_OFFSET_FACTOR = __helpers.promoteIntLiteral(c_int, 0x8038, .hex);
pub const GL_POLYGON_OFFSET_FILL = __helpers.promoteIntLiteral(c_int, 0x8037, .hex);
pub const GL_POLYGON_OFFSET_LINE = @as(c_int, 0x2A02);
pub const GL_POLYGON_OFFSET_POINT = @as(c_int, 0x2A01);
pub const GL_POLYGON_OFFSET_UNITS = @as(c_int, 0x2A00);
pub const GL_POLYGON_SMOOTH = @as(c_int, 0x0B41);
pub const GL_POLYGON_SMOOTH_HINT = @as(c_int, 0x0C53);
pub const GL_PRIMITIVES_GENERATED = __helpers.promoteIntLiteral(c_int, 0x8C87, .hex);
pub const GL_PRIMITIVES_SUBMITTED = __helpers.promoteIntLiteral(c_int, 0x82EF, .hex);
pub const GL_PRIMITIVE_RESTART = __helpers.promoteIntLiteral(c_int, 0x8F9D, .hex);
pub const GL_PRIMITIVE_RESTART_FIXED_INDEX = __helpers.promoteIntLiteral(c_int, 0x8D69, .hex);
pub const GL_PRIMITIVE_RESTART_FOR_PATCHES_SUPPORTED = __helpers.promoteIntLiteral(c_int, 0x8221, .hex);
pub const GL_PRIMITIVE_RESTART_INDEX = __helpers.promoteIntLiteral(c_int, 0x8F9E, .hex);
pub const GL_PROGRAM = __helpers.promoteIntLiteral(c_int, 0x82E2, .hex);
pub const GL_PROGRAM_BINARY_FORMATS = __helpers.promoteIntLiteral(c_int, 0x87FF, .hex);
pub const GL_PROGRAM_BINARY_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8741, .hex);
pub const GL_PROGRAM_BINARY_RETRIEVABLE_HINT = __helpers.promoteIntLiteral(c_int, 0x8257, .hex);
pub const GL_PROGRAM_INPUT = __helpers.promoteIntLiteral(c_int, 0x92E3, .hex);
pub const GL_PROGRAM_OUTPUT = __helpers.promoteIntLiteral(c_int, 0x92E4, .hex);
pub const GL_PROGRAM_PIPELINE = __helpers.promoteIntLiteral(c_int, 0x82E4, .hex);
pub const GL_PROGRAM_PIPELINE_BINDING = __helpers.promoteIntLiteral(c_int, 0x825A, .hex);
pub const GL_PROGRAM_POINT_SIZE = __helpers.promoteIntLiteral(c_int, 0x8642, .hex);
pub const GL_PROGRAM_SEPARABLE = __helpers.promoteIntLiteral(c_int, 0x8258, .hex);
pub const GL_PROVOKING_VERTEX = __helpers.promoteIntLiteral(c_int, 0x8E4F, .hex);
pub const GL_PROXY_TEXTURE_1D = __helpers.promoteIntLiteral(c_int, 0x8063, .hex);
pub const GL_PROXY_TEXTURE_1D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8C19, .hex);
pub const GL_PROXY_TEXTURE_2D = __helpers.promoteIntLiteral(c_int, 0x8064, .hex);
pub const GL_PROXY_TEXTURE_2D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8C1B, .hex);
pub const GL_PROXY_TEXTURE_2D_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x9101, .hex);
pub const GL_PROXY_TEXTURE_2D_MULTISAMPLE_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9103, .hex);
pub const GL_PROXY_TEXTURE_3D = __helpers.promoteIntLiteral(c_int, 0x8070, .hex);
pub const GL_PROXY_TEXTURE_CUBE_MAP = __helpers.promoteIntLiteral(c_int, 0x851B, .hex);
pub const GL_PROXY_TEXTURE_CUBE_MAP_ARRAY = __helpers.promoteIntLiteral(c_int, 0x900B, .hex);
pub const GL_PROXY_TEXTURE_RECTANGLE = __helpers.promoteIntLiteral(c_int, 0x84F7, .hex);
pub const GL_QUADS = @as(c_int, 0x0007);
pub const GL_QUADS_FOLLOW_PROVOKING_VERTEX_CONVENTION = __helpers.promoteIntLiteral(c_int, 0x8E4C, .hex);
pub const GL_QUERY = __helpers.promoteIntLiteral(c_int, 0x82E3, .hex);
pub const GL_QUERY_BUFFER = __helpers.promoteIntLiteral(c_int, 0x9192, .hex);
pub const GL_QUERY_BUFFER_BARRIER_BIT = __helpers.promoteIntLiteral(c_int, 0x00008000, .hex);
pub const GL_QUERY_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x9193, .hex);
pub const GL_QUERY_BY_REGION_NO_WAIT = __helpers.promoteIntLiteral(c_int, 0x8E16, .hex);
pub const GL_QUERY_BY_REGION_NO_WAIT_INVERTED = __helpers.promoteIntLiteral(c_int, 0x8E1A, .hex);
pub const GL_QUERY_BY_REGION_WAIT = __helpers.promoteIntLiteral(c_int, 0x8E15, .hex);
pub const GL_QUERY_BY_REGION_WAIT_INVERTED = __helpers.promoteIntLiteral(c_int, 0x8E19, .hex);
pub const GL_QUERY_COUNTER_BITS = __helpers.promoteIntLiteral(c_int, 0x8864, .hex);
pub const GL_QUERY_NO_WAIT = __helpers.promoteIntLiteral(c_int, 0x8E14, .hex);
pub const GL_QUERY_NO_WAIT_INVERTED = __helpers.promoteIntLiteral(c_int, 0x8E18, .hex);
pub const GL_QUERY_RESULT = __helpers.promoteIntLiteral(c_int, 0x8866, .hex);
pub const GL_QUERY_RESULT_AVAILABLE = __helpers.promoteIntLiteral(c_int, 0x8867, .hex);
pub const GL_QUERY_RESULT_NO_WAIT = __helpers.promoteIntLiteral(c_int, 0x9194, .hex);
pub const GL_QUERY_TARGET = __helpers.promoteIntLiteral(c_int, 0x82EA, .hex);
pub const GL_QUERY_WAIT = __helpers.promoteIntLiteral(c_int, 0x8E13, .hex);
pub const GL_QUERY_WAIT_INVERTED = __helpers.promoteIntLiteral(c_int, 0x8E17, .hex);
pub const GL_R11F_G11F_B10F = __helpers.promoteIntLiteral(c_int, 0x8C3A, .hex);
pub const GL_R16 = __helpers.promoteIntLiteral(c_int, 0x822A, .hex);
pub const GL_R16F = __helpers.promoteIntLiteral(c_int, 0x822D, .hex);
pub const GL_R16I = __helpers.promoteIntLiteral(c_int, 0x8233, .hex);
pub const GL_R16UI = __helpers.promoteIntLiteral(c_int, 0x8234, .hex);
pub const GL_R16_SNORM = __helpers.promoteIntLiteral(c_int, 0x8F98, .hex);
pub const GL_R32F = __helpers.promoteIntLiteral(c_int, 0x822E, .hex);
pub const GL_R32I = __helpers.promoteIntLiteral(c_int, 0x8235, .hex);
pub const GL_R32UI = __helpers.promoteIntLiteral(c_int, 0x8236, .hex);
pub const GL_R3_G3_B2 = @as(c_int, 0x2A10);
pub const GL_R8 = __helpers.promoteIntLiteral(c_int, 0x8229, .hex);
pub const GL_R8I = __helpers.promoteIntLiteral(c_int, 0x8231, .hex);
pub const GL_R8UI = __helpers.promoteIntLiteral(c_int, 0x8232, .hex);
pub const GL_R8_SNORM = __helpers.promoteIntLiteral(c_int, 0x8F94, .hex);
pub const GL_RASTERIZER_DISCARD = __helpers.promoteIntLiteral(c_int, 0x8C89, .hex);
pub const GL_READ_BUFFER = @as(c_int, 0x0C02);
pub const GL_READ_FRAMEBUFFER = __helpers.promoteIntLiteral(c_int, 0x8CA8, .hex);
pub const GL_READ_FRAMEBUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8CAA, .hex);
pub const GL_READ_ONLY = __helpers.promoteIntLiteral(c_int, 0x88B8, .hex);
pub const GL_READ_PIXELS = __helpers.promoteIntLiteral(c_int, 0x828C, .hex);
pub const GL_READ_PIXELS_FORMAT = __helpers.promoteIntLiteral(c_int, 0x828D, .hex);
pub const GL_READ_PIXELS_TYPE = __helpers.promoteIntLiteral(c_int, 0x828E, .hex);
pub const GL_READ_WRITE = __helpers.promoteIntLiteral(c_int, 0x88BA, .hex);
pub const GL_RED = @as(c_int, 0x1903);
pub const GL_RED_INTEGER = __helpers.promoteIntLiteral(c_int, 0x8D94, .hex);
pub const GL_REFERENCED_BY_COMPUTE_SHADER = __helpers.promoteIntLiteral(c_int, 0x930B, .hex);
pub const GL_REFERENCED_BY_FRAGMENT_SHADER = __helpers.promoteIntLiteral(c_int, 0x930A, .hex);
pub const GL_REFERENCED_BY_GEOMETRY_SHADER = __helpers.promoteIntLiteral(c_int, 0x9309, .hex);
pub const GL_REFERENCED_BY_TESS_CONTROL_SHADER = __helpers.promoteIntLiteral(c_int, 0x9307, .hex);
pub const GL_REFERENCED_BY_TESS_EVALUATION_SHADER = __helpers.promoteIntLiteral(c_int, 0x9308, .hex);
pub const GL_REFERENCED_BY_VERTEX_SHADER = __helpers.promoteIntLiteral(c_int, 0x9306, .hex);
pub const GL_RENDERBUFFER = __helpers.promoteIntLiteral(c_int, 0x8D41, .hex);
pub const GL_RENDERBUFFER_ALPHA_SIZE = __helpers.promoteIntLiteral(c_int, 0x8D53, .hex);
pub const GL_RENDERBUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8CA7, .hex);
pub const GL_RENDERBUFFER_BLUE_SIZE = __helpers.promoteIntLiteral(c_int, 0x8D52, .hex);
pub const GL_RENDERBUFFER_DEPTH_SIZE = __helpers.promoteIntLiteral(c_int, 0x8D54, .hex);
pub const GL_RENDERBUFFER_GREEN_SIZE = __helpers.promoteIntLiteral(c_int, 0x8D51, .hex);
pub const GL_RENDERBUFFER_HEIGHT = __helpers.promoteIntLiteral(c_int, 0x8D43, .hex);
pub const GL_RENDERBUFFER_INTERNAL_FORMAT = __helpers.promoteIntLiteral(c_int, 0x8D44, .hex);
pub const GL_RENDERBUFFER_RED_SIZE = __helpers.promoteIntLiteral(c_int, 0x8D50, .hex);
pub const GL_RENDERBUFFER_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x8CAB, .hex);
pub const GL_RENDERBUFFER_STENCIL_SIZE = __helpers.promoteIntLiteral(c_int, 0x8D55, .hex);
pub const GL_RENDERBUFFER_WIDTH = __helpers.promoteIntLiteral(c_int, 0x8D42, .hex);
pub const GL_RENDERER = @as(c_int, 0x1F01);
pub const GL_REPEAT = @as(c_int, 0x2901);
pub const GL_REPLACE = @as(c_int, 0x1E01);
pub const GL_RESET_NOTIFICATION_STRATEGY = __helpers.promoteIntLiteral(c_int, 0x8256, .hex);
pub const GL_RG = __helpers.promoteIntLiteral(c_int, 0x8227, .hex);
pub const GL_RG16 = __helpers.promoteIntLiteral(c_int, 0x822C, .hex);
pub const GL_RG16F = __helpers.promoteIntLiteral(c_int, 0x822F, .hex);
pub const GL_RG16I = __helpers.promoteIntLiteral(c_int, 0x8239, .hex);
pub const GL_RG16UI = __helpers.promoteIntLiteral(c_int, 0x823A, .hex);
pub const GL_RG16_SNORM = __helpers.promoteIntLiteral(c_int, 0x8F99, .hex);
pub const GL_RG32F = __helpers.promoteIntLiteral(c_int, 0x8230, .hex);
pub const GL_RG32I = __helpers.promoteIntLiteral(c_int, 0x823B, .hex);
pub const GL_RG32UI = __helpers.promoteIntLiteral(c_int, 0x823C, .hex);
pub const GL_RG8 = __helpers.promoteIntLiteral(c_int, 0x822B, .hex);
pub const GL_RG8I = __helpers.promoteIntLiteral(c_int, 0x8237, .hex);
pub const GL_RG8UI = __helpers.promoteIntLiteral(c_int, 0x8238, .hex);
pub const GL_RG8_SNORM = __helpers.promoteIntLiteral(c_int, 0x8F95, .hex);
pub const GL_RGB = @as(c_int, 0x1907);
pub const GL_RGB10 = __helpers.promoteIntLiteral(c_int, 0x8052, .hex);
pub const GL_RGB10_A2 = __helpers.promoteIntLiteral(c_int, 0x8059, .hex);
pub const GL_RGB10_A2UI = __helpers.promoteIntLiteral(c_int, 0x906F, .hex);
pub const GL_RGB12 = __helpers.promoteIntLiteral(c_int, 0x8053, .hex);
pub const GL_RGB16 = __helpers.promoteIntLiteral(c_int, 0x8054, .hex);
pub const GL_RGB16F = __helpers.promoteIntLiteral(c_int, 0x881B, .hex);
pub const GL_RGB16I = __helpers.promoteIntLiteral(c_int, 0x8D89, .hex);
pub const GL_RGB16UI = __helpers.promoteIntLiteral(c_int, 0x8D77, .hex);
pub const GL_RGB16_SNORM = __helpers.promoteIntLiteral(c_int, 0x8F9A, .hex);
pub const GL_RGB32F = __helpers.promoteIntLiteral(c_int, 0x8815, .hex);
pub const GL_RGB32I = __helpers.promoteIntLiteral(c_int, 0x8D83, .hex);
pub const GL_RGB32UI = __helpers.promoteIntLiteral(c_int, 0x8D71, .hex);
pub const GL_RGB4 = __helpers.promoteIntLiteral(c_int, 0x804F, .hex);
pub const GL_RGB5 = __helpers.promoteIntLiteral(c_int, 0x8050, .hex);
pub const GL_RGB565 = __helpers.promoteIntLiteral(c_int, 0x8D62, .hex);
pub const GL_RGB5_A1 = __helpers.promoteIntLiteral(c_int, 0x8057, .hex);
pub const GL_RGB8 = __helpers.promoteIntLiteral(c_int, 0x8051, .hex);
pub const GL_RGB8I = __helpers.promoteIntLiteral(c_int, 0x8D8F, .hex);
pub const GL_RGB8UI = __helpers.promoteIntLiteral(c_int, 0x8D7D, .hex);
pub const GL_RGB8_SNORM = __helpers.promoteIntLiteral(c_int, 0x8F96, .hex);
pub const GL_RGB9_E5 = __helpers.promoteIntLiteral(c_int, 0x8C3D, .hex);
pub const GL_RGBA = @as(c_int, 0x1908);
pub const GL_RGBA12 = __helpers.promoteIntLiteral(c_int, 0x805A, .hex);
pub const GL_RGBA16 = __helpers.promoteIntLiteral(c_int, 0x805B, .hex);
pub const GL_RGBA16F = __helpers.promoteIntLiteral(c_int, 0x881A, .hex);
pub const GL_RGBA16I = __helpers.promoteIntLiteral(c_int, 0x8D88, .hex);
pub const GL_RGBA16UI = __helpers.promoteIntLiteral(c_int, 0x8D76, .hex);
pub const GL_RGBA16_SNORM = __helpers.promoteIntLiteral(c_int, 0x8F9B, .hex);
pub const GL_RGBA2 = __helpers.promoteIntLiteral(c_int, 0x8055, .hex);
pub const GL_RGBA32F = __helpers.promoteIntLiteral(c_int, 0x8814, .hex);
pub const GL_RGBA32I = __helpers.promoteIntLiteral(c_int, 0x8D82, .hex);
pub const GL_RGBA32UI = __helpers.promoteIntLiteral(c_int, 0x8D70, .hex);
pub const GL_RGBA4 = __helpers.promoteIntLiteral(c_int, 0x8056, .hex);
pub const GL_RGBA8 = __helpers.promoteIntLiteral(c_int, 0x8058, .hex);
pub const GL_RGBA8I = __helpers.promoteIntLiteral(c_int, 0x8D8E, .hex);
pub const GL_RGBA8UI = __helpers.promoteIntLiteral(c_int, 0x8D7C, .hex);
pub const GL_RGBA8_SNORM = __helpers.promoteIntLiteral(c_int, 0x8F97, .hex);
pub const GL_RGBA_INTEGER = __helpers.promoteIntLiteral(c_int, 0x8D99, .hex);
pub const GL_RGB_INTEGER = __helpers.promoteIntLiteral(c_int, 0x8D98, .hex);
pub const GL_RG_INTEGER = __helpers.promoteIntLiteral(c_int, 0x8228, .hex);
pub const GL_RIGHT = @as(c_int, 0x0407);
pub const GL_SAMPLER = __helpers.promoteIntLiteral(c_int, 0x82E6, .hex);
pub const GL_SAMPLER_1D = __helpers.promoteIntLiteral(c_int, 0x8B5D, .hex);
pub const GL_SAMPLER_1D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8DC0, .hex);
pub const GL_SAMPLER_1D_ARRAY_SHADOW = __helpers.promoteIntLiteral(c_int, 0x8DC3, .hex);
pub const GL_SAMPLER_1D_SHADOW = __helpers.promoteIntLiteral(c_int, 0x8B61, .hex);
pub const GL_SAMPLER_2D = __helpers.promoteIntLiteral(c_int, 0x8B5E, .hex);
pub const GL_SAMPLER_2D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8DC1, .hex);
pub const GL_SAMPLER_2D_ARRAY_SHADOW = __helpers.promoteIntLiteral(c_int, 0x8DC4, .hex);
pub const GL_SAMPLER_2D_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x9108, .hex);
pub const GL_SAMPLER_2D_MULTISAMPLE_ARRAY = __helpers.promoteIntLiteral(c_int, 0x910B, .hex);
pub const GL_SAMPLER_2D_RECT = __helpers.promoteIntLiteral(c_int, 0x8B63, .hex);
pub const GL_SAMPLER_2D_RECT_SHADOW = __helpers.promoteIntLiteral(c_int, 0x8B64, .hex);
pub const GL_SAMPLER_2D_SHADOW = __helpers.promoteIntLiteral(c_int, 0x8B62, .hex);
pub const GL_SAMPLER_3D = __helpers.promoteIntLiteral(c_int, 0x8B5F, .hex);
pub const GL_SAMPLER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8919, .hex);
pub const GL_SAMPLER_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8DC2, .hex);
pub const GL_SAMPLER_CUBE = __helpers.promoteIntLiteral(c_int, 0x8B60, .hex);
pub const GL_SAMPLER_CUBE_MAP_ARRAY = __helpers.promoteIntLiteral(c_int, 0x900C, .hex);
pub const GL_SAMPLER_CUBE_MAP_ARRAY_SHADOW = __helpers.promoteIntLiteral(c_int, 0x900D, .hex);
pub const GL_SAMPLER_CUBE_SHADOW = __helpers.promoteIntLiteral(c_int, 0x8DC5, .hex);
pub const GL_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x80A9, .hex);
pub const GL_SAMPLES_PASSED = __helpers.promoteIntLiteral(c_int, 0x8914, .hex);
pub const GL_SAMPLE_ALPHA_TO_COVERAGE = __helpers.promoteIntLiteral(c_int, 0x809E, .hex);
pub const GL_SAMPLE_ALPHA_TO_ONE = __helpers.promoteIntLiteral(c_int, 0x809F, .hex);
pub const GL_SAMPLE_BUFFERS = __helpers.promoteIntLiteral(c_int, 0x80A8, .hex);
pub const GL_SAMPLE_COVERAGE = __helpers.promoteIntLiteral(c_int, 0x80A0, .hex);
pub const GL_SAMPLE_COVERAGE_INVERT = __helpers.promoteIntLiteral(c_int, 0x80AB, .hex);
pub const GL_SAMPLE_COVERAGE_VALUE = __helpers.promoteIntLiteral(c_int, 0x80AA, .hex);
pub const GL_SAMPLE_MASK = __helpers.promoteIntLiteral(c_int, 0x8E51, .hex);
pub const GL_SAMPLE_MASK_VALUE = __helpers.promoteIntLiteral(c_int, 0x8E52, .hex);
pub const GL_SAMPLE_POSITION = __helpers.promoteIntLiteral(c_int, 0x8E50, .hex);
pub const GL_SAMPLE_SHADING = __helpers.promoteIntLiteral(c_int, 0x8C36, .hex);
pub const GL_SCISSOR_BOX = @as(c_int, 0x0C10);
pub const GL_SCISSOR_TEST = @as(c_int, 0x0C11);
pub const GL_SEPARATE_ATTRIBS = __helpers.promoteIntLiteral(c_int, 0x8C8D, .hex);
pub const GL_SET = @as(c_int, 0x150F);
pub const GL_SHADER = __helpers.promoteIntLiteral(c_int, 0x82E1, .hex);
pub const GL_SHADER_BINARY_FORMATS = __helpers.promoteIntLiteral(c_int, 0x8DF8, .hex);
pub const GL_SHADER_BINARY_FORMAT_SPIR_V = __helpers.promoteIntLiteral(c_int, 0x9551, .hex);
pub const GL_SHADER_COMPILER = __helpers.promoteIntLiteral(c_int, 0x8DFA, .hex);
pub const GL_SHADER_IMAGE_ACCESS_BARRIER_BIT = @as(c_int, 0x00000020);
pub const GL_SHADER_IMAGE_ATOMIC = __helpers.promoteIntLiteral(c_int, 0x82A6, .hex);
pub const GL_SHADER_IMAGE_LOAD = __helpers.promoteIntLiteral(c_int, 0x82A4, .hex);
pub const GL_SHADER_IMAGE_STORE = __helpers.promoteIntLiteral(c_int, 0x82A5, .hex);
pub const GL_SHADER_SOURCE_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8B88, .hex);
pub const GL_SHADER_STORAGE_BARRIER_BIT = @as(c_int, 0x00002000);
pub const GL_SHADER_STORAGE_BLOCK = __helpers.promoteIntLiteral(c_int, 0x92E6, .hex);
pub const GL_SHADER_STORAGE_BUFFER = __helpers.promoteIntLiteral(c_int, 0x90D2, .hex);
pub const GL_SHADER_STORAGE_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x90D3, .hex);
pub const GL_SHADER_STORAGE_BUFFER_OFFSET_ALIGNMENT = __helpers.promoteIntLiteral(c_int, 0x90DF, .hex);
pub const GL_SHADER_STORAGE_BUFFER_SIZE = __helpers.promoteIntLiteral(c_int, 0x90D5, .hex);
pub const GL_SHADER_STORAGE_BUFFER_START = __helpers.promoteIntLiteral(c_int, 0x90D4, .hex);
pub const GL_SHADER_TYPE = __helpers.promoteIntLiteral(c_int, 0x8B4F, .hex);
pub const GL_SHADING_LANGUAGE_VERSION = __helpers.promoteIntLiteral(c_int, 0x8B8C, .hex);
pub const GL_SHORT = @as(c_int, 0x1402);
pub const GL_SIGNALED = __helpers.promoteIntLiteral(c_int, 0x9119, .hex);
pub const GL_SIGNED_NORMALIZED = __helpers.promoteIntLiteral(c_int, 0x8F9C, .hex);
pub const GL_SIMULTANEOUS_TEXTURE_AND_DEPTH_TEST = __helpers.promoteIntLiteral(c_int, 0x82AC, .hex);
pub const GL_SIMULTANEOUS_TEXTURE_AND_DEPTH_WRITE = __helpers.promoteIntLiteral(c_int, 0x82AE, .hex);
pub const GL_SIMULTANEOUS_TEXTURE_AND_STENCIL_TEST = __helpers.promoteIntLiteral(c_int, 0x82AD, .hex);
pub const GL_SIMULTANEOUS_TEXTURE_AND_STENCIL_WRITE = __helpers.promoteIntLiteral(c_int, 0x82AF, .hex);
pub const GL_SMOOTH_LINE_WIDTH_GRANULARITY = @as(c_int, 0x0B23);
pub const GL_SMOOTH_LINE_WIDTH_RANGE = @as(c_int, 0x0B22);
pub const GL_SMOOTH_POINT_SIZE_GRANULARITY = @as(c_int, 0x0B13);
pub const GL_SMOOTH_POINT_SIZE_RANGE = @as(c_int, 0x0B12);
pub const GL_SPIR_V_BINARY = __helpers.promoteIntLiteral(c_int, 0x9552, .hex);
pub const GL_SPIR_V_EXTENSIONS = __helpers.promoteIntLiteral(c_int, 0x9553, .hex);
pub const GL_SRC1_ALPHA = __helpers.promoteIntLiteral(c_int, 0x8589, .hex);
pub const GL_SRC1_COLOR = __helpers.promoteIntLiteral(c_int, 0x88F9, .hex);
pub const GL_SRC_ALPHA = @as(c_int, 0x0302);
pub const GL_SRC_ALPHA_SATURATE = @as(c_int, 0x0308);
pub const GL_SRC_COLOR = @as(c_int, 0x0300);
pub const GL_SRGB = __helpers.promoteIntLiteral(c_int, 0x8C40, .hex);
pub const GL_SRGB8 = __helpers.promoteIntLiteral(c_int, 0x8C41, .hex);
pub const GL_SRGB8_ALPHA8 = __helpers.promoteIntLiteral(c_int, 0x8C43, .hex);
pub const GL_SRGB_ALPHA = __helpers.promoteIntLiteral(c_int, 0x8C42, .hex);
pub const GL_SRGB_READ = __helpers.promoteIntLiteral(c_int, 0x8297, .hex);
pub const GL_SRGB_WRITE = __helpers.promoteIntLiteral(c_int, 0x8298, .hex);
pub const GL_STACK_OVERFLOW = @as(c_int, 0x0503);
pub const GL_STACK_UNDERFLOW = @as(c_int, 0x0504);
pub const GL_STATIC_COPY = __helpers.promoteIntLiteral(c_int, 0x88E6, .hex);
pub const GL_STATIC_DRAW = __helpers.promoteIntLiteral(c_int, 0x88E4, .hex);
pub const GL_STATIC_READ = __helpers.promoteIntLiteral(c_int, 0x88E5, .hex);
pub const GL_STENCIL = @as(c_int, 0x1802);
pub const GL_STENCIL_ATTACHMENT = __helpers.promoteIntLiteral(c_int, 0x8D20, .hex);
pub const GL_STENCIL_BACK_FAIL = __helpers.promoteIntLiteral(c_int, 0x8801, .hex);
pub const GL_STENCIL_BACK_FUNC = __helpers.promoteIntLiteral(c_int, 0x8800, .hex);
pub const GL_STENCIL_BACK_PASS_DEPTH_FAIL = __helpers.promoteIntLiteral(c_int, 0x8802, .hex);
pub const GL_STENCIL_BACK_PASS_DEPTH_PASS = __helpers.promoteIntLiteral(c_int, 0x8803, .hex);
pub const GL_STENCIL_BACK_REF = __helpers.promoteIntLiteral(c_int, 0x8CA3, .hex);
pub const GL_STENCIL_BACK_VALUE_MASK = __helpers.promoteIntLiteral(c_int, 0x8CA4, .hex);
pub const GL_STENCIL_BACK_WRITEMASK = __helpers.promoteIntLiteral(c_int, 0x8CA5, .hex);
pub const GL_STENCIL_BUFFER_BIT = @as(c_int, 0x00000400);
pub const GL_STENCIL_CLEAR_VALUE = @as(c_int, 0x0B91);
pub const GL_STENCIL_COMPONENTS = __helpers.promoteIntLiteral(c_int, 0x8285, .hex);
pub const GL_STENCIL_FAIL = @as(c_int, 0x0B94);
pub const GL_STENCIL_FUNC = @as(c_int, 0x0B92);
pub const GL_STENCIL_INDEX = @as(c_int, 0x1901);
pub const GL_STENCIL_INDEX1 = __helpers.promoteIntLiteral(c_int, 0x8D46, .hex);
pub const GL_STENCIL_INDEX16 = __helpers.promoteIntLiteral(c_int, 0x8D49, .hex);
pub const GL_STENCIL_INDEX4 = __helpers.promoteIntLiteral(c_int, 0x8D47, .hex);
pub const GL_STENCIL_INDEX8 = __helpers.promoteIntLiteral(c_int, 0x8D48, .hex);
pub const GL_STENCIL_PASS_DEPTH_FAIL = @as(c_int, 0x0B95);
pub const GL_STENCIL_PASS_DEPTH_PASS = @as(c_int, 0x0B96);
pub const GL_STENCIL_REF = @as(c_int, 0x0B97);
pub const GL_STENCIL_RENDERABLE = __helpers.promoteIntLiteral(c_int, 0x8288, .hex);
pub const GL_STENCIL_TEST = @as(c_int, 0x0B90);
pub const GL_STENCIL_VALUE_MASK = @as(c_int, 0x0B93);
pub const GL_STENCIL_WRITEMASK = @as(c_int, 0x0B98);
pub const GL_STEREO = @as(c_int, 0x0C33);
pub const GL_STREAM_COPY = __helpers.promoteIntLiteral(c_int, 0x88E2, .hex);
pub const GL_STREAM_DRAW = __helpers.promoteIntLiteral(c_int, 0x88E0, .hex);
pub const GL_STREAM_READ = __helpers.promoteIntLiteral(c_int, 0x88E1, .hex);
pub const GL_SUBPIXEL_BITS = @as(c_int, 0x0D50);
pub const GL_SYNC_CONDITION = __helpers.promoteIntLiteral(c_int, 0x9113, .hex);
pub const GL_SYNC_FENCE = __helpers.promoteIntLiteral(c_int, 0x9116, .hex);
pub const GL_SYNC_FLAGS = __helpers.promoteIntLiteral(c_int, 0x9115, .hex);
pub const GL_SYNC_FLUSH_COMMANDS_BIT = @as(c_int, 0x00000001);
pub const GL_SYNC_GPU_COMMANDS_COMPLETE = __helpers.promoteIntLiteral(c_int, 0x9117, .hex);
pub const GL_SYNC_STATUS = __helpers.promoteIntLiteral(c_int, 0x9114, .hex);
pub const GL_TESS_CONTROL_OUTPUT_VERTICES = __helpers.promoteIntLiteral(c_int, 0x8E75, .hex);
pub const GL_TESS_CONTROL_SHADER = __helpers.promoteIntLiteral(c_int, 0x8E88, .hex);
pub const GL_TESS_CONTROL_SHADER_BIT = @as(c_int, 0x00000008);
pub const GL_TESS_CONTROL_SHADER_PATCHES = __helpers.promoteIntLiteral(c_int, 0x82F1, .hex);
pub const GL_TESS_CONTROL_SUBROUTINE = __helpers.promoteIntLiteral(c_int, 0x92E9, .hex);
pub const GL_TESS_CONTROL_SUBROUTINE_UNIFORM = __helpers.promoteIntLiteral(c_int, 0x92EF, .hex);
pub const GL_TESS_CONTROL_TEXTURE = __helpers.promoteIntLiteral(c_int, 0x829C, .hex);
pub const GL_TESS_EVALUATION_SHADER = __helpers.promoteIntLiteral(c_int, 0x8E87, .hex);
pub const GL_TESS_EVALUATION_SHADER_BIT = @as(c_int, 0x00000010);
pub const GL_TESS_EVALUATION_SHADER_INVOCATIONS = __helpers.promoteIntLiteral(c_int, 0x82F2, .hex);
pub const GL_TESS_EVALUATION_SUBROUTINE = __helpers.promoteIntLiteral(c_int, 0x92EA, .hex);
pub const GL_TESS_EVALUATION_SUBROUTINE_UNIFORM = __helpers.promoteIntLiteral(c_int, 0x92F0, .hex);
pub const GL_TESS_EVALUATION_TEXTURE = __helpers.promoteIntLiteral(c_int, 0x829D, .hex);
pub const GL_TESS_GEN_MODE = __helpers.promoteIntLiteral(c_int, 0x8E76, .hex);
pub const GL_TESS_GEN_POINT_MODE = __helpers.promoteIntLiteral(c_int, 0x8E79, .hex);
pub const GL_TESS_GEN_SPACING = __helpers.promoteIntLiteral(c_int, 0x8E77, .hex);
pub const GL_TESS_GEN_VERTEX_ORDER = __helpers.promoteIntLiteral(c_int, 0x8E78, .hex);
pub const GL_TEXTURE = @as(c_int, 0x1702);
pub const GL_TEXTURE0 = __helpers.promoteIntLiteral(c_int, 0x84C0, .hex);
pub const GL_TEXTURE1 = __helpers.promoteIntLiteral(c_int, 0x84C1, .hex);
pub const GL_TEXTURE10 = __helpers.promoteIntLiteral(c_int, 0x84CA, .hex);
pub const GL_TEXTURE11 = __helpers.promoteIntLiteral(c_int, 0x84CB, .hex);
pub const GL_TEXTURE12 = __helpers.promoteIntLiteral(c_int, 0x84CC, .hex);
pub const GL_TEXTURE13 = __helpers.promoteIntLiteral(c_int, 0x84CD, .hex);
pub const GL_TEXTURE14 = __helpers.promoteIntLiteral(c_int, 0x84CE, .hex);
pub const GL_TEXTURE15 = __helpers.promoteIntLiteral(c_int, 0x84CF, .hex);
pub const GL_TEXTURE16 = __helpers.promoteIntLiteral(c_int, 0x84D0, .hex);
pub const GL_TEXTURE17 = __helpers.promoteIntLiteral(c_int, 0x84D1, .hex);
pub const GL_TEXTURE18 = __helpers.promoteIntLiteral(c_int, 0x84D2, .hex);
pub const GL_TEXTURE19 = __helpers.promoteIntLiteral(c_int, 0x84D3, .hex);
pub const GL_TEXTURE2 = __helpers.promoteIntLiteral(c_int, 0x84C2, .hex);
pub const GL_TEXTURE20 = __helpers.promoteIntLiteral(c_int, 0x84D4, .hex);
pub const GL_TEXTURE21 = __helpers.promoteIntLiteral(c_int, 0x84D5, .hex);
pub const GL_TEXTURE22 = __helpers.promoteIntLiteral(c_int, 0x84D6, .hex);
pub const GL_TEXTURE23 = __helpers.promoteIntLiteral(c_int, 0x84D7, .hex);
pub const GL_TEXTURE24 = __helpers.promoteIntLiteral(c_int, 0x84D8, .hex);
pub const GL_TEXTURE25 = __helpers.promoteIntLiteral(c_int, 0x84D9, .hex);
pub const GL_TEXTURE26 = __helpers.promoteIntLiteral(c_int, 0x84DA, .hex);
pub const GL_TEXTURE27 = __helpers.promoteIntLiteral(c_int, 0x84DB, .hex);
pub const GL_TEXTURE28 = __helpers.promoteIntLiteral(c_int, 0x84DC, .hex);
pub const GL_TEXTURE29 = __helpers.promoteIntLiteral(c_int, 0x84DD, .hex);
pub const GL_TEXTURE3 = __helpers.promoteIntLiteral(c_int, 0x84C3, .hex);
pub const GL_TEXTURE30 = __helpers.promoteIntLiteral(c_int, 0x84DE, .hex);
pub const GL_TEXTURE31 = __helpers.promoteIntLiteral(c_int, 0x84DF, .hex);
pub const GL_TEXTURE4 = __helpers.promoteIntLiteral(c_int, 0x84C4, .hex);
pub const GL_TEXTURE5 = __helpers.promoteIntLiteral(c_int, 0x84C5, .hex);
pub const GL_TEXTURE6 = __helpers.promoteIntLiteral(c_int, 0x84C6, .hex);
pub const GL_TEXTURE7 = __helpers.promoteIntLiteral(c_int, 0x84C7, .hex);
pub const GL_TEXTURE8 = __helpers.promoteIntLiteral(c_int, 0x84C8, .hex);
pub const GL_TEXTURE9 = __helpers.promoteIntLiteral(c_int, 0x84C9, .hex);
pub const GL_TEXTURE_1D = @as(c_int, 0x0DE0);
pub const GL_TEXTURE_1D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8C18, .hex);
pub const GL_TEXTURE_2D = @as(c_int, 0x0DE1);
pub const GL_TEXTURE_2D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8C1A, .hex);
pub const GL_TEXTURE_2D_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x9100, .hex);
pub const GL_TEXTURE_2D_MULTISAMPLE_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9102, .hex);
pub const GL_TEXTURE_3D = __helpers.promoteIntLiteral(c_int, 0x806F, .hex);
pub const GL_TEXTURE_ALPHA_SIZE = __helpers.promoteIntLiteral(c_int, 0x805F, .hex);
pub const GL_TEXTURE_ALPHA_TYPE = __helpers.promoteIntLiteral(c_int, 0x8C13, .hex);
pub const GL_TEXTURE_BASE_LEVEL = __helpers.promoteIntLiteral(c_int, 0x813C, .hex);
pub const GL_TEXTURE_BINDING_1D = __helpers.promoteIntLiteral(c_int, 0x8068, .hex);
pub const GL_TEXTURE_BINDING_1D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8C1C, .hex);
pub const GL_TEXTURE_BINDING_2D = __helpers.promoteIntLiteral(c_int, 0x8069, .hex);
pub const GL_TEXTURE_BINDING_2D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8C1D, .hex);
pub const GL_TEXTURE_BINDING_2D_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x9104, .hex);
pub const GL_TEXTURE_BINDING_2D_MULTISAMPLE_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9105, .hex);
pub const GL_TEXTURE_BINDING_3D = __helpers.promoteIntLiteral(c_int, 0x806A, .hex);
pub const GL_TEXTURE_BINDING_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8C2C, .hex);
pub const GL_TEXTURE_BINDING_CUBE_MAP = __helpers.promoteIntLiteral(c_int, 0x8514, .hex);
pub const GL_TEXTURE_BINDING_CUBE_MAP_ARRAY = __helpers.promoteIntLiteral(c_int, 0x900A, .hex);
pub const GL_TEXTURE_BINDING_RECTANGLE = __helpers.promoteIntLiteral(c_int, 0x84F6, .hex);
pub const GL_TEXTURE_BLUE_SIZE = __helpers.promoteIntLiteral(c_int, 0x805E, .hex);
pub const GL_TEXTURE_BLUE_TYPE = __helpers.promoteIntLiteral(c_int, 0x8C12, .hex);
pub const GL_TEXTURE_BORDER_COLOR = @as(c_int, 0x1004);
pub const GL_TEXTURE_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8C2A, .hex);
pub const GL_TEXTURE_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8C2A, .hex);
pub const GL_TEXTURE_BUFFER_DATA_STORE_BINDING = __helpers.promoteIntLiteral(c_int, 0x8C2D, .hex);
pub const GL_TEXTURE_BUFFER_OFFSET = __helpers.promoteIntLiteral(c_int, 0x919D, .hex);
pub const GL_TEXTURE_BUFFER_OFFSET_ALIGNMENT = __helpers.promoteIntLiteral(c_int, 0x919F, .hex);
pub const GL_TEXTURE_BUFFER_SIZE = __helpers.promoteIntLiteral(c_int, 0x919E, .hex);
pub const GL_TEXTURE_COMPARE_FUNC = __helpers.promoteIntLiteral(c_int, 0x884D, .hex);
pub const GL_TEXTURE_COMPARE_MODE = __helpers.promoteIntLiteral(c_int, 0x884C, .hex);
pub const GL_TEXTURE_COMPRESSED = __helpers.promoteIntLiteral(c_int, 0x86A1, .hex);
pub const GL_TEXTURE_COMPRESSED_BLOCK_HEIGHT = __helpers.promoteIntLiteral(c_int, 0x82B2, .hex);
pub const GL_TEXTURE_COMPRESSED_BLOCK_SIZE = __helpers.promoteIntLiteral(c_int, 0x82B3, .hex);
pub const GL_TEXTURE_COMPRESSED_BLOCK_WIDTH = __helpers.promoteIntLiteral(c_int, 0x82B1, .hex);
pub const GL_TEXTURE_COMPRESSED_IMAGE_SIZE = __helpers.promoteIntLiteral(c_int, 0x86A0, .hex);
pub const GL_TEXTURE_COMPRESSION_HINT = __helpers.promoteIntLiteral(c_int, 0x84EF, .hex);
pub const GL_TEXTURE_CUBE_MAP = __helpers.promoteIntLiteral(c_int, 0x8513, .hex);
pub const GL_TEXTURE_CUBE_MAP_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9009, .hex);
pub const GL_TEXTURE_CUBE_MAP_NEGATIVE_X = __helpers.promoteIntLiteral(c_int, 0x8516, .hex);
pub const GL_TEXTURE_CUBE_MAP_NEGATIVE_Y = __helpers.promoteIntLiteral(c_int, 0x8518, .hex);
pub const GL_TEXTURE_CUBE_MAP_NEGATIVE_Z = __helpers.promoteIntLiteral(c_int, 0x851A, .hex);
pub const GL_TEXTURE_CUBE_MAP_POSITIVE_X = __helpers.promoteIntLiteral(c_int, 0x8515, .hex);
pub const GL_TEXTURE_CUBE_MAP_POSITIVE_Y = __helpers.promoteIntLiteral(c_int, 0x8517, .hex);
pub const GL_TEXTURE_CUBE_MAP_POSITIVE_Z = __helpers.promoteIntLiteral(c_int, 0x8519, .hex);
pub const GL_TEXTURE_CUBE_MAP_SEAMLESS = __helpers.promoteIntLiteral(c_int, 0x884F, .hex);
pub const GL_TEXTURE_DEPTH = __helpers.promoteIntLiteral(c_int, 0x8071, .hex);
pub const GL_TEXTURE_DEPTH_SIZE = __helpers.promoteIntLiteral(c_int, 0x884A, .hex);
pub const GL_TEXTURE_DEPTH_TYPE = __helpers.promoteIntLiteral(c_int, 0x8C16, .hex);
pub const GL_TEXTURE_FETCH_BARRIER_BIT = @as(c_int, 0x00000008);
pub const GL_TEXTURE_FIXED_SAMPLE_LOCATIONS = __helpers.promoteIntLiteral(c_int, 0x9107, .hex);
pub const GL_TEXTURE_GATHER = __helpers.promoteIntLiteral(c_int, 0x82A2, .hex);
pub const GL_TEXTURE_GATHER_SHADOW = __helpers.promoteIntLiteral(c_int, 0x82A3, .hex);
pub const GL_TEXTURE_GREEN_SIZE = __helpers.promoteIntLiteral(c_int, 0x805D, .hex);
pub const GL_TEXTURE_GREEN_TYPE = __helpers.promoteIntLiteral(c_int, 0x8C11, .hex);
pub const GL_TEXTURE_HEIGHT = @as(c_int, 0x1001);
pub const GL_TEXTURE_IMAGE_FORMAT = __helpers.promoteIntLiteral(c_int, 0x828F, .hex);
pub const GL_TEXTURE_IMAGE_TYPE = __helpers.promoteIntLiteral(c_int, 0x8290, .hex);
pub const GL_TEXTURE_IMMUTABLE_FORMAT = __helpers.promoteIntLiteral(c_int, 0x912F, .hex);
pub const GL_TEXTURE_IMMUTABLE_LEVELS = __helpers.promoteIntLiteral(c_int, 0x82DF, .hex);
pub const GL_TEXTURE_INTERNAL_FORMAT = @as(c_int, 0x1003);
pub const GL_TEXTURE_LOD_BIAS = __helpers.promoteIntLiteral(c_int, 0x8501, .hex);
pub const GL_TEXTURE_MAG_FILTER = @as(c_int, 0x2800);
pub const GL_TEXTURE_MAX_ANISOTROPY = __helpers.promoteIntLiteral(c_int, 0x84FE, .hex);
pub const GL_TEXTURE_MAX_LEVEL = __helpers.promoteIntLiteral(c_int, 0x813D, .hex);
pub const GL_TEXTURE_MAX_LOD = __helpers.promoteIntLiteral(c_int, 0x813B, .hex);
pub const GL_TEXTURE_MIN_FILTER = @as(c_int, 0x2801);
pub const GL_TEXTURE_MIN_LOD = __helpers.promoteIntLiteral(c_int, 0x813A, .hex);
pub const GL_TEXTURE_RECTANGLE = __helpers.promoteIntLiteral(c_int, 0x84F5, .hex);
pub const GL_TEXTURE_RED_SIZE = __helpers.promoteIntLiteral(c_int, 0x805C, .hex);
pub const GL_TEXTURE_RED_TYPE = __helpers.promoteIntLiteral(c_int, 0x8C10, .hex);
pub const GL_TEXTURE_SAMPLES = __helpers.promoteIntLiteral(c_int, 0x9106, .hex);
pub const GL_TEXTURE_SHADOW = __helpers.promoteIntLiteral(c_int, 0x82A1, .hex);
pub const GL_TEXTURE_SHARED_SIZE = __helpers.promoteIntLiteral(c_int, 0x8C3F, .hex);
pub const GL_TEXTURE_STENCIL_SIZE = __helpers.promoteIntLiteral(c_int, 0x88F1, .hex);
pub const GL_TEXTURE_SWIZZLE_A = __helpers.promoteIntLiteral(c_int, 0x8E45, .hex);
pub const GL_TEXTURE_SWIZZLE_B = __helpers.promoteIntLiteral(c_int, 0x8E44, .hex);
pub const GL_TEXTURE_SWIZZLE_G = __helpers.promoteIntLiteral(c_int, 0x8E43, .hex);
pub const GL_TEXTURE_SWIZZLE_R = __helpers.promoteIntLiteral(c_int, 0x8E42, .hex);
pub const GL_TEXTURE_SWIZZLE_RGBA = __helpers.promoteIntLiteral(c_int, 0x8E46, .hex);
pub const GL_TEXTURE_TARGET = @as(c_int, 0x1006);
pub const GL_TEXTURE_UPDATE_BARRIER_BIT = @as(c_int, 0x00000100);
pub const GL_TEXTURE_VIEW = __helpers.promoteIntLiteral(c_int, 0x82B5, .hex);
pub const GL_TEXTURE_VIEW_MIN_LAYER = __helpers.promoteIntLiteral(c_int, 0x82DD, .hex);
pub const GL_TEXTURE_VIEW_MIN_LEVEL = __helpers.promoteIntLiteral(c_int, 0x82DB, .hex);
pub const GL_TEXTURE_VIEW_NUM_LAYERS = __helpers.promoteIntLiteral(c_int, 0x82DE, .hex);
pub const GL_TEXTURE_VIEW_NUM_LEVELS = __helpers.promoteIntLiteral(c_int, 0x82DC, .hex);
pub const GL_TEXTURE_WIDTH = @as(c_int, 0x1000);
pub const GL_TEXTURE_WRAP_R = __helpers.promoteIntLiteral(c_int, 0x8072, .hex);
pub const GL_TEXTURE_WRAP_S = @as(c_int, 0x2802);
pub const GL_TEXTURE_WRAP_T = @as(c_int, 0x2803);
pub const GL_TIMEOUT_EXPIRED = __helpers.promoteIntLiteral(c_int, 0x911B, .hex);
pub const GL_TIMEOUT_IGNORED = __helpers.promoteIntLiteral(c_int, 0xFFFFFFFFFFFFFFFF, .hex);
pub const GL_TIMESTAMP = __helpers.promoteIntLiteral(c_int, 0x8E28, .hex);
pub const GL_TIME_ELAPSED = __helpers.promoteIntLiteral(c_int, 0x88BF, .hex);
pub const GL_TOP_LEVEL_ARRAY_SIZE = __helpers.promoteIntLiteral(c_int, 0x930C, .hex);
pub const GL_TOP_LEVEL_ARRAY_STRIDE = __helpers.promoteIntLiteral(c_int, 0x930D, .hex);
pub const GL_TRANSFORM_FEEDBACK = __helpers.promoteIntLiteral(c_int, 0x8E22, .hex);
pub const GL_TRANSFORM_FEEDBACK_ACTIVE = __helpers.promoteIntLiteral(c_int, 0x8E24, .hex);
pub const GL_TRANSFORM_FEEDBACK_BARRIER_BIT = @as(c_int, 0x00000800);
pub const GL_TRANSFORM_FEEDBACK_BINDING = __helpers.promoteIntLiteral(c_int, 0x8E25, .hex);
pub const GL_TRANSFORM_FEEDBACK_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8C8E, .hex);
pub const GL_TRANSFORM_FEEDBACK_BUFFER_ACTIVE = __helpers.promoteIntLiteral(c_int, 0x8E24, .hex);
pub const GL_TRANSFORM_FEEDBACK_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8C8F, .hex);
pub const GL_TRANSFORM_FEEDBACK_BUFFER_INDEX = __helpers.promoteIntLiteral(c_int, 0x934B, .hex);
pub const GL_TRANSFORM_FEEDBACK_BUFFER_MODE = __helpers.promoteIntLiteral(c_int, 0x8C7F, .hex);
pub const GL_TRANSFORM_FEEDBACK_BUFFER_PAUSED = __helpers.promoteIntLiteral(c_int, 0x8E23, .hex);
pub const GL_TRANSFORM_FEEDBACK_BUFFER_SIZE = __helpers.promoteIntLiteral(c_int, 0x8C85, .hex);
pub const GL_TRANSFORM_FEEDBACK_BUFFER_START = __helpers.promoteIntLiteral(c_int, 0x8C84, .hex);
pub const GL_TRANSFORM_FEEDBACK_BUFFER_STRIDE = __helpers.promoteIntLiteral(c_int, 0x934C, .hex);
pub const GL_TRANSFORM_FEEDBACK_OVERFLOW = __helpers.promoteIntLiteral(c_int, 0x82EC, .hex);
pub const GL_TRANSFORM_FEEDBACK_PAUSED = __helpers.promoteIntLiteral(c_int, 0x8E23, .hex);
pub const GL_TRANSFORM_FEEDBACK_PRIMITIVES_WRITTEN = __helpers.promoteIntLiteral(c_int, 0x8C88, .hex);
pub const GL_TRANSFORM_FEEDBACK_STREAM_OVERFLOW = __helpers.promoteIntLiteral(c_int, 0x82ED, .hex);
pub const GL_TRANSFORM_FEEDBACK_VARYING = __helpers.promoteIntLiteral(c_int, 0x92F4, .hex);
pub const GL_TRANSFORM_FEEDBACK_VARYINGS = __helpers.promoteIntLiteral(c_int, 0x8C83, .hex);
pub const GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8C76, .hex);
pub const GL_TRIANGLES = @as(c_int, 0x0004);
pub const GL_TRIANGLES_ADJACENCY = @as(c_int, 0x000C);
pub const GL_TRIANGLE_FAN = @as(c_int, 0x0006);
pub const GL_TRIANGLE_STRIP = @as(c_int, 0x0005);
pub const GL_TRIANGLE_STRIP_ADJACENCY = @as(c_int, 0x000D);
pub const GL_TRUE = @as(c_int, 1);
pub const GL_TYPE = __helpers.promoteIntLiteral(c_int, 0x92FA, .hex);
pub const GL_UNDEFINED_VERTEX = __helpers.promoteIntLiteral(c_int, 0x8260, .hex);
pub const GL_UNIFORM = __helpers.promoteIntLiteral(c_int, 0x92E1, .hex);
pub const GL_UNIFORM_ARRAY_STRIDE = __helpers.promoteIntLiteral(c_int, 0x8A3C, .hex);
pub const GL_UNIFORM_ATOMIC_COUNTER_BUFFER_INDEX = __helpers.promoteIntLiteral(c_int, 0x92DA, .hex);
pub const GL_UNIFORM_BARRIER_BIT = @as(c_int, 0x00000004);
pub const GL_UNIFORM_BLOCK = __helpers.promoteIntLiteral(c_int, 0x92E2, .hex);
pub const GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS = __helpers.promoteIntLiteral(c_int, 0x8A42, .hex);
pub const GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES = __helpers.promoteIntLiteral(c_int, 0x8A43, .hex);
pub const GL_UNIFORM_BLOCK_BINDING = __helpers.promoteIntLiteral(c_int, 0x8A3F, .hex);
pub const GL_UNIFORM_BLOCK_DATA_SIZE = __helpers.promoteIntLiteral(c_int, 0x8A40, .hex);
pub const GL_UNIFORM_BLOCK_INDEX = __helpers.promoteIntLiteral(c_int, 0x8A3A, .hex);
pub const GL_UNIFORM_BLOCK_NAME_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8A41, .hex);
pub const GL_UNIFORM_BLOCK_REFERENCED_BY_COMPUTE_SHADER = __helpers.promoteIntLiteral(c_int, 0x90EC, .hex);
pub const GL_UNIFORM_BLOCK_REFERENCED_BY_FRAGMENT_SHADER = __helpers.promoteIntLiteral(c_int, 0x8A46, .hex);
pub const GL_UNIFORM_BLOCK_REFERENCED_BY_GEOMETRY_SHADER = __helpers.promoteIntLiteral(c_int, 0x8A45, .hex);
pub const GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_CONTROL_SHADER = __helpers.promoteIntLiteral(c_int, 0x84F0, .hex);
pub const GL_UNIFORM_BLOCK_REFERENCED_BY_TESS_EVALUATION_SHADER = __helpers.promoteIntLiteral(c_int, 0x84F1, .hex);
pub const GL_UNIFORM_BLOCK_REFERENCED_BY_VERTEX_SHADER = __helpers.promoteIntLiteral(c_int, 0x8A44, .hex);
pub const GL_UNIFORM_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8A11, .hex);
pub const GL_UNIFORM_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x8A28, .hex);
pub const GL_UNIFORM_BUFFER_OFFSET_ALIGNMENT = __helpers.promoteIntLiteral(c_int, 0x8A34, .hex);
pub const GL_UNIFORM_BUFFER_SIZE = __helpers.promoteIntLiteral(c_int, 0x8A2A, .hex);
pub const GL_UNIFORM_BUFFER_START = __helpers.promoteIntLiteral(c_int, 0x8A29, .hex);
pub const GL_UNIFORM_IS_ROW_MAJOR = __helpers.promoteIntLiteral(c_int, 0x8A3E, .hex);
pub const GL_UNIFORM_MATRIX_STRIDE = __helpers.promoteIntLiteral(c_int, 0x8A3D, .hex);
pub const GL_UNIFORM_NAME_LENGTH = __helpers.promoteIntLiteral(c_int, 0x8A39, .hex);
pub const GL_UNIFORM_OFFSET = __helpers.promoteIntLiteral(c_int, 0x8A3B, .hex);
pub const GL_UNIFORM_SIZE = __helpers.promoteIntLiteral(c_int, 0x8A38, .hex);
pub const GL_UNIFORM_TYPE = __helpers.promoteIntLiteral(c_int, 0x8A37, .hex);
pub const GL_UNKNOWN_CONTEXT_RESET = __helpers.promoteIntLiteral(c_int, 0x8255, .hex);
pub const GL_UNPACK_ALIGNMENT = @as(c_int, 0x0CF5);
pub const GL_UNPACK_COMPRESSED_BLOCK_DEPTH = __helpers.promoteIntLiteral(c_int, 0x9129, .hex);
pub const GL_UNPACK_COMPRESSED_BLOCK_HEIGHT = __helpers.promoteIntLiteral(c_int, 0x9128, .hex);
pub const GL_UNPACK_COMPRESSED_BLOCK_SIZE = __helpers.promoteIntLiteral(c_int, 0x912A, .hex);
pub const GL_UNPACK_COMPRESSED_BLOCK_WIDTH = __helpers.promoteIntLiteral(c_int, 0x9127, .hex);
pub const GL_UNPACK_IMAGE_HEIGHT = __helpers.promoteIntLiteral(c_int, 0x806E, .hex);
pub const GL_UNPACK_LSB_FIRST = @as(c_int, 0x0CF1);
pub const GL_UNPACK_ROW_LENGTH = @as(c_int, 0x0CF2);
pub const GL_UNPACK_SKIP_IMAGES = __helpers.promoteIntLiteral(c_int, 0x806D, .hex);
pub const GL_UNPACK_SKIP_PIXELS = @as(c_int, 0x0CF4);
pub const GL_UNPACK_SKIP_ROWS = @as(c_int, 0x0CF3);
pub const GL_UNPACK_SWAP_BYTES = @as(c_int, 0x0CF0);
pub const GL_UNSIGNALED = __helpers.promoteIntLiteral(c_int, 0x9118, .hex);
pub const GL_UNSIGNED_BYTE = @as(c_int, 0x1401);
pub const GL_UNSIGNED_BYTE_2_3_3_REV = __helpers.promoteIntLiteral(c_int, 0x8362, .hex);
pub const GL_UNSIGNED_BYTE_3_3_2 = __helpers.promoteIntLiteral(c_int, 0x8032, .hex);
pub const GL_UNSIGNED_INT = @as(c_int, 0x1405);
pub const GL_UNSIGNED_INT_10F_11F_11F_REV = __helpers.promoteIntLiteral(c_int, 0x8C3B, .hex);
pub const GL_UNSIGNED_INT_10_10_10_2 = __helpers.promoteIntLiteral(c_int, 0x8036, .hex);
pub const GL_UNSIGNED_INT_24_8 = __helpers.promoteIntLiteral(c_int, 0x84FA, .hex);
pub const GL_UNSIGNED_INT_2_10_10_10_REV = __helpers.promoteIntLiteral(c_int, 0x8368, .hex);
pub const GL_UNSIGNED_INT_5_9_9_9_REV = __helpers.promoteIntLiteral(c_int, 0x8C3E, .hex);
pub const GL_UNSIGNED_INT_8_8_8_8 = __helpers.promoteIntLiteral(c_int, 0x8035, .hex);
pub const GL_UNSIGNED_INT_8_8_8_8_REV = __helpers.promoteIntLiteral(c_int, 0x8367, .hex);
pub const GL_UNSIGNED_INT_ATOMIC_COUNTER = __helpers.promoteIntLiteral(c_int, 0x92DB, .hex);
pub const GL_UNSIGNED_INT_IMAGE_1D = __helpers.promoteIntLiteral(c_int, 0x9062, .hex);
pub const GL_UNSIGNED_INT_IMAGE_1D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9068, .hex);
pub const GL_UNSIGNED_INT_IMAGE_2D = __helpers.promoteIntLiteral(c_int, 0x9063, .hex);
pub const GL_UNSIGNED_INT_IMAGE_2D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x9069, .hex);
pub const GL_UNSIGNED_INT_IMAGE_2D_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x906B, .hex);
pub const GL_UNSIGNED_INT_IMAGE_2D_MULTISAMPLE_ARRAY = __helpers.promoteIntLiteral(c_int, 0x906C, .hex);
pub const GL_UNSIGNED_INT_IMAGE_2D_RECT = __helpers.promoteIntLiteral(c_int, 0x9065, .hex);
pub const GL_UNSIGNED_INT_IMAGE_3D = __helpers.promoteIntLiteral(c_int, 0x9064, .hex);
pub const GL_UNSIGNED_INT_IMAGE_BUFFER = __helpers.promoteIntLiteral(c_int, 0x9067, .hex);
pub const GL_UNSIGNED_INT_IMAGE_CUBE = __helpers.promoteIntLiteral(c_int, 0x9066, .hex);
pub const GL_UNSIGNED_INT_IMAGE_CUBE_MAP_ARRAY = __helpers.promoteIntLiteral(c_int, 0x906A, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_1D = __helpers.promoteIntLiteral(c_int, 0x8DD1, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_1D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8DD6, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_2D = __helpers.promoteIntLiteral(c_int, 0x8DD2, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_2D_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8DD7, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE = __helpers.promoteIntLiteral(c_int, 0x910A, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_2D_MULTISAMPLE_ARRAY = __helpers.promoteIntLiteral(c_int, 0x910D, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_2D_RECT = __helpers.promoteIntLiteral(c_int, 0x8DD5, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_3D = __helpers.promoteIntLiteral(c_int, 0x8DD3, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8DD8, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_CUBE = __helpers.promoteIntLiteral(c_int, 0x8DD4, .hex);
pub const GL_UNSIGNED_INT_SAMPLER_CUBE_MAP_ARRAY = __helpers.promoteIntLiteral(c_int, 0x900F, .hex);
pub const GL_UNSIGNED_INT_VEC2 = __helpers.promoteIntLiteral(c_int, 0x8DC6, .hex);
pub const GL_UNSIGNED_INT_VEC3 = __helpers.promoteIntLiteral(c_int, 0x8DC7, .hex);
pub const GL_UNSIGNED_INT_VEC4 = __helpers.promoteIntLiteral(c_int, 0x8DC8, .hex);
pub const GL_UNSIGNED_NORMALIZED = __helpers.promoteIntLiteral(c_int, 0x8C17, .hex);
pub const GL_UNSIGNED_SHORT = @as(c_int, 0x1403);
pub const GL_UNSIGNED_SHORT_1_5_5_5_REV = __helpers.promoteIntLiteral(c_int, 0x8366, .hex);
pub const GL_UNSIGNED_SHORT_4_4_4_4 = __helpers.promoteIntLiteral(c_int, 0x8033, .hex);
pub const GL_UNSIGNED_SHORT_4_4_4_4_REV = __helpers.promoteIntLiteral(c_int, 0x8365, .hex);
pub const GL_UNSIGNED_SHORT_5_5_5_1 = __helpers.promoteIntLiteral(c_int, 0x8034, .hex);
pub const GL_UNSIGNED_SHORT_5_6_5 = __helpers.promoteIntLiteral(c_int, 0x8363, .hex);
pub const GL_UNSIGNED_SHORT_5_6_5_REV = __helpers.promoteIntLiteral(c_int, 0x8364, .hex);
pub const GL_UPPER_LEFT = __helpers.promoteIntLiteral(c_int, 0x8CA2, .hex);
pub const GL_VALIDATE_STATUS = __helpers.promoteIntLiteral(c_int, 0x8B83, .hex);
pub const GL_VENDOR = @as(c_int, 0x1F00);
pub const GL_VERSION = @as(c_int, 0x1F02);
pub const GL_VERTEX_ARRAY = __helpers.promoteIntLiteral(c_int, 0x8074, .hex);
pub const GL_VERTEX_ARRAY_BINDING = __helpers.promoteIntLiteral(c_int, 0x85B5, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_BARRIER_BIT = @as(c_int, 0x00000001);
pub const GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING = __helpers.promoteIntLiteral(c_int, 0x889F, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_DIVISOR = __helpers.promoteIntLiteral(c_int, 0x88FE, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_ENABLED = __helpers.promoteIntLiteral(c_int, 0x8622, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_INTEGER = __helpers.promoteIntLiteral(c_int, 0x88FD, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_LONG = __helpers.promoteIntLiteral(c_int, 0x874E, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_NORMALIZED = __helpers.promoteIntLiteral(c_int, 0x886A, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_POINTER = __helpers.promoteIntLiteral(c_int, 0x8645, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_SIZE = __helpers.promoteIntLiteral(c_int, 0x8623, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_STRIDE = __helpers.promoteIntLiteral(c_int, 0x8624, .hex);
pub const GL_VERTEX_ATTRIB_ARRAY_TYPE = __helpers.promoteIntLiteral(c_int, 0x8625, .hex);
pub const GL_VERTEX_ATTRIB_BINDING = __helpers.promoteIntLiteral(c_int, 0x82D4, .hex);
pub const GL_VERTEX_ATTRIB_RELATIVE_OFFSET = __helpers.promoteIntLiteral(c_int, 0x82D5, .hex);
pub const GL_VERTEX_BINDING_BUFFER = __helpers.promoteIntLiteral(c_int, 0x8F4F, .hex);
pub const GL_VERTEX_BINDING_DIVISOR = __helpers.promoteIntLiteral(c_int, 0x82D6, .hex);
pub const GL_VERTEX_BINDING_OFFSET = __helpers.promoteIntLiteral(c_int, 0x82D7, .hex);
pub const GL_VERTEX_BINDING_STRIDE = __helpers.promoteIntLiteral(c_int, 0x82D8, .hex);
pub const GL_VERTEX_PROGRAM_POINT_SIZE = __helpers.promoteIntLiteral(c_int, 0x8642, .hex);
pub const GL_VERTEX_SHADER = __helpers.promoteIntLiteral(c_int, 0x8B31, .hex);
pub const GL_VERTEX_SHADER_BIT = @as(c_int, 0x00000001);
pub const GL_VERTEX_SHADER_INVOCATIONS = __helpers.promoteIntLiteral(c_int, 0x82F0, .hex);
pub const GL_VERTEX_SUBROUTINE = __helpers.promoteIntLiteral(c_int, 0x92E8, .hex);
pub const GL_VERTEX_SUBROUTINE_UNIFORM = __helpers.promoteIntLiteral(c_int, 0x92EE, .hex);
pub const GL_VERTEX_TEXTURE = __helpers.promoteIntLiteral(c_int, 0x829B, .hex);
pub const GL_VERTICES_SUBMITTED = __helpers.promoteIntLiteral(c_int, 0x82EE, .hex);
pub const GL_VIEWPORT = @as(c_int, 0x0BA2);
pub const GL_VIEWPORT_BOUNDS_RANGE = __helpers.promoteIntLiteral(c_int, 0x825D, .hex);
pub const GL_VIEWPORT_INDEX_PROVOKING_VERTEX = __helpers.promoteIntLiteral(c_int, 0x825F, .hex);
pub const GL_VIEWPORT_SUBPIXEL_BITS = __helpers.promoteIntLiteral(c_int, 0x825C, .hex);
pub const GL_VIEW_CLASS_128_BITS = __helpers.promoteIntLiteral(c_int, 0x82C4, .hex);
pub const GL_VIEW_CLASS_16_BITS = __helpers.promoteIntLiteral(c_int, 0x82CA, .hex);
pub const GL_VIEW_CLASS_24_BITS = __helpers.promoteIntLiteral(c_int, 0x82C9, .hex);
pub const GL_VIEW_CLASS_32_BITS = __helpers.promoteIntLiteral(c_int, 0x82C8, .hex);
pub const GL_VIEW_CLASS_48_BITS = __helpers.promoteIntLiteral(c_int, 0x82C7, .hex);
pub const GL_VIEW_CLASS_64_BITS = __helpers.promoteIntLiteral(c_int, 0x82C6, .hex);
pub const GL_VIEW_CLASS_8_BITS = __helpers.promoteIntLiteral(c_int, 0x82CB, .hex);
pub const GL_VIEW_CLASS_96_BITS = __helpers.promoteIntLiteral(c_int, 0x82C5, .hex);
pub const GL_VIEW_CLASS_BPTC_FLOAT = __helpers.promoteIntLiteral(c_int, 0x82D3, .hex);
pub const GL_VIEW_CLASS_BPTC_UNORM = __helpers.promoteIntLiteral(c_int, 0x82D2, .hex);
pub const GL_VIEW_CLASS_RGTC1_RED = __helpers.promoteIntLiteral(c_int, 0x82D0, .hex);
pub const GL_VIEW_CLASS_RGTC2_RG = __helpers.promoteIntLiteral(c_int, 0x82D1, .hex);
pub const GL_VIEW_CLASS_S3TC_DXT1_RGB = __helpers.promoteIntLiteral(c_int, 0x82CC, .hex);
pub const GL_VIEW_CLASS_S3TC_DXT1_RGBA = __helpers.promoteIntLiteral(c_int, 0x82CD, .hex);
pub const GL_VIEW_CLASS_S3TC_DXT3_RGBA = __helpers.promoteIntLiteral(c_int, 0x82CE, .hex);
pub const GL_VIEW_CLASS_S3TC_DXT5_RGBA = __helpers.promoteIntLiteral(c_int, 0x82CF, .hex);
pub const GL_VIEW_COMPATIBILITY_CLASS = __helpers.promoteIntLiteral(c_int, 0x82B6, .hex);
pub const GL_WAIT_FAILED = __helpers.promoteIntLiteral(c_int, 0x911D, .hex);
pub const GL_WRITE_ONLY = __helpers.promoteIntLiteral(c_int, 0x88B9, .hex);
pub const GL_XOR = @as(c_int, 0x1506);
pub const GL_ZERO = @as(c_int, 0);
pub const GL_ZERO_TO_ONE = __helpers.promoteIntLiteral(c_int, 0x935F, .hex);
pub const __khrplatform_h_ = "";
pub const KHRONOS_APICALL = @compileError("unable to translate macro: undefined identifier `dllimport`"); // C:\Users\ianb5\Desktop\Github\irec\DVAP\lib\GLAD\include\\KHR/khrplatform.h:107:12
pub const KHRONOS_APIENTRY = @compileError("unable to translate C expr: unexpected token '__stdcall'"); // C:\Users\ianb5\Desktop\Github\irec\DVAP\lib\GLAD\include\\KHR/khrplatform.h:124:12
pub const KHRONOS_APIATTRIBUTES = "";
pub const __CLANG_STDINT_H = "";
pub const _STDINT_H = "";
pub const _INC_CRTDEFS = "";
pub const _INC_CORECRT = "";
pub const _INC__MINGW_H = "";
pub const _INC_CRTDEFS_MACRO = "";
pub const __MINGW64_PASTE2 = @compileError("unable to translate C expr: unexpected token '##'"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:10:9
pub inline fn __MINGW64_PASTE(x: anytype, y: anytype) @TypeOf(__MINGW64_PASTE2(x, y)) {
    _ = &x;
    _ = &y;
    return __MINGW64_PASTE2(x, y);
}
pub const __STRINGIFY = @compileError("unable to translate C expr: unexpected token ''"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:13:9
pub inline fn __MINGW64_STRINGIFY(x: anytype) @TypeOf(__STRINGIFY(x)) {
    _ = &x;
    return __STRINGIFY(x);
}
pub const __MINGW64_VERSION_MAJOR = @as(c_int, 13);
pub const __MINGW64_VERSION_MINOR = @as(c_int, 0);
pub const __MINGW64_VERSION_BUGFIX = @as(c_int, 0);
pub const __MINGW64_VERSION_RC = @as(c_int, 0);
pub const __MINGW64_VERSION_STR = __MINGW64_STRINGIFY(__MINGW64_VERSION_MAJOR) ++ "." ++ __MINGW64_STRINGIFY(__MINGW64_VERSION_MINOR) ++ "." ++ __MINGW64_STRINGIFY(__MINGW64_VERSION_BUGFIX);
pub const __MINGW64_VERSION_STATE = "alpha";
pub const __MINGW32_MAJOR_VERSION = @as(c_int, 3);
pub const __MINGW32_MINOR_VERSION = @as(c_int, 11);
pub const _M_AMD64 = @as(c_int, 100);
pub const _M_X64 = @as(c_int, 100);
pub const __MINGW_USE_UNDERSCORE_PREFIX = @as(c_int, 0);
pub const __MINGW_IMP_SYMBOL = @compileError("unable to translate macro: undefined identifier `__imp_`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:129:11
pub const __MINGW_IMP_LSYMBOL = @compileError("unable to translate macro: undefined identifier `__imp_`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:130:11
pub inline fn __MINGW_USYMBOL(sym: anytype) @TypeOf(sym) {
    _ = &sym;
    return sym;
}
pub const __MINGW_LSYMBOL = @compileError("unable to translate macro: undefined identifier `_`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:132:11
pub const __MINGW_ASM_CALL = @compileError("unable to translate C expr: unexpected token '__asm__'"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:140:9
pub const __MINGW_ASM_CRT_CALL = @compileError("unable to translate C expr: unexpected token '__asm__'"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:141:9
pub const __MINGW_EXTENSION = @compileError("unable to translate C expr: unexpected token '__extension__'"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:173:13
pub const __C89_NAMELESS = __MINGW_EXTENSION;
pub const __C89_NAMELESSSTRUCTNAME = "";
pub const __C89_NAMELESSSTRUCTNAME1 = "";
pub const __C89_NAMELESSSTRUCTNAME2 = "";
pub const __C89_NAMELESSSTRUCTNAME3 = "";
pub const __C89_NAMELESSSTRUCTNAME4 = "";
pub const __C89_NAMELESSSTRUCTNAME5 = "";
pub const __C89_NAMELESSUNIONNAME = "";
pub const __C89_NAMELESSUNIONNAME1 = "";
pub const __C89_NAMELESSUNIONNAME2 = "";
pub const __C89_NAMELESSUNIONNAME3 = "";
pub const __C89_NAMELESSUNIONNAME4 = "";
pub const __C89_NAMELESSUNIONNAME5 = "";
pub const __C89_NAMELESSUNIONNAME6 = "";
pub const __C89_NAMELESSUNIONNAME7 = "";
pub const __C89_NAMELESSUNIONNAME8 = "";
pub const __GNU_EXTENSION = __MINGW_EXTENSION;
pub const __MINGW_HAVE_ANSI_C99_PRINTF = @as(c_int, 1);
pub const __MINGW_HAVE_WIDE_C99_PRINTF = @as(c_int, 1);
pub const __MINGW_HAVE_ANSI_C99_SCANF = @as(c_int, 1);
pub const __MINGW_HAVE_WIDE_C99_SCANF = @as(c_int, 1);
pub const __MINGW_POISON_NAME = @compileError("unable to translate macro: undefined identifier `_layout_has_not_been_verified_and_its_declaration_is_most_likely_incorrect`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:213:11
pub const __MSABI_LONG = __helpers.L_SUFFIX;
pub const __MINGW_GCC_VERSION = ((__GNUC__ * @as(c_int, 10000)) + (__GNUC_MINOR__ * @as(c_int, 100))) + __GNUC_PATCHLEVEL__;
pub inline fn __MINGW_GNUC_PREREQ(major: anytype, minor: anytype) @TypeOf((__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor))) {
    _ = &major;
    _ = &minor;
    return (__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor));
}
pub inline fn __MINGW_MSC_PREREQ(major: anytype, minor: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &major;
    _ = &minor;
    return @as(c_int, 0);
}
pub inline fn __MINGW_ATTRIB_DEPRECATED_STR(X: anytype) void {
    _ = &X;
    return;
}
pub const __MINGW_SEC_WARN_STR = "This function or variable may be unsafe, use _CRT_SECURE_NO_WARNINGS to disable deprecation";
pub const __MINGW_MSVC2005_DEPREC_STR = "This POSIX function is deprecated beginning in Visual C++ 2005, use _CRT_NONSTDC_NO_DEPRECATE to disable deprecation";
pub const __MINGW_ATTRIB_DEPRECATED_MSVC2005 = __MINGW_ATTRIB_DEPRECATED_STR(__MINGW_MSVC2005_DEPREC_STR);
pub const __MINGW_ATTRIB_DEPRECATED_SEC_WARN = __MINGW_ATTRIB_DEPRECATED_STR(__MINGW_SEC_WARN_STR);
pub const __MINGW_MS_PRINTF = @compileError("unable to translate macro: undefined identifier `__format__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:293:9
pub const __MINGW_MS_SCANF = @compileError("unable to translate macro: undefined identifier `__format__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:296:9
pub const __MINGW_GNU_PRINTF = @compileError("unable to translate macro: undefined identifier `__format__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:299:9
pub const __MINGW_GNU_SCANF = @compileError("unable to translate macro: undefined identifier `__format__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:302:9
pub const __mingw_ovr = @compileError("unable to translate macro: undefined identifier `__unused__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:311:11
pub const __mingw_attribute_artificial = @compileError("unable to translate macro: undefined identifier `__artificial__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:318:11
pub const __MINGW_SELECTANY = @compileError("unable to translate macro: undefined identifier `__selectany__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_mac.h:324:9
pub const __MINGW_FORTIFY_LEVEL = @as(c_int, 0);
pub const __mingw_bos_ovr = __mingw_ovr;
pub const __MINGW_FORTIFY_VA_ARG = @as(c_int, 0);
pub const _INC_MINGW_SECAPI = "";
pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES = @as(c_int, 0);
pub const _CRT_SECURE_CPP_OVERLOAD_SECURE_NAMES_MEMORY = @as(c_int, 0);
pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES = @as(c_int, 0);
pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_COUNT = @as(c_int, 0);
pub const _CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY = @as(c_int, 0);
pub const __MINGW_CRT_NAME_CONCAT2 = @compileError("unable to translate macro: undefined identifier `_s`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_secapi.h:41:9
pub const __CRT_SECURE_CPP_OVERLOAD_STANDARD_NAMES_MEMORY_0_3_ = @compileError("unable to translate C expr: unexpected token '__cdecl'"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw_secapi.h:69:9
pub const __LONG32 = c_long;
pub const __MINGW_IMPORT = @compileError("unable to translate macro: undefined identifier `__dllimport__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:44:12
pub const __USE_CRTIMP = @as(c_int, 1);
pub const _CRTIMP = @compileError("unable to translate macro: undefined identifier `__dllimport__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:52:15
pub const __DECLSPEC_SUPPORTED = "";
pub const USE___UUIDOF = @as(c_int, 0);
pub const _inline = @compileError("unable to translate C expr: unexpected token '__inline'"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:74:9
pub const __CRT_INLINE = @compileError("unable to translate macro: undefined identifier `__gnu_inline__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:83:11
pub const __MINGW_INTRIN_INLINE = @compileError("unable to translate macro: undefined identifier `__always_inline__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:90:9
pub const __MINGW_CXX11_CONSTEXPR = "";
pub const __MINGW_CXX14_CONSTEXPR = "";
pub const __UNUSED_PARAM = @compileError("unable to translate macro: undefined identifier `__unused__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:118:11
pub const __restrict_arr = @compileError("unable to translate C expr: unexpected token '__restrict'"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:133:10
pub const __MINGW_ATTRIB_NORETURN = @compileError("unable to translate macro: undefined identifier `__noreturn__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:149:9
pub const __MINGW_ATTRIB_CONST = @compileError("unable to translate C expr: unexpected token '__attribute__'"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:150:9
pub const __MINGW_ATTRIB_MALLOC = @compileError("unable to translate macro: undefined identifier `__malloc__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:160:9
pub const __MINGW_ATTRIB_PURE = @compileError("unable to translate macro: undefined identifier `__pure__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:161:9
pub const __MINGW_ATTRIB_NONNULL = @compileError("unable to translate macro: undefined identifier `__nonnull__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:174:9
pub const __MINGW_ATTRIB_UNUSED = @compileError("unable to translate macro: undefined identifier `__unused__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:180:9
pub const __MINGW_ATTRIB_USED = @compileError("unable to translate macro: undefined identifier `__used__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:186:9
pub const __MINGW_ATTRIB_DEPRECATED = @compileError("unable to translate macro: undefined identifier `__deprecated__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:187:9
pub const __MINGW_ATTRIB_DEPRECATED_MSG = @compileError("unable to translate macro: undefined identifier `__deprecated__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:189:9
pub const __MINGW_NOTHROW = @compileError("unable to translate macro: undefined identifier `__nothrow__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:204:9
pub const __MINGW_ATTRIB_NO_OPTIMIZE = @compileError("unable to translate macro: undefined identifier `__optimize__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:212:9
pub const __MINGW_PRAGMA_PARAM = @compileError("unable to translate macro: undefined identifier `_Pragma`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:218:9
pub const __MINGW_BROKEN_INTERFACE = @compileError("unable to translate macro: undefined identifier `message`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:225:9
pub const _UCRT = "";
pub inline fn __MINGW_UCRT_ASM_CALL(func: anytype) @TypeOf(__MINGW_ASM_CALL(func)) {
    _ = &func;
    return __MINGW_ASM_CALL(func);
}
pub const _INT128_DEFINED = "";
pub const __int8 = u8;
pub const __int16 = c_short;
pub const __int32 = c_int;
pub const __int64 = c_longlong;
pub const __ptr32 = "";
pub const __ptr64 = "";
pub const __unaligned = "";
pub const __w64 = "";
pub const __forceinline = @compileError("unable to translate macro: undefined identifier `__always_inline__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:290:9
pub const __nothrow = "";
pub const _INC_VADEFS = "";
pub const MINGW_SDK_INIT = "";
pub const MINGW_HAS_SECURE_API = @as(c_int, 1);
pub const __STDC_SECURE_LIB__ = @as(c_long, 200411);
pub const __GOT_SECURE_LIB__ = __STDC_SECURE_LIB__;
pub const MINGW_DDK_H = "";
pub const MINGW_HAS_DDK_H = @as(c_int, 1);
pub const __GNUC_VA_LIST = "";
pub const _VA_LIST_DEFINED = "";
pub inline fn _ADDRESSOF(v: anytype) @TypeOf(&v) {
    _ = &v;
    return &v;
}
pub const _crt_va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\vadefs.h:48:9
pub const _crt_va_arg = @compileError("unable to translate macro: undefined identifier `__builtin_va_arg`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\vadefs.h:49:9
pub const _crt_va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\vadefs.h:50:9
pub const _crt_va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\vadefs.h:51:9
pub const __CRT_STRINGIZE = @compileError("unable to translate C expr: unexpected token ''"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:309:9
pub inline fn _CRT_STRINGIZE(_Value: anytype) @TypeOf(__CRT_STRINGIZE(_Value)) {
    _ = &_Value;
    return __CRT_STRINGIZE(_Value);
}
pub const __CRT_WIDE = @compileError("unable to translate macro: undefined identifier `L`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:314:9
pub inline fn _CRT_WIDE(_String: anytype) @TypeOf(__CRT_WIDE(_String)) {
    _ = &_String;
    return __CRT_WIDE(_String);
}
pub const _W64 = "";
pub const _CRTIMP_NOIA64 = _CRTIMP;
pub const _CRTIMP2 = _CRTIMP;
pub const _CRTIMP_ALTERNATIVE = _CRTIMP;
pub const _CRT_ALTERNATIVE_IMPORTED = "";
pub const _MRTIMP2 = _CRTIMP;
pub const _DLL = "";
pub const _MT = "";
pub const _MCRTIMP = _CRTIMP;
pub const _CRTIMP_PURE = _CRTIMP;
pub const _PGLOBAL = "";
pub const _AGLOBAL = "";
pub const _SECURECRT_FILL_BUFFER_PATTERN = @as(c_int, 0xFD);
pub const _CRT_DEPRECATE_TEXT = @compileError("unable to translate macro: undefined identifier `deprecated`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:373:9
pub inline fn _CRT_INSECURE_DEPRECATE_MEMORY(_Replacement: anytype) void {
    _ = &_Replacement;
    return;
}
pub inline fn _CRT_INSECURE_DEPRECATE_GLOBALS(_Replacement: anytype) void {
    _ = &_Replacement;
    return;
}
pub const _CRT_MANAGED_HEAP_DEPRECATE = "";
pub inline fn _CRT_OBSOLETE(_NewItem: anytype) void {
    _ = &_NewItem;
    return;
}
pub const _CONST_RETURN = "";
pub const UNALIGNED = "";
pub const _CRT_ALIGN = @compileError("unable to translate macro: undefined identifier `__aligned__`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:415:9
pub const __CRTDECL = @compileError("unable to translate C expr: unexpected token '__cdecl'"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:422:9
pub const _ARGMAX = @as(c_int, 100);
pub const _TRUNCATE = __helpers.cast(usize, -@as(c_int, 1));
pub inline fn _CRT_UNUSED(x: anytype) anyopaque {
    _ = &x;
    return __helpers.cast(anyopaque, x);
}
pub const __USE_MINGW_ANSI_STDIO = @as(c_int, 0);
pub const _CRT_glob = @compileError("unable to translate macro: undefined identifier `_dowildcard`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:479:9
pub const __ANONYMOUS_DEFINED = "";
pub const _ANONYMOUS_UNION = __MINGW_EXTENSION;
pub const _ANONYMOUS_STRUCT = __MINGW_EXTENSION;
pub inline fn _UNION_NAME(x: anytype) void {
    _ = &x;
    return;
}
pub inline fn _STRUCT_NAME(x: anytype) void {
    _ = &x;
    return;
}
pub const DUMMYUNIONNAME = "";
pub const DUMMYUNIONNAME1 = "";
pub const DUMMYUNIONNAME2 = "";
pub const DUMMYUNIONNAME3 = "";
pub const DUMMYUNIONNAME4 = "";
pub const DUMMYUNIONNAME5 = "";
pub const DUMMYUNIONNAME6 = "";
pub const DUMMYUNIONNAME7 = "";
pub const DUMMYUNIONNAME8 = "";
pub const DUMMYUNIONNAME9 = "";
pub const DUMMYSTRUCTNAME = "";
pub const DUMMYSTRUCTNAME1 = "";
pub const DUMMYSTRUCTNAME2 = "";
pub const DUMMYSTRUCTNAME3 = "";
pub const DUMMYSTRUCTNAME4 = "";
pub const DUMMYSTRUCTNAME5 = "";
pub inline fn __CRT_UUID_DECL(@"type": anytype, l: anytype, w1: anytype, w2: anytype, b1: anytype, b2: anytype, b3: anytype, b4: anytype, b5: anytype, b6: anytype, b7: anytype, b8: anytype) void {
    _ = &@"type";
    _ = &l;
    _ = &w1;
    _ = &w2;
    _ = &b1;
    _ = &b2;
    _ = &b3;
    _ = &b4;
    _ = &b5;
    _ = &b6;
    _ = &b7;
    _ = &b8;
    return;
}
pub const __MINGW_DEBUGBREAK_IMPL = @compileError("unable to translate macro: undefined identifier `__debugbreak`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:599:9
pub const __MINGW_FASTFAIL_IMPL = @compileError("unable to translate macro: undefined identifier `__fastfail`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:620:9
pub const __MINGW_PREFETCH_IMPL = @compileError("unable to translate macro: undefined identifier `__prefetch`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\_mingw.h:644:9
pub const _CRT_PACKING = @as(c_int, 8);
pub const _CRTNOALIAS = "";
pub const _CRTRESTRICT = "";
pub const _SIZE_T_DEFINED = "";
pub const _SSIZE_T_DEFINED = "";
pub const _RSIZE_T_DEFINED = "";
pub const _INTPTR_T_DEFINED = "";
pub const __intptr_t_defined = "";
pub const _UINTPTR_T_DEFINED = "";
pub const __uintptr_t_defined = "";
pub const _PTRDIFF_T_DEFINED = "";
pub const _PTRDIFF_T_ = "";
pub const _WCHAR_T_DEFINED = "";
pub const _WCTYPE_T_DEFINED = "";
pub const _WINT_T = "";
pub const _ERRCODE_DEFINED = "";
pub const _TIME32_T_DEFINED = "";
pub const _TIME64_T_DEFINED = "";
pub const _TIME_T_DEFINED = "";
pub const _CRT_SECURE_CPP_NOTHROW = @compileError("unable to translate macro: undefined identifier `throw`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\corecrt.h:143:9
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_0(__ret: anytype, __func: anytype, __dsttype: anytype, __dst: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__dsttype;
    _ = &__dst;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1(__ret: anytype, __func: anytype, __dsttype: anytype, __dst: anytype, __type1: anytype, __arg1: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__dsttype;
    _ = &__dst;
    _ = &__type1;
    _ = &__arg1;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2(__ret: anytype, __func: anytype, __dsttype: anytype, __dst: anytype, __type1: anytype, __arg1: anytype, __type2: anytype, __arg2: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__dsttype;
    _ = &__dst;
    _ = &__type1;
    _ = &__arg1;
    _ = &__type2;
    _ = &__arg2;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_3(__ret: anytype, __func: anytype, __dsttype: anytype, __dst: anytype, __type1: anytype, __arg1: anytype, __type2: anytype, __arg2: anytype, __type3: anytype, __arg3: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__dsttype;
    _ = &__dst;
    _ = &__type1;
    _ = &__arg1;
    _ = &__type2;
    _ = &__arg2;
    _ = &__type3;
    _ = &__arg3;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_4(__ret: anytype, __func: anytype, __dsttype: anytype, __dst: anytype, __type1: anytype, __arg1: anytype, __type2: anytype, __arg2: anytype, __type3: anytype, __arg3: anytype, __type4: anytype, __arg4: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__dsttype;
    _ = &__dst;
    _ = &__type1;
    _ = &__arg1;
    _ = &__type2;
    _ = &__arg2;
    _ = &__type3;
    _ = &__arg3;
    _ = &__type4;
    _ = &__arg4;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_1(__ret: anytype, __func: anytype, __type0: anytype, __arg0: anytype, __dsttype: anytype, __dst: anytype, __type1: anytype, __arg1: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__type0;
    _ = &__arg0;
    _ = &__dsttype;
    _ = &__dst;
    _ = &__type1;
    _ = &__arg1;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_2(__ret: anytype, __func: anytype, __type0: anytype, __arg0: anytype, __dsttype: anytype, __dst: anytype, __type1: anytype, __arg1: anytype, __type2: anytype, __arg2: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__type0;
    _ = &__arg0;
    _ = &__dsttype;
    _ = &__dst;
    _ = &__type1;
    _ = &__arg1;
    _ = &__type2;
    _ = &__arg2;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_1_3(__ret: anytype, __func: anytype, __type0: anytype, __arg0: anytype, __dsttype: anytype, __dst: anytype, __type1: anytype, __arg1: anytype, __type2: anytype, __arg2: anytype, __type3: anytype, __arg3: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__type0;
    _ = &__arg0;
    _ = &__dsttype;
    _ = &__dst;
    _ = &__type1;
    _ = &__arg1;
    _ = &__type2;
    _ = &__arg2;
    _ = &__type3;
    _ = &__arg3;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_2_0(__ret: anytype, __func: anytype, __type1: anytype, __arg1: anytype, __type2: anytype, __arg2: anytype, __dsttype: anytype, __dst: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__type1;
    _ = &__arg1;
    _ = &__type2;
    _ = &__arg2;
    _ = &__dsttype;
    _ = &__dst;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_1_ARGLIST(__ret: anytype, __func: anytype, __vfunc: anytype, __dsttype: anytype, __dst: anytype, __type1: anytype, __arg1: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__vfunc;
    _ = &__dsttype;
    _ = &__dst;
    _ = &__type1;
    _ = &__arg1;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_0_2_ARGLIST(__ret: anytype, __func: anytype, __vfunc: anytype, __dsttype: anytype, __dst: anytype, __type1: anytype, __arg1: anytype, __type2: anytype, __arg2: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__vfunc;
    _ = &__dsttype;
    _ = &__dst;
    _ = &__type1;
    _ = &__arg1;
    _ = &__type2;
    _ = &__arg2;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_SECURE_FUNC_SPLITPATH(__ret: anytype, __func: anytype, __dsttype: anytype, __src: anytype) void {
    _ = &__ret;
    _ = &__func;
    _ = &__dsttype;
    _ = &__src;
    return;
}
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0 = @compileError("unable to translate macro: undefined identifier `__func_name`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\corecrt.h:277:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1 = @compileError("unable to translate macro: undefined identifier `__func_name`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\corecrt.h:279:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2 = @compileError("unable to translate macro: undefined identifier `__func_name`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\corecrt.h:281:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3 = @compileError("unable to translate macro: undefined identifier `__func_name`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\corecrt.h:283:9
pub const __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4 = @compileError("unable to translate macro: undefined identifier `__func_name`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\libc\include\any-windows-any\corecrt.h:285:9
pub inline fn __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_0_EX(__ret_type: anytype, __ret_policy: anytype, __decl_spec: anytype, __name: anytype, __sec_name: anytype, __dst_attr: anytype, __dst_type: anytype, __dst: anytype) void {
    _ = &__ret_type;
    _ = &__ret_policy;
    _ = &__decl_spec;
    _ = &__name;
    _ = &__sec_name;
    _ = &__dst_attr;
    _ = &__dst_type;
    _ = &__dst;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_1_EX(__ret_type: anytype, __ret_policy: anytype, __decl_spec: anytype, __name: anytype, __sec_name: anytype, __dst_attr: anytype, __dst_type: anytype, __dst: anytype, __arg1_type: anytype, __arg1: anytype) void {
    _ = &__ret_type;
    _ = &__ret_policy;
    _ = &__decl_spec;
    _ = &__name;
    _ = &__sec_name;
    _ = &__dst_attr;
    _ = &__dst_type;
    _ = &__dst;
    _ = &__arg1_type;
    _ = &__arg1;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_2_EX(__ret_type: anytype, __ret_policy: anytype, __decl_spec: anytype, __name: anytype, __sec_name: anytype, __dst_attr: anytype, __dst_type: anytype, __dst: anytype, __arg1_type: anytype, __arg1: anytype, __arg2_type: anytype, __arg2: anytype) void {
    _ = &__ret_type;
    _ = &__ret_policy;
    _ = &__decl_spec;
    _ = &__name;
    _ = &__sec_name;
    _ = &__dst_attr;
    _ = &__dst_type;
    _ = &__dst;
    _ = &__arg1_type;
    _ = &__arg1;
    _ = &__arg2_type;
    _ = &__arg2;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_3_EX(__ret_type: anytype, __ret_policy: anytype, __decl_spec: anytype, __name: anytype, __sec_name: anytype, __dst_attr: anytype, __dst_type: anytype, __dst: anytype, __arg1_type: anytype, __arg1: anytype, __arg2_type: anytype, __arg2: anytype, __arg3_type: anytype, __arg3: anytype) void {
    _ = &__ret_type;
    _ = &__ret_policy;
    _ = &__decl_spec;
    _ = &__name;
    _ = &__sec_name;
    _ = &__dst_attr;
    _ = &__dst_type;
    _ = &__dst;
    _ = &__arg1_type;
    _ = &__arg1;
    _ = &__arg2_type;
    _ = &__arg2;
    _ = &__arg3_type;
    _ = &__arg3;
    return;
}
pub inline fn __DEFINE_CPP_OVERLOAD_STANDARD_FUNC_0_4_EX(__ret_type: anytype, __ret_policy: anytype, __decl_spec: anytype, __name: anytype, __sec_name: anytype, __dst_attr: anytype, __dst_type: anytype, __dst: anytype, __arg1_type: anytype, __arg1: anytype, __arg2_type: anytype, __arg2: anytype, __arg3_type: anytype, __arg3: anytype, __arg4_type: anytype, __arg4: anytype) void {
    _ = &__ret_type;
    _ = &__ret_policy;
    _ = &__decl_spec;
    _ = &__name;
    _ = &__sec_name;
    _ = &__dst_attr;
    _ = &__dst_type;
    _ = &__dst;
    _ = &__arg1_type;
    _ = &__arg1;
    _ = &__arg2_type;
    _ = &__arg2;
    _ = &__arg3_type;
    _ = &__arg3;
    _ = &__arg4_type;
    _ = &__arg4;
    return;
}
pub const _TAGLC_ID_DEFINED = "";
pub const _THREADLOCALEINFO = "";
pub inline fn __crt_typefix(ctype: anytype) void {
    _ = &ctype;
    return;
}
pub const _CRT_USE_WINAPI_FAMILY_DESKTOP_APP = "";
pub const __need_wint_t = "";
pub const __need_wchar_t = "";
pub const __STDC_VERSION_STDDEF_H__ = @as(c_long, 202311);
pub const NULL = __helpers.cast(?*anyopaque, @as(c_int, 0));
pub const offsetof = @compileError("unable to translate macro: undefined identifier `__builtin_offsetof`"); // C:\Users\ianb5\AppData\Roaming\Code\User\globalStorage\ziglang.vscode-zig\zig\x86_64-windows-0.16.0\lib\compiler\aro\include\stddef.h:18:9
pub const INT8_MIN = -@as(c_int, 128);
pub const INT16_MIN = -__helpers.promoteIntLiteral(c_int, 32768, .decimal);
pub const INT32_MIN = -__helpers.promoteIntLiteral(c_int, 2147483647, .decimal) - @as(c_int, 1);
pub const INT64_MIN = -@as(c_longlong, 9223372036854775807) - @as(c_int, 1);
pub const INT8_MAX = @as(c_int, 127);
pub const INT16_MAX = @as(c_int, 32767);
pub const INT32_MAX = __helpers.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const INT64_MAX = @as(c_longlong, 9223372036854775807);
pub const UINT8_MAX = @as(c_int, 255);
pub const UINT16_MAX = __helpers.promoteIntLiteral(c_int, 65535, .decimal);
pub const UINT32_MAX = __helpers.promoteIntLiteral(c_uint, 0xffffffff, .hex);
pub const UINT64_MAX = @as(c_ulonglong, 0xffffffffffffffff);
pub const INT_LEAST8_MIN = INT8_MIN;
pub const INT_LEAST16_MIN = INT16_MIN;
pub const INT_LEAST32_MIN = INT32_MIN;
pub const INT_LEAST64_MIN = INT64_MIN;
pub const INT_LEAST8_MAX = INT8_MAX;
pub const INT_LEAST16_MAX = INT16_MAX;
pub const INT_LEAST32_MAX = INT32_MAX;
pub const INT_LEAST64_MAX = INT64_MAX;
pub const UINT_LEAST8_MAX = UINT8_MAX;
pub const UINT_LEAST16_MAX = UINT16_MAX;
pub const UINT_LEAST32_MAX = UINT32_MAX;
pub const UINT_LEAST64_MAX = UINT64_MAX;
pub const INT_FAST8_MIN = INT8_MIN;
pub const INT_FAST16_MIN = INT16_MIN;
pub const INT_FAST32_MIN = INT32_MIN;
pub const INT_FAST64_MIN = INT64_MIN;
pub const INT_FAST8_MAX = INT8_MAX;
pub const INT_FAST16_MAX = INT16_MAX;
pub const INT_FAST32_MAX = INT32_MAX;
pub const INT_FAST64_MAX = INT64_MAX;
pub const UINT_FAST8_MAX = UINT8_MAX;
pub const UINT_FAST16_MAX = UINT16_MAX;
pub const UINT_FAST32_MAX = UINT32_MAX;
pub const UINT_FAST64_MAX = UINT64_MAX;
pub const INTPTR_MIN = INT64_MIN;
pub const INTPTR_MAX = INT64_MAX;
pub const UINTPTR_MAX = UINT64_MAX;
pub const INTMAX_MIN = INT64_MIN;
pub const INTMAX_MAX = INT64_MAX;
pub const UINTMAX_MAX = UINT64_MAX;
pub const PTRDIFF_MIN = INT64_MIN;
pub const PTRDIFF_MAX = INT64_MAX;
pub const SIG_ATOMIC_MIN = INT32_MIN;
pub const SIG_ATOMIC_MAX = INT32_MAX;
pub const SIZE_MAX = UINT64_MAX;
pub const WCHAR_MIN = @as(c_uint, 0);
pub const WCHAR_MAX = @as(c_uint, 0xffff);
pub const WINT_MIN = @as(c_uint, 0);
pub const WINT_MAX = @as(c_uint, 0xffff);
pub inline fn INT8_C(val: anytype) @TypeOf((INT_LEAST8_MAX - INT_LEAST8_MAX) + val) {
    _ = &val;
    return (INT_LEAST8_MAX - INT_LEAST8_MAX) + val;
}
pub inline fn INT16_C(val: anytype) @TypeOf((INT_LEAST16_MAX - INT_LEAST16_MAX) + val) {
    _ = &val;
    return (INT_LEAST16_MAX - INT_LEAST16_MAX) + val;
}
pub inline fn INT32_C(val: anytype) @TypeOf((INT_LEAST32_MAX - INT_LEAST32_MAX) + val) {
    _ = &val;
    return (INT_LEAST32_MAX - INT_LEAST32_MAX) + val;
}
pub const INT64_C = __helpers.LL_SUFFIX;
pub inline fn UINT8_C(val: anytype) @TypeOf(val) {
    _ = &val;
    return val;
}
pub inline fn UINT16_C(val: anytype) @TypeOf(val) {
    _ = &val;
    return val;
}
pub const UINT32_C = __helpers.U_SUFFIX;
pub const UINT64_C = __helpers.ULL_SUFFIX;
pub const INTMAX_C = __helpers.LL_SUFFIX;
pub const UINTMAX_C = __helpers.ULL_SUFFIX;
pub const KHRONOS_SUPPORT_INT64 = @as(c_int, 1);
pub const KHRONOS_SUPPORT_FLOAT = @as(c_int, 1);
pub const KHRONOS_USE_INTPTR_T = "";
pub const KHRONOS_MAX_ENUM = __helpers.promoteIntLiteral(c_int, 0x7FFFFFFF, .hex);
pub const GL_VERSION_1_0 = @as(c_int, 1);
pub const GL_VERSION_1_1 = @as(c_int, 1);
pub const GL_VERSION_1_2 = @as(c_int, 1);
pub const GL_VERSION_1_3 = @as(c_int, 1);
pub const GL_VERSION_1_4 = @as(c_int, 1);
pub const GL_VERSION_1_5 = @as(c_int, 1);
pub const GL_VERSION_2_0 = @as(c_int, 1);
pub const GL_VERSION_2_1 = @as(c_int, 1);
pub const GL_VERSION_3_0 = @as(c_int, 1);
pub const GL_VERSION_3_1 = @as(c_int, 1);
pub const GL_VERSION_3_2 = @as(c_int, 1);
pub const GL_VERSION_3_3 = @as(c_int, 1);
pub const GL_VERSION_4_0 = @as(c_int, 1);
pub const GL_VERSION_4_1 = @as(c_int, 1);
pub const GL_VERSION_4_2 = @as(c_int, 1);
pub const GL_VERSION_4_3 = @as(c_int, 1);
pub const GL_VERSION_4_4 = @as(c_int, 1);
pub const GL_VERSION_4_5 = @as(c_int, 1);
pub const GL_VERSION_4_6 = @as(c_int, 1);
pub inline fn glActiveShaderProgram(pipeline: GLuint, program: GLuint) void {
    return glad_glActiveShaderProgram.?(pipeline, program);
}
pub inline fn glActiveTexture(texture: GLenum) void {
    return glad_glActiveTexture.?(texture);
}
pub inline fn glAttachShader(program: GLuint, shader: GLuint) void {
    return glad_glAttachShader.?(program, shader);
}
pub inline fn glBeginConditionalRender(id: GLuint, mode: GLenum) void {
    return glad_glBeginConditionalRender.?(id, mode);
}
pub inline fn glBeginQuery(target: GLenum, id: GLuint) void {
    return glad_glBeginQuery.?(target, id);
}
pub inline fn glBeginQueryIndexed(target: GLenum, index: GLuint, id: GLuint) void {
    return glad_glBeginQueryIndexed.?(target, index, id);
}
pub inline fn glBeginTransformFeedback(primitiveMode: GLenum) void {
    return glad_glBeginTransformFeedback.?(primitiveMode);
}
pub inline fn glBindAttribLocation(program: GLuint, index: GLuint, name: [*c]const GLchar) void {
    return glad_glBindAttribLocation.?(program, index, name);
}
pub inline fn glBindBuffer(target: GLenum, buffer: GLuint) void {
    return glad_glBindBuffer.?(target, buffer);
}
pub inline fn glBindBufferBase(target: GLenum, index: GLuint, buffer: GLuint) void {
    return glad_glBindBufferBase.?(target, index, buffer);
}
pub inline fn glBindBufferRange(target: GLenum, index: GLuint, buffer: GLuint, offset: GLintptr, size: GLsizeiptr) void {
    return glad_glBindBufferRange.?(target, index, buffer, offset, size);
}
pub inline fn glBindBuffersBase(target: GLenum, first: GLuint, count: GLsizei, buffers: [*c]const GLuint) void {
    return glad_glBindBuffersBase.?(target, first, count, buffers);
}
pub inline fn glBindBuffersRange(target: GLenum, first: GLuint, count: GLsizei, buffers: [*c]const GLuint, offsets: [*c]const GLintptr, sizes: [*c]const GLsizeiptr) void {
    return glad_glBindBuffersRange.?(target, first, count, buffers, offsets, sizes);
}
pub inline fn glBindFragDataLocation(program: GLuint, color: GLuint, name: [*c]const GLchar) void {
    return glad_glBindFragDataLocation.?(program, color, name);
}
pub inline fn glBindFragDataLocationIndexed(program: GLuint, colorNumber: GLuint, index: GLuint, name: [*c]const GLchar) void {
    return glad_glBindFragDataLocationIndexed.?(program, colorNumber, index, name);
}
pub inline fn glBindFramebuffer(target: GLenum, framebuffer: GLuint) void {
    return glad_glBindFramebuffer.?(target, framebuffer);
}
pub inline fn glBindImageTexture(unit: GLuint, texture: GLuint, level: GLint, layered: GLboolean, layer: GLint, access: GLenum, format: GLenum) void {
    return glad_glBindImageTexture.?(unit, texture, level, layered, layer, access, format);
}
pub inline fn glBindImageTextures(first: GLuint, count: GLsizei, textures: [*c]const GLuint) void {
    return glad_glBindImageTextures.?(first, count, textures);
}
pub inline fn glBindProgramPipeline(pipeline: GLuint) void {
    return glad_glBindProgramPipeline.?(pipeline);
}
pub inline fn glBindRenderbuffer(target: GLenum, renderbuffer: GLuint) void {
    return glad_glBindRenderbuffer.?(target, renderbuffer);
}
pub inline fn glBindSampler(unit: GLuint, sampler: GLuint) void {
    return glad_glBindSampler.?(unit, sampler);
}
pub inline fn glBindSamplers(first: GLuint, count: GLsizei, samplers: [*c]const GLuint) void {
    return glad_glBindSamplers.?(first, count, samplers);
}
pub inline fn glBindTexture(target: GLenum, texture: GLuint) void {
    return glad_glBindTexture.?(target, texture);
}
pub inline fn glBindTextureUnit(unit: GLuint, texture: GLuint) void {
    return glad_glBindTextureUnit.?(unit, texture);
}
pub inline fn glBindTextures(first: GLuint, count: GLsizei, textures: [*c]const GLuint) void {
    return glad_glBindTextures.?(first, count, textures);
}
pub inline fn glBindTransformFeedback(target: GLenum, id: GLuint) void {
    return glad_glBindTransformFeedback.?(target, id);
}
pub inline fn glBindVertexArray(array: GLuint) void {
    return glad_glBindVertexArray.?(array);
}
pub inline fn glBindVertexBuffer(bindingindex: GLuint, buffer: GLuint, offset: GLintptr, stride: GLsizei) void {
    return glad_glBindVertexBuffer.?(bindingindex, buffer, offset, stride);
}
pub inline fn glBindVertexBuffers(first: GLuint, count: GLsizei, buffers: [*c]const GLuint, offsets: [*c]const GLintptr, strides: [*c]const GLsizei) void {
    return glad_glBindVertexBuffers.?(first, count, buffers, offsets, strides);
}
pub inline fn glBlendColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) void {
    return glad_glBlendColor.?(red, green, blue, alpha);
}
pub inline fn glBlendEquation(mode: GLenum) void {
    return glad_glBlendEquation.?(mode);
}
pub inline fn glBlendEquationSeparate(modeRGB: GLenum, modeAlpha: GLenum) void {
    return glad_glBlendEquationSeparate.?(modeRGB, modeAlpha);
}
pub inline fn glBlendEquationSeparatei(buf: GLuint, modeRGB: GLenum, modeAlpha: GLenum) void {
    return glad_glBlendEquationSeparatei.?(buf, modeRGB, modeAlpha);
}
pub inline fn glBlendEquationi(buf: GLuint, mode: GLenum) void {
    return glad_glBlendEquationi.?(buf, mode);
}
pub inline fn glBlendFunc(sfactor: GLenum, dfactor: GLenum) void {
    return glad_glBlendFunc.?(sfactor, dfactor);
}
pub inline fn glBlendFuncSeparate(sfactorRGB: GLenum, dfactorRGB: GLenum, sfactorAlpha: GLenum, dfactorAlpha: GLenum) void {
    return glad_glBlendFuncSeparate.?(sfactorRGB, dfactorRGB, sfactorAlpha, dfactorAlpha);
}
pub inline fn glBlendFuncSeparatei(buf: GLuint, srcRGB: GLenum, dstRGB: GLenum, srcAlpha: GLenum, dstAlpha: GLenum) void {
    return glad_glBlendFuncSeparatei.?(buf, srcRGB, dstRGB, srcAlpha, dstAlpha);
}
pub inline fn glBlendFunci(buf: GLuint, src: GLenum, dst: GLenum) void {
    return glad_glBlendFunci.?(buf, src, dst);
}
pub inline fn glBlitFramebuffer(srcX0: GLint, srcY0: GLint, srcX1: GLint, srcY1: GLint, dstX0: GLint, dstY0: GLint, dstX1: GLint, dstY1: GLint, mask: GLbitfield, filter: GLenum) void {
    return glad_glBlitFramebuffer.?(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}
pub inline fn glBlitNamedFramebuffer(readFramebuffer: GLuint, drawFramebuffer: GLuint, srcX0: GLint, srcY0: GLint, srcX1: GLint, srcY1: GLint, dstX0: GLint, dstY0: GLint, dstX1: GLint, dstY1: GLint, mask: GLbitfield, filter: GLenum) void {
    return glad_glBlitNamedFramebuffer.?(readFramebuffer, drawFramebuffer, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}
pub inline fn glBufferData(target: GLenum, size: GLsizeiptr, data: ?*const anyopaque, usage: GLenum) void {
    return glad_glBufferData.?(target, size, data, usage);
}
pub inline fn glBufferStorage(target: GLenum, size: GLsizeiptr, data: ?*const anyopaque, flags: GLbitfield) void {
    return glad_glBufferStorage.?(target, size, data, flags);
}
pub inline fn glBufferSubData(target: GLenum, offset: GLintptr, size: GLsizeiptr, data: ?*const anyopaque) void {
    return glad_glBufferSubData.?(target, offset, size, data);
}
pub inline fn glCheckFramebufferStatus(target: GLenum) GLenum {
    return glad_glCheckFramebufferStatus.?(target);
}
pub inline fn glCheckNamedFramebufferStatus(framebuffer: GLuint, target: GLenum) GLenum {
    return glad_glCheckNamedFramebufferStatus.?(framebuffer, target);
}
pub inline fn glClampColor(target: GLenum, clamp: GLenum) void {
    return glad_glClampColor.?(target, clamp);
}
pub inline fn glClear(mask: GLbitfield) void {
    return glad_glClear.?(mask);
}
pub inline fn glClearBufferData(target: GLenum, internalformat: GLenum, format: GLenum, @"type": GLenum, data: ?*const anyopaque) void {
    return glad_glClearBufferData.?(target, internalformat, format, @"type", data);
}
pub inline fn glClearBufferSubData(target: GLenum, internalformat: GLenum, offset: GLintptr, size: GLsizeiptr, format: GLenum, @"type": GLenum, data: ?*const anyopaque) void {
    return glad_glClearBufferSubData.?(target, internalformat, offset, size, format, @"type", data);
}
pub inline fn glClearBufferfi(buffer: GLenum, drawbuffer: GLint, depth: GLfloat, stencil: GLint) void {
    return glad_glClearBufferfi.?(buffer, drawbuffer, depth, stencil);
}
pub inline fn glClearBufferfv(buffer: GLenum, drawbuffer: GLint, value: [*c]const GLfloat) void {
    return glad_glClearBufferfv.?(buffer, drawbuffer, value);
}
pub inline fn glClearBufferiv(buffer: GLenum, drawbuffer: GLint, value: [*c]const GLint) void {
    return glad_glClearBufferiv.?(buffer, drawbuffer, value);
}
pub inline fn glClearBufferuiv(buffer: GLenum, drawbuffer: GLint, value: [*c]const GLuint) void {
    return glad_glClearBufferuiv.?(buffer, drawbuffer, value);
}
pub inline fn glClearColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) void {
    return glad_glClearColor.?(red, green, blue, alpha);
}
pub inline fn glClearDepth(depth: GLdouble) void {
    return glad_glClearDepth.?(depth);
}
pub inline fn glClearDepthf(d: GLfloat) void {
    return glad_glClearDepthf.?(d);
}
pub inline fn glClearNamedBufferData(buffer: GLuint, internalformat: GLenum, format: GLenum, @"type": GLenum, data: ?*const anyopaque) void {
    return glad_glClearNamedBufferData.?(buffer, internalformat, format, @"type", data);
}
pub inline fn glClearNamedBufferSubData(buffer: GLuint, internalformat: GLenum, offset: GLintptr, size: GLsizeiptr, format: GLenum, @"type": GLenum, data: ?*const anyopaque) void {
    return glad_glClearNamedBufferSubData.?(buffer, internalformat, offset, size, format, @"type", data);
}
pub inline fn glClearNamedFramebufferfi(framebuffer: GLuint, buffer: GLenum, drawbuffer: GLint, depth: GLfloat, stencil: GLint) void {
    return glad_glClearNamedFramebufferfi.?(framebuffer, buffer, drawbuffer, depth, stencil);
}
pub inline fn glClearNamedFramebufferfv(framebuffer: GLuint, buffer: GLenum, drawbuffer: GLint, value: [*c]const GLfloat) void {
    return glad_glClearNamedFramebufferfv.?(framebuffer, buffer, drawbuffer, value);
}
pub inline fn glClearNamedFramebufferiv(framebuffer: GLuint, buffer: GLenum, drawbuffer: GLint, value: [*c]const GLint) void {
    return glad_glClearNamedFramebufferiv.?(framebuffer, buffer, drawbuffer, value);
}
pub inline fn glClearNamedFramebufferuiv(framebuffer: GLuint, buffer: GLenum, drawbuffer: GLint, value: [*c]const GLuint) void {
    return glad_glClearNamedFramebufferuiv.?(framebuffer, buffer, drawbuffer, value);
}
pub inline fn glClearStencil(s: GLint) void {
    return glad_glClearStencil.?(s);
}
pub inline fn glClearTexImage(texture: GLuint, level: GLint, format: GLenum, @"type": GLenum, data: ?*const anyopaque) void {
    return glad_glClearTexImage.?(texture, level, format, @"type", data);
}
pub inline fn glClearTexSubImage(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, @"type": GLenum, data: ?*const anyopaque) void {
    return glad_glClearTexSubImage.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, @"type", data);
}
pub inline fn glClientWaitSync(sync: GLsync, flags: GLbitfield, timeout: GLuint64) GLenum {
    return glad_glClientWaitSync.?(sync, flags, timeout);
}
pub inline fn glClipControl(origin: GLenum, depth: GLenum) void {
    return glad_glClipControl.?(origin, depth);
}
pub inline fn glColorMask(red: GLboolean, green: GLboolean, blue: GLboolean, alpha: GLboolean) void {
    return glad_glColorMask.?(red, green, blue, alpha);
}
pub inline fn glColorMaski(index: GLuint, r: GLboolean, g: GLboolean, b: GLboolean, a: GLboolean) void {
    return glad_glColorMaski.?(index, r, g, b, a);
}
pub inline fn glCompileShader(shader: GLuint) void {
    return glad_glCompileShader.?(shader);
}
pub inline fn glCompressedTexImage1D(target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, border: GLint, imageSize: GLsizei, data: ?*const anyopaque) void {
    return glad_glCompressedTexImage1D.?(target, level, internalformat, width, border, imageSize, data);
}
pub inline fn glCompressedTexImage2D(target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, height: GLsizei, border: GLint, imageSize: GLsizei, data: ?*const anyopaque) void {
    return glad_glCompressedTexImage2D.?(target, level, internalformat, width, height, border, imageSize, data);
}
pub inline fn glCompressedTexImage3D(target: GLenum, level: GLint, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, border: GLint, imageSize: GLsizei, data: ?*const anyopaque) void {
    return glad_glCompressedTexImage3D.?(target, level, internalformat, width, height, depth, border, imageSize, data);
}
pub inline fn glCompressedTexSubImage1D(target: GLenum, level: GLint, xoffset: GLint, width: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) void {
    return glad_glCompressedTexSubImage1D.?(target, level, xoffset, width, format, imageSize, data);
}
pub inline fn glCompressedTexSubImage2D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) void {
    return glad_glCompressedTexSubImage2D.?(target, level, xoffset, yoffset, width, height, format, imageSize, data);
}
pub inline fn glCompressedTexSubImage3D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) void {
    return glad_glCompressedTexSubImage3D.?(target, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data);
}
pub inline fn glCompressedTextureSubImage1D(texture: GLuint, level: GLint, xoffset: GLint, width: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) void {
    return glad_glCompressedTextureSubImage1D.?(texture, level, xoffset, width, format, imageSize, data);
}
pub inline fn glCompressedTextureSubImage2D(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) void {
    return glad_glCompressedTextureSubImage2D.?(texture, level, xoffset, yoffset, width, height, format, imageSize, data);
}
pub inline fn glCompressedTextureSubImage3D(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, imageSize: GLsizei, data: ?*const anyopaque) void {
    return glad_glCompressedTextureSubImage3D.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data);
}
pub inline fn glCopyBufferSubData(readTarget: GLenum, writeTarget: GLenum, readOffset: GLintptr, writeOffset: GLintptr, size: GLsizeiptr) void {
    return glad_glCopyBufferSubData.?(readTarget, writeTarget, readOffset, writeOffset, size);
}
pub inline fn glCopyImageSubData(srcName: GLuint, srcTarget: GLenum, srcLevel: GLint, srcX: GLint, srcY: GLint, srcZ: GLint, dstName: GLuint, dstTarget: GLenum, dstLevel: GLint, dstX: GLint, dstY: GLint, dstZ: GLint, srcWidth: GLsizei, srcHeight: GLsizei, srcDepth: GLsizei) void {
    return glad_glCopyImageSubData.?(srcName, srcTarget, srcLevel, srcX, srcY, srcZ, dstName, dstTarget, dstLevel, dstX, dstY, dstZ, srcWidth, srcHeight, srcDepth);
}
pub inline fn glCopyNamedBufferSubData(readBuffer: GLuint, writeBuffer: GLuint, readOffset: GLintptr, writeOffset: GLintptr, size: GLsizeiptr) void {
    return glad_glCopyNamedBufferSubData.?(readBuffer, writeBuffer, readOffset, writeOffset, size);
}
pub inline fn glCopyTexImage1D(target: GLenum, level: GLint, internalformat: GLenum, x: GLint, y: GLint, width: GLsizei, border: GLint) void {
    return glad_glCopyTexImage1D.?(target, level, internalformat, x, y, width, border);
}
pub inline fn glCopyTexImage2D(target: GLenum, level: GLint, internalformat: GLenum, x: GLint, y: GLint, width: GLsizei, height: GLsizei, border: GLint) void {
    return glad_glCopyTexImage2D.?(target, level, internalformat, x, y, width, height, border);
}
pub inline fn glCopyTexSubImage1D(target: GLenum, level: GLint, xoffset: GLint, x: GLint, y: GLint, width: GLsizei) void {
    return glad_glCopyTexSubImage1D.?(target, level, xoffset, x, y, width);
}
pub inline fn glCopyTexSubImage2D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
    return glad_glCopyTexSubImage2D.?(target, level, xoffset, yoffset, x, y, width, height);
}
pub inline fn glCopyTexSubImage3D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
    return glad_glCopyTexSubImage3D.?(target, level, xoffset, yoffset, zoffset, x, y, width, height);
}
pub inline fn glCopyTextureSubImage1D(texture: GLuint, level: GLint, xoffset: GLint, x: GLint, y: GLint, width: GLsizei) void {
    return glad_glCopyTextureSubImage1D.?(texture, level, xoffset, x, y, width);
}
pub inline fn glCopyTextureSubImage2D(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
    return glad_glCopyTextureSubImage2D.?(texture, level, xoffset, yoffset, x, y, width, height);
}
pub inline fn glCopyTextureSubImage3D(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
    return glad_glCopyTextureSubImage3D.?(texture, level, xoffset, yoffset, zoffset, x, y, width, height);
}
pub inline fn glCreateBuffers(n: GLsizei, buffers: [*c]GLuint) void {
    return glad_glCreateBuffers.?(n, buffers);
}
pub inline fn glCreateFramebuffers(n: GLsizei, framebuffers: [*c]GLuint) void {
    return glad_glCreateFramebuffers.?(n, framebuffers);
}
pub inline fn glCreateProgram() GLuint {
    return glad_glCreateProgram.?();
}
pub inline fn glCreateProgramPipelines(n: GLsizei, pipelines: [*c]GLuint) void {
    return glad_glCreateProgramPipelines.?(n, pipelines);
}
pub inline fn glCreateQueries(target: GLenum, n: GLsizei, ids: [*c]GLuint) void {
    return glad_glCreateQueries.?(target, n, ids);
}
pub inline fn glCreateRenderbuffers(n: GLsizei, renderbuffers: [*c]GLuint) void {
    return glad_glCreateRenderbuffers.?(n, renderbuffers);
}
pub inline fn glCreateSamplers(n: GLsizei, samplers: [*c]GLuint) void {
    return glad_glCreateSamplers.?(n, samplers);
}
pub inline fn glCreateShader(@"type": GLenum) GLuint {
    return glad_glCreateShader.?(@"type");
}
pub inline fn glCreateShaderProgramv(@"type": GLenum, count: GLsizei, strings: [*c]const [*c]const GLchar) GLuint {
    return glad_glCreateShaderProgramv.?(@"type", count, strings);
}
pub inline fn glCreateTextures(target: GLenum, n: GLsizei, textures: [*c]GLuint) void {
    return glad_glCreateTextures.?(target, n, textures);
}
pub inline fn glCreateTransformFeedbacks(n: GLsizei, ids: [*c]GLuint) void {
    return glad_glCreateTransformFeedbacks.?(n, ids);
}
pub inline fn glCreateVertexArrays(n: GLsizei, arrays: [*c]GLuint) void {
    return glad_glCreateVertexArrays.?(n, arrays);
}
pub inline fn glCullFace(mode: GLenum) void {
    return glad_glCullFace.?(mode);
}
pub inline fn glDebugMessageCallback(callback: GLDEBUGPROC, userParam: ?*const anyopaque) void {
    return glad_glDebugMessageCallback.?(callback, userParam);
}
pub inline fn glDebugMessageControl(source: GLenum, @"type": GLenum, severity: GLenum, count: GLsizei, ids: [*c]const GLuint, enabled: GLboolean) void {
    return glad_glDebugMessageControl.?(source, @"type", severity, count, ids, enabled);
}
pub inline fn glDebugMessageInsert(source: GLenum, @"type": GLenum, id: GLuint, severity: GLenum, length: GLsizei, buf: [*c]const GLchar) void {
    return glad_glDebugMessageInsert.?(source, @"type", id, severity, length, buf);
}
pub inline fn glDeleteBuffers(n: GLsizei, buffers: [*c]const GLuint) void {
    return glad_glDeleteBuffers.?(n, buffers);
}
pub inline fn glDeleteFramebuffers(n: GLsizei, framebuffers: [*c]const GLuint) void {
    return glad_glDeleteFramebuffers.?(n, framebuffers);
}
pub inline fn glDeleteProgram(program: GLuint) void {
    return glad_glDeleteProgram.?(program);
}
pub inline fn glDeleteProgramPipelines(n: GLsizei, pipelines: [*c]const GLuint) void {
    return glad_glDeleteProgramPipelines.?(n, pipelines);
}
pub inline fn glDeleteQueries(n: GLsizei, ids: [*c]const GLuint) void {
    return glad_glDeleteQueries.?(n, ids);
}
pub inline fn glDeleteRenderbuffers(n: GLsizei, renderbuffers: [*c]const GLuint) void {
    return glad_glDeleteRenderbuffers.?(n, renderbuffers);
}
pub inline fn glDeleteSamplers(count: GLsizei, samplers: [*c]const GLuint) void {
    return glad_glDeleteSamplers.?(count, samplers);
}
pub inline fn glDeleteShader(shader: GLuint) void {
    return glad_glDeleteShader.?(shader);
}
pub inline fn glDeleteSync(sync: GLsync) void {
    return glad_glDeleteSync.?(sync);
}
pub inline fn glDeleteTextures(n: GLsizei, textures: [*c]const GLuint) void {
    return glad_glDeleteTextures.?(n, textures);
}
pub inline fn glDeleteTransformFeedbacks(n: GLsizei, ids: [*c]const GLuint) void {
    return glad_glDeleteTransformFeedbacks.?(n, ids);
}
pub inline fn glDeleteVertexArrays(n: GLsizei, arrays: [*c]const GLuint) void {
    return glad_glDeleteVertexArrays.?(n, arrays);
}
pub inline fn glDepthFunc(func: GLenum) void {
    return glad_glDepthFunc.?(func);
}
pub inline fn glDepthMask(flag: GLboolean) void {
    return glad_glDepthMask.?(flag);
}
pub inline fn glDepthRange(n: GLdouble, f: GLdouble) void {
    return glad_glDepthRange.?(n, f);
}
pub inline fn glDepthRangeArrayv(first: GLuint, count: GLsizei, v: [*c]const GLdouble) void {
    return glad_glDepthRangeArrayv.?(first, count, v);
}
pub inline fn glDepthRangeIndexed(index: GLuint, n: GLdouble, f: GLdouble) void {
    return glad_glDepthRangeIndexed.?(index, n, f);
}
pub inline fn glDepthRangef(n: GLfloat, f: GLfloat) void {
    return glad_glDepthRangef.?(n, f);
}
pub inline fn glDetachShader(program: GLuint, shader: GLuint) void {
    return glad_glDetachShader.?(program, shader);
}
pub inline fn glDisable(cap: GLenum) void {
    return glad_glDisable.?(cap);
}
pub inline fn glDisableVertexArrayAttrib(vaobj: GLuint, index: GLuint) void {
    return glad_glDisableVertexArrayAttrib.?(vaobj, index);
}
pub inline fn glDisableVertexAttribArray(index: GLuint) void {
    return glad_glDisableVertexAttribArray.?(index);
}
pub inline fn glDisablei(target: GLenum, index: GLuint) void {
    return glad_glDisablei.?(target, index);
}
pub inline fn glDispatchCompute(num_groups_x: GLuint, num_groups_y: GLuint, num_groups_z: GLuint) void {
    return glad_glDispatchCompute.?(num_groups_x, num_groups_y, num_groups_z);
}
pub inline fn glDispatchComputeIndirect(indirect: GLintptr) void {
    return glad_glDispatchComputeIndirect.?(indirect);
}
pub inline fn glDrawArrays(mode: GLenum, first: GLint, count: GLsizei) void {
    return glad_glDrawArrays.?(mode, first, count);
}
pub inline fn glDrawArraysIndirect(mode: GLenum, indirect: ?*const anyopaque) void {
    return glad_glDrawArraysIndirect.?(mode, indirect);
}
pub inline fn glDrawArraysInstanced(mode: GLenum, first: GLint, count: GLsizei, instancecount: GLsizei) void {
    return glad_glDrawArraysInstanced.?(mode, first, count, instancecount);
}
pub inline fn glDrawArraysInstancedBaseInstance(mode: GLenum, first: GLint, count: GLsizei, instancecount: GLsizei, baseinstance: GLuint) void {
    return glad_glDrawArraysInstancedBaseInstance.?(mode, first, count, instancecount, baseinstance);
}
pub inline fn glDrawBuffer(buf: GLenum) void {
    return glad_glDrawBuffer.?(buf);
}
pub inline fn glDrawBuffers(n: GLsizei, bufs: [*c]const GLenum) void {
    return glad_glDrawBuffers.?(n, bufs);
}
pub inline fn glDrawElements(mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque) void {
    return glad_glDrawElements.?(mode, count, @"type", indices);
}
pub inline fn glDrawElementsBaseVertex(mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, basevertex: GLint) void {
    return glad_glDrawElementsBaseVertex.?(mode, count, @"type", indices, basevertex);
}
pub inline fn glDrawElementsIndirect(mode: GLenum, @"type": GLenum, indirect: ?*const anyopaque) void {
    return glad_glDrawElementsIndirect.?(mode, @"type", indirect);
}
pub inline fn glDrawElementsInstanced(mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, instancecount: GLsizei) void {
    return glad_glDrawElementsInstanced.?(mode, count, @"type", indices, instancecount);
}
pub inline fn glDrawElementsInstancedBaseInstance(mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, instancecount: GLsizei, baseinstance: GLuint) void {
    return glad_glDrawElementsInstancedBaseInstance.?(mode, count, @"type", indices, instancecount, baseinstance);
}
pub inline fn glDrawElementsInstancedBaseVertex(mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, instancecount: GLsizei, basevertex: GLint) void {
    return glad_glDrawElementsInstancedBaseVertex.?(mode, count, @"type", indices, instancecount, basevertex);
}
pub inline fn glDrawElementsInstancedBaseVertexBaseInstance(mode: GLenum, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, instancecount: GLsizei, basevertex: GLint, baseinstance: GLuint) void {
    return glad_glDrawElementsInstancedBaseVertexBaseInstance.?(mode, count, @"type", indices, instancecount, basevertex, baseinstance);
}
pub inline fn glDrawRangeElements(mode: GLenum, start: GLuint, end: GLuint, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque) void {
    return glad_glDrawRangeElements.?(mode, start, end, count, @"type", indices);
}
pub inline fn glDrawRangeElementsBaseVertex(mode: GLenum, start: GLuint, end: GLuint, count: GLsizei, @"type": GLenum, indices: ?*const anyopaque, basevertex: GLint) void {
    return glad_glDrawRangeElementsBaseVertex.?(mode, start, end, count, @"type", indices, basevertex);
}
pub inline fn glDrawTransformFeedback(mode: GLenum, id: GLuint) void {
    return glad_glDrawTransformFeedback.?(mode, id);
}
pub inline fn glDrawTransformFeedbackInstanced(mode: GLenum, id: GLuint, instancecount: GLsizei) void {
    return glad_glDrawTransformFeedbackInstanced.?(mode, id, instancecount);
}
pub inline fn glDrawTransformFeedbackStream(mode: GLenum, id: GLuint, stream: GLuint) void {
    return glad_glDrawTransformFeedbackStream.?(mode, id, stream);
}
pub inline fn glDrawTransformFeedbackStreamInstanced(mode: GLenum, id: GLuint, stream: GLuint, instancecount: GLsizei) void {
    return glad_glDrawTransformFeedbackStreamInstanced.?(mode, id, stream, instancecount);
}
pub inline fn glEnable(cap: GLenum) void {
    return glad_glEnable.?(cap);
}
pub inline fn glEnableVertexArrayAttrib(vaobj: GLuint, index: GLuint) void {
    return glad_glEnableVertexArrayAttrib.?(vaobj, index);
}
pub inline fn glEnableVertexAttribArray(index: GLuint) void {
    return glad_glEnableVertexAttribArray.?(index);
}
pub inline fn glEnablei(target: GLenum, index: GLuint) void {
    return glad_glEnablei.?(target, index);
}
pub inline fn glEndConditionalRender() void {
    return glad_glEndConditionalRender.?();
}
pub inline fn glEndQuery(target: GLenum) void {
    return glad_glEndQuery.?(target);
}
pub inline fn glEndQueryIndexed(target: GLenum, index: GLuint) void {
    return glad_glEndQueryIndexed.?(target, index);
}
pub inline fn glEndTransformFeedback() void {
    return glad_glEndTransformFeedback.?();
}
pub inline fn glFenceSync(condition: GLenum, flags: GLbitfield) GLsync {
    return glad_glFenceSync.?(condition, flags);
}
pub inline fn glFinish() void {
    return glad_glFinish.?();
}
pub inline fn glFlush() void {
    return glad_glFlush.?();
}
pub inline fn glFlushMappedBufferRange(target: GLenum, offset: GLintptr, length: GLsizeiptr) void {
    return glad_glFlushMappedBufferRange.?(target, offset, length);
}
pub inline fn glFlushMappedNamedBufferRange(buffer: GLuint, offset: GLintptr, length: GLsizeiptr) void {
    return glad_glFlushMappedNamedBufferRange.?(buffer, offset, length);
}
pub inline fn glFramebufferParameteri(target: GLenum, pname: GLenum, param: GLint) void {
    return glad_glFramebufferParameteri.?(target, pname, param);
}
pub inline fn glFramebufferRenderbuffer(target: GLenum, attachment: GLenum, renderbuffertarget: GLenum, renderbuffer: GLuint) void {
    return glad_glFramebufferRenderbuffer.?(target, attachment, renderbuffertarget, renderbuffer);
}
pub inline fn glFramebufferTexture(target: GLenum, attachment: GLenum, texture: GLuint, level: GLint) void {
    return glad_glFramebufferTexture.?(target, attachment, texture, level);
}
pub inline fn glFramebufferTexture1D(target: GLenum, attachment: GLenum, textarget: GLenum, texture: GLuint, level: GLint) void {
    return glad_glFramebufferTexture1D.?(target, attachment, textarget, texture, level);
}
pub inline fn glFramebufferTexture2D(target: GLenum, attachment: GLenum, textarget: GLenum, texture: GLuint, level: GLint) void {
    return glad_glFramebufferTexture2D.?(target, attachment, textarget, texture, level);
}
pub inline fn glFramebufferTexture3D(target: GLenum, attachment: GLenum, textarget: GLenum, texture: GLuint, level: GLint, zoffset: GLint) void {
    return glad_glFramebufferTexture3D.?(target, attachment, textarget, texture, level, zoffset);
}
pub inline fn glFramebufferTextureLayer(target: GLenum, attachment: GLenum, texture: GLuint, level: GLint, layer: GLint) void {
    return glad_glFramebufferTextureLayer.?(target, attachment, texture, level, layer);
}
pub inline fn glFrontFace(mode: GLenum) void {
    return glad_glFrontFace.?(mode);
}
pub inline fn glGenBuffers(n: GLsizei, buffers: [*c]GLuint) void {
    return glad_glGenBuffers.?(n, buffers);
}
pub inline fn glGenFramebuffers(n: GLsizei, framebuffers: [*c]GLuint) void {
    return glad_glGenFramebuffers.?(n, framebuffers);
}
pub inline fn glGenProgramPipelines(n: GLsizei, pipelines: [*c]GLuint) void {
    return glad_glGenProgramPipelines.?(n, pipelines);
}
pub inline fn glGenQueries(n: GLsizei, ids: [*c]GLuint) void {
    return glad_glGenQueries.?(n, ids);
}
pub inline fn glGenRenderbuffers(n: GLsizei, renderbuffers: [*c]GLuint) void {
    return glad_glGenRenderbuffers.?(n, renderbuffers);
}
pub inline fn glGenSamplers(count: GLsizei, samplers: [*c]GLuint) void {
    return glad_glGenSamplers.?(count, samplers);
}
pub inline fn glGenTextures(n: GLsizei, textures: [*c]GLuint) void {
    return glad_glGenTextures.?(n, textures);
}
pub inline fn glGenTransformFeedbacks(n: GLsizei, ids: [*c]GLuint) void {
    return glad_glGenTransformFeedbacks.?(n, ids);
}
pub inline fn glGenVertexArrays(n: GLsizei, arrays: [*c]GLuint) void {
    return glad_glGenVertexArrays.?(n, arrays);
}
pub inline fn glGenerateMipmap(target: GLenum) void {
    return glad_glGenerateMipmap.?(target);
}
pub inline fn glGenerateTextureMipmap(texture: GLuint) void {
    return glad_glGenerateTextureMipmap.?(texture);
}
pub inline fn glGetActiveAtomicCounterBufferiv(program: GLuint, bufferIndex: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetActiveAtomicCounterBufferiv.?(program, bufferIndex, pname, params);
}
pub inline fn glGetActiveAttrib(program: GLuint, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, size: [*c]GLint, @"type": [*c]GLenum, name: [*c]GLchar) void {
    return glad_glGetActiveAttrib.?(program, index, bufSize, length, size, @"type", name);
}
pub inline fn glGetActiveSubroutineName(program: GLuint, shadertype: GLenum, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, name: [*c]GLchar) void {
    return glad_glGetActiveSubroutineName.?(program, shadertype, index, bufSize, length, name);
}
pub inline fn glGetActiveSubroutineUniformName(program: GLuint, shadertype: GLenum, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, name: [*c]GLchar) void {
    return glad_glGetActiveSubroutineUniformName.?(program, shadertype, index, bufSize, length, name);
}
pub inline fn glGetActiveSubroutineUniformiv(program: GLuint, shadertype: GLenum, index: GLuint, pname: GLenum, values: [*c]GLint) void {
    return glad_glGetActiveSubroutineUniformiv.?(program, shadertype, index, pname, values);
}
pub inline fn glGetActiveUniform(program: GLuint, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, size: [*c]GLint, @"type": [*c]GLenum, name: [*c]GLchar) void {
    return glad_glGetActiveUniform.?(program, index, bufSize, length, size, @"type", name);
}
pub inline fn glGetActiveUniformBlockName(program: GLuint, uniformBlockIndex: GLuint, bufSize: GLsizei, length: [*c]GLsizei, uniformBlockName: [*c]GLchar) void {
    return glad_glGetActiveUniformBlockName.?(program, uniformBlockIndex, bufSize, length, uniformBlockName);
}
pub inline fn glGetActiveUniformBlockiv(program: GLuint, uniformBlockIndex: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetActiveUniformBlockiv.?(program, uniformBlockIndex, pname, params);
}
pub inline fn glGetActiveUniformName(program: GLuint, uniformIndex: GLuint, bufSize: GLsizei, length: [*c]GLsizei, uniformName: [*c]GLchar) void {
    return glad_glGetActiveUniformName.?(program, uniformIndex, bufSize, length, uniformName);
}
pub inline fn glGetActiveUniformsiv(program: GLuint, uniformCount: GLsizei, uniformIndices: [*c]const GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetActiveUniformsiv.?(program, uniformCount, uniformIndices, pname, params);
}
pub inline fn glGetAttachedShaders(program: GLuint, maxCount: GLsizei, count: [*c]GLsizei, shaders: [*c]GLuint) void {
    return glad_glGetAttachedShaders.?(program, maxCount, count, shaders);
}
pub inline fn glGetAttribLocation(program: GLuint, name: [*c]const GLchar) GLint {
    return glad_glGetAttribLocation.?(program, name);
}
pub inline fn glGetBooleani_v(target: GLenum, index: GLuint, data: [*c]GLboolean) void {
    return glad_glGetBooleani_v.?(target, index, data);
}
pub inline fn glGetBooleanv(pname: GLenum, data: [*c]GLboolean) void {
    return glad_glGetBooleanv.?(pname, data);
}
pub inline fn glGetBufferParameteri64v(target: GLenum, pname: GLenum, params: [*c]GLint64) void {
    return glad_glGetBufferParameteri64v.?(target, pname, params);
}
pub inline fn glGetBufferParameteriv(target: GLenum, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetBufferParameteriv.?(target, pname, params);
}
pub inline fn glGetBufferPointerv(target: GLenum, pname: GLenum, params: [*c]?*anyopaque) void {
    return glad_glGetBufferPointerv.?(target, pname, params);
}
pub inline fn glGetBufferSubData(target: GLenum, offset: GLintptr, size: GLsizeiptr, data: ?*anyopaque) void {
    return glad_glGetBufferSubData.?(target, offset, size, data);
}
pub inline fn glGetCompressedTexImage(target: GLenum, level: GLint, img: ?*anyopaque) void {
    return glad_glGetCompressedTexImage.?(target, level, img);
}
pub inline fn glGetCompressedTextureImage(texture: GLuint, level: GLint, bufSize: GLsizei, pixels: ?*anyopaque) void {
    return glad_glGetCompressedTextureImage.?(texture, level, bufSize, pixels);
}
pub inline fn glGetCompressedTextureSubImage(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, bufSize: GLsizei, pixels: ?*anyopaque) void {
    return glad_glGetCompressedTextureSubImage.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, bufSize, pixels);
}
pub inline fn glGetDebugMessageLog(count: GLuint, bufSize: GLsizei, sources: [*c]GLenum, types: [*c]GLenum, ids: [*c]GLuint, severities: [*c]GLenum, lengths: [*c]GLsizei, messageLog: [*c]GLchar) GLuint {
    return glad_glGetDebugMessageLog.?(count, bufSize, sources, types, ids, severities, lengths, messageLog);
}
pub inline fn glGetDoublei_v(target: GLenum, index: GLuint, data: [*c]GLdouble) void {
    return glad_glGetDoublei_v.?(target, index, data);
}
pub inline fn glGetDoublev(pname: GLenum, data: [*c]GLdouble) void {
    return glad_glGetDoublev.?(pname, data);
}
pub inline fn glGetError() GLenum {
    return glad_glGetError.?();
}
pub inline fn glGetFloati_v(target: GLenum, index: GLuint, data: [*c]GLfloat) void {
    return glad_glGetFloati_v.?(target, index, data);
}
pub inline fn glGetFloatv(pname: GLenum, data: [*c]GLfloat) void {
    return glad_glGetFloatv.?(pname, data);
}
pub inline fn glGetFragDataIndex(program: GLuint, name: [*c]const GLchar) GLint {
    return glad_glGetFragDataIndex.?(program, name);
}
pub inline fn glGetFragDataLocation(program: GLuint, name: [*c]const GLchar) GLint {
    return glad_glGetFragDataLocation.?(program, name);
}
pub inline fn glGetFramebufferAttachmentParameteriv(target: GLenum, attachment: GLenum, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetFramebufferAttachmentParameteriv.?(target, attachment, pname, params);
}
pub inline fn glGetFramebufferParameteriv(target: GLenum, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetFramebufferParameteriv.?(target, pname, params);
}
pub inline fn glGetGraphicsResetStatus() GLenum {
    return glad_glGetGraphicsResetStatus.?();
}
pub inline fn glGetInteger64i_v(target: GLenum, index: GLuint, data: [*c]GLint64) void {
    return glad_glGetInteger64i_v.?(target, index, data);
}
pub inline fn glGetInteger64v(pname: GLenum, data: [*c]GLint64) void {
    return glad_glGetInteger64v.?(pname, data);
}
pub inline fn glGetIntegeri_v(target: GLenum, index: GLuint, data: [*c]GLint) void {
    return glad_glGetIntegeri_v.?(target, index, data);
}
pub inline fn glGetIntegerv(pname: GLenum, data: [*c]GLint) void {
    return glad_glGetIntegerv.?(pname, data);
}
pub inline fn glGetInternalformati64v(target: GLenum, internalformat: GLenum, pname: GLenum, count: GLsizei, params: [*c]GLint64) void {
    return glad_glGetInternalformati64v.?(target, internalformat, pname, count, params);
}
pub inline fn glGetInternalformativ(target: GLenum, internalformat: GLenum, pname: GLenum, count: GLsizei, params: [*c]GLint) void {
    return glad_glGetInternalformativ.?(target, internalformat, pname, count, params);
}
pub inline fn glGetMultisamplefv(pname: GLenum, index: GLuint, val: [*c]GLfloat) void {
    return glad_glGetMultisamplefv.?(pname, index, val);
}
pub inline fn glGetNamedBufferParameteri64v(buffer: GLuint, pname: GLenum, params: [*c]GLint64) void {
    return glad_glGetNamedBufferParameteri64v.?(buffer, pname, params);
}
pub inline fn glGetNamedBufferParameteriv(buffer: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetNamedBufferParameteriv.?(buffer, pname, params);
}
pub inline fn glGetNamedBufferPointerv(buffer: GLuint, pname: GLenum, params: [*c]?*anyopaque) void {
    return glad_glGetNamedBufferPointerv.?(buffer, pname, params);
}
pub inline fn glGetNamedBufferSubData(buffer: GLuint, offset: GLintptr, size: GLsizeiptr, data: ?*anyopaque) void {
    return glad_glGetNamedBufferSubData.?(buffer, offset, size, data);
}
pub inline fn glGetNamedFramebufferAttachmentParameteriv(framebuffer: GLuint, attachment: GLenum, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetNamedFramebufferAttachmentParameteriv.?(framebuffer, attachment, pname, params);
}
pub inline fn glGetNamedFramebufferParameteriv(framebuffer: GLuint, pname: GLenum, param: [*c]GLint) void {
    return glad_glGetNamedFramebufferParameteriv.?(framebuffer, pname, param);
}
pub inline fn glGetNamedRenderbufferParameteriv(renderbuffer: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetNamedRenderbufferParameteriv.?(renderbuffer, pname, params);
}
pub inline fn glGetObjectLabel(identifier: GLenum, name: GLuint, bufSize: GLsizei, length: [*c]GLsizei, label: [*c]GLchar) void {
    return glad_glGetObjectLabel.?(identifier, name, bufSize, length, label);
}
pub inline fn glGetObjectPtrLabel(ptr: ?*const anyopaque, bufSize: GLsizei, length: [*c]GLsizei, label: [*c]GLchar) void {
    return glad_glGetObjectPtrLabel.?(ptr, bufSize, length, label);
}
pub inline fn glGetPointerv(pname: GLenum, params: [*c]?*anyopaque) void {
    return glad_glGetPointerv.?(pname, params);
}
pub inline fn glGetProgramBinary(program: GLuint, bufSize: GLsizei, length: [*c]GLsizei, binaryFormat: [*c]GLenum, binary: ?*anyopaque) void {
    return glad_glGetProgramBinary.?(program, bufSize, length, binaryFormat, binary);
}
pub inline fn glGetProgramInfoLog(program: GLuint, bufSize: GLsizei, length: [*c]GLsizei, infoLog: [*c]GLchar) void {
    return glad_glGetProgramInfoLog.?(program, bufSize, length, infoLog);
}
pub inline fn glGetProgramInterfaceiv(program: GLuint, programInterface: GLenum, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetProgramInterfaceiv.?(program, programInterface, pname, params);
}
pub inline fn glGetProgramPipelineInfoLog(pipeline: GLuint, bufSize: GLsizei, length: [*c]GLsizei, infoLog: [*c]GLchar) void {
    return glad_glGetProgramPipelineInfoLog.?(pipeline, bufSize, length, infoLog);
}
pub inline fn glGetProgramPipelineiv(pipeline: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetProgramPipelineiv.?(pipeline, pname, params);
}
pub inline fn glGetProgramResourceIndex(program: GLuint, programInterface: GLenum, name: [*c]const GLchar) GLuint {
    return glad_glGetProgramResourceIndex.?(program, programInterface, name);
}
pub inline fn glGetProgramResourceLocation(program: GLuint, programInterface: GLenum, name: [*c]const GLchar) GLint {
    return glad_glGetProgramResourceLocation.?(program, programInterface, name);
}
pub inline fn glGetProgramResourceLocationIndex(program: GLuint, programInterface: GLenum, name: [*c]const GLchar) GLint {
    return glad_glGetProgramResourceLocationIndex.?(program, programInterface, name);
}
pub inline fn glGetProgramResourceName(program: GLuint, programInterface: GLenum, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, name: [*c]GLchar) void {
    return glad_glGetProgramResourceName.?(program, programInterface, index, bufSize, length, name);
}
pub inline fn glGetProgramResourceiv(program: GLuint, programInterface: GLenum, index: GLuint, propCount: GLsizei, props: [*c]const GLenum, count: GLsizei, length: [*c]GLsizei, params: [*c]GLint) void {
    return glad_glGetProgramResourceiv.?(program, programInterface, index, propCount, props, count, length, params);
}
pub inline fn glGetProgramStageiv(program: GLuint, shadertype: GLenum, pname: GLenum, values: [*c]GLint) void {
    return glad_glGetProgramStageiv.?(program, shadertype, pname, values);
}
pub inline fn glGetProgramiv(program: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetProgramiv.?(program, pname, params);
}
pub inline fn glGetQueryBufferObjecti64v(id: GLuint, buffer: GLuint, pname: GLenum, offset: GLintptr) void {
    return glad_glGetQueryBufferObjecti64v.?(id, buffer, pname, offset);
}
pub inline fn glGetQueryBufferObjectiv(id: GLuint, buffer: GLuint, pname: GLenum, offset: GLintptr) void {
    return glad_glGetQueryBufferObjectiv.?(id, buffer, pname, offset);
}
pub inline fn glGetQueryBufferObjectui64v(id: GLuint, buffer: GLuint, pname: GLenum, offset: GLintptr) void {
    return glad_glGetQueryBufferObjectui64v.?(id, buffer, pname, offset);
}
pub inline fn glGetQueryBufferObjectuiv(id: GLuint, buffer: GLuint, pname: GLenum, offset: GLintptr) void {
    return glad_glGetQueryBufferObjectuiv.?(id, buffer, pname, offset);
}
pub inline fn glGetQueryIndexediv(target: GLenum, index: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetQueryIndexediv.?(target, index, pname, params);
}
pub inline fn glGetQueryObjecti64v(id: GLuint, pname: GLenum, params: [*c]GLint64) void {
    return glad_glGetQueryObjecti64v.?(id, pname, params);
}
pub inline fn glGetQueryObjectiv(id: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetQueryObjectiv.?(id, pname, params);
}
pub inline fn glGetQueryObjectui64v(id: GLuint, pname: GLenum, params: [*c]GLuint64) void {
    return glad_glGetQueryObjectui64v.?(id, pname, params);
}
pub inline fn glGetQueryObjectuiv(id: GLuint, pname: GLenum, params: [*c]GLuint) void {
    return glad_glGetQueryObjectuiv.?(id, pname, params);
}
pub inline fn glGetQueryiv(target: GLenum, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetQueryiv.?(target, pname, params);
}
pub inline fn glGetRenderbufferParameteriv(target: GLenum, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetRenderbufferParameteriv.?(target, pname, params);
}
pub inline fn glGetSamplerParameterIiv(sampler: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetSamplerParameterIiv.?(sampler, pname, params);
}
pub inline fn glGetSamplerParameterIuiv(sampler: GLuint, pname: GLenum, params: [*c]GLuint) void {
    return glad_glGetSamplerParameterIuiv.?(sampler, pname, params);
}
pub inline fn glGetSamplerParameterfv(sampler: GLuint, pname: GLenum, params: [*c]GLfloat) void {
    return glad_glGetSamplerParameterfv.?(sampler, pname, params);
}
pub inline fn glGetSamplerParameteriv(sampler: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetSamplerParameteriv.?(sampler, pname, params);
}
pub inline fn glGetShaderInfoLog(shader: GLuint, bufSize: GLsizei, length: [*c]GLsizei, infoLog: [*c]GLchar) void {
    return glad_glGetShaderInfoLog.?(shader, bufSize, length, infoLog);
}
pub inline fn glGetShaderPrecisionFormat(shadertype: GLenum, precisiontype: GLenum, range: [*c]GLint, precision: [*c]GLint) void {
    return glad_glGetShaderPrecisionFormat.?(shadertype, precisiontype, range, precision);
}
pub inline fn glGetShaderSource(shader: GLuint, bufSize: GLsizei, length: [*c]GLsizei, source: [*c]GLchar) void {
    return glad_glGetShaderSource.?(shader, bufSize, length, source);
}
pub inline fn glGetShaderiv(shader: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetShaderiv.?(shader, pname, params);
}
pub inline fn glGetString(name: GLenum) [*c]const GLubyte {
    return glad_glGetString.?(name);
}
pub inline fn glGetStringi(name: GLenum, index: GLuint) [*c]const GLubyte {
    return glad_glGetStringi.?(name, index);
}
pub inline fn glGetSubroutineIndex(program: GLuint, shadertype: GLenum, name: [*c]const GLchar) GLuint {
    return glad_glGetSubroutineIndex.?(program, shadertype, name);
}
pub inline fn glGetSubroutineUniformLocation(program: GLuint, shadertype: GLenum, name: [*c]const GLchar) GLint {
    return glad_glGetSubroutineUniformLocation.?(program, shadertype, name);
}
pub inline fn glGetSynciv(sync: GLsync, pname: GLenum, count: GLsizei, length: [*c]GLsizei, values: [*c]GLint) void {
    return glad_glGetSynciv.?(sync, pname, count, length, values);
}
pub inline fn glGetTexImage(target: GLenum, level: GLint, format: GLenum, @"type": GLenum, pixels: ?*anyopaque) void {
    return glad_glGetTexImage.?(target, level, format, @"type", pixels);
}
pub inline fn glGetTexLevelParameterfv(target: GLenum, level: GLint, pname: GLenum, params: [*c]GLfloat) void {
    return glad_glGetTexLevelParameterfv.?(target, level, pname, params);
}
pub inline fn glGetTexLevelParameteriv(target: GLenum, level: GLint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetTexLevelParameteriv.?(target, level, pname, params);
}
pub inline fn glGetTexParameterIiv(target: GLenum, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetTexParameterIiv.?(target, pname, params);
}
pub inline fn glGetTexParameterIuiv(target: GLenum, pname: GLenum, params: [*c]GLuint) void {
    return glad_glGetTexParameterIuiv.?(target, pname, params);
}
pub inline fn glGetTexParameterfv(target: GLenum, pname: GLenum, params: [*c]GLfloat) void {
    return glad_glGetTexParameterfv.?(target, pname, params);
}
pub inline fn glGetTexParameteriv(target: GLenum, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetTexParameteriv.?(target, pname, params);
}
pub inline fn glGetTextureImage(texture: GLuint, level: GLint, format: GLenum, @"type": GLenum, bufSize: GLsizei, pixels: ?*anyopaque) void {
    return glad_glGetTextureImage.?(texture, level, format, @"type", bufSize, pixels);
}
pub inline fn glGetTextureLevelParameterfv(texture: GLuint, level: GLint, pname: GLenum, params: [*c]GLfloat) void {
    return glad_glGetTextureLevelParameterfv.?(texture, level, pname, params);
}
pub inline fn glGetTextureLevelParameteriv(texture: GLuint, level: GLint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetTextureLevelParameteriv.?(texture, level, pname, params);
}
pub inline fn glGetTextureParameterIiv(texture: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetTextureParameterIiv.?(texture, pname, params);
}
pub inline fn glGetTextureParameterIuiv(texture: GLuint, pname: GLenum, params: [*c]GLuint) void {
    return glad_glGetTextureParameterIuiv.?(texture, pname, params);
}
pub inline fn glGetTextureParameterfv(texture: GLuint, pname: GLenum, params: [*c]GLfloat) void {
    return glad_glGetTextureParameterfv.?(texture, pname, params);
}
pub inline fn glGetTextureParameteriv(texture: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetTextureParameteriv.?(texture, pname, params);
}
pub inline fn glGetTextureSubImage(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, @"type": GLenum, bufSize: GLsizei, pixels: ?*anyopaque) void {
    return glad_glGetTextureSubImage.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, @"type", bufSize, pixels);
}
pub inline fn glGetTransformFeedbackVarying(program: GLuint, index: GLuint, bufSize: GLsizei, length: [*c]GLsizei, size: [*c]GLsizei, @"type": [*c]GLenum, name: [*c]GLchar) void {
    return glad_glGetTransformFeedbackVarying.?(program, index, bufSize, length, size, @"type", name);
}
pub inline fn glGetTransformFeedbacki64_v(xfb: GLuint, pname: GLenum, index: GLuint, param: [*c]GLint64) void {
    return glad_glGetTransformFeedbacki64_v.?(xfb, pname, index, param);
}
pub inline fn glGetTransformFeedbacki_v(xfb: GLuint, pname: GLenum, index: GLuint, param: [*c]GLint) void {
    return glad_glGetTransformFeedbacki_v.?(xfb, pname, index, param);
}
pub inline fn glGetTransformFeedbackiv(xfb: GLuint, pname: GLenum, param: [*c]GLint) void {
    return glad_glGetTransformFeedbackiv.?(xfb, pname, param);
}
pub inline fn glGetUniformBlockIndex(program: GLuint, uniformBlockName: [*c]const GLchar) GLuint {
    return glad_glGetUniformBlockIndex.?(program, uniformBlockName);
}
pub inline fn glGetUniformIndices(program: GLuint, uniformCount: GLsizei, uniformNames: [*c]const [*c]const GLchar, uniformIndices: [*c]GLuint) void {
    return glad_glGetUniformIndices.?(program, uniformCount, uniformNames, uniformIndices);
}
pub inline fn glGetUniformLocation(program: GLuint, name: [*c]const GLchar) GLint {
    return glad_glGetUniformLocation.?(program, name);
}
pub inline fn glGetUniformSubroutineuiv(shadertype: GLenum, location: GLint, params: [*c]GLuint) void {
    return glad_glGetUniformSubroutineuiv.?(shadertype, location, params);
}
pub inline fn glGetUniformdv(program: GLuint, location: GLint, params: [*c]GLdouble) void {
    return glad_glGetUniformdv.?(program, location, params);
}
pub inline fn glGetUniformfv(program: GLuint, location: GLint, params: [*c]GLfloat) void {
    return glad_glGetUniformfv.?(program, location, params);
}
pub inline fn glGetUniformiv(program: GLuint, location: GLint, params: [*c]GLint) void {
    return glad_glGetUniformiv.?(program, location, params);
}
pub inline fn glGetUniformuiv(program: GLuint, location: GLint, params: [*c]GLuint) void {
    return glad_glGetUniformuiv.?(program, location, params);
}
pub inline fn glGetVertexArrayIndexed64iv(vaobj: GLuint, index: GLuint, pname: GLenum, param: [*c]GLint64) void {
    return glad_glGetVertexArrayIndexed64iv.?(vaobj, index, pname, param);
}
pub inline fn glGetVertexArrayIndexediv(vaobj: GLuint, index: GLuint, pname: GLenum, param: [*c]GLint) void {
    return glad_glGetVertexArrayIndexediv.?(vaobj, index, pname, param);
}
pub inline fn glGetVertexArrayiv(vaobj: GLuint, pname: GLenum, param: [*c]GLint) void {
    return glad_glGetVertexArrayiv.?(vaobj, pname, param);
}
pub inline fn glGetVertexAttribIiv(index: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetVertexAttribIiv.?(index, pname, params);
}
pub inline fn glGetVertexAttribIuiv(index: GLuint, pname: GLenum, params: [*c]GLuint) void {
    return glad_glGetVertexAttribIuiv.?(index, pname, params);
}
pub inline fn glGetVertexAttribLdv(index: GLuint, pname: GLenum, params: [*c]GLdouble) void {
    return glad_glGetVertexAttribLdv.?(index, pname, params);
}
pub inline fn glGetVertexAttribPointerv(index: GLuint, pname: GLenum, pointer: [*c]?*anyopaque) void {
    return glad_glGetVertexAttribPointerv.?(index, pname, pointer);
}
pub inline fn glGetVertexAttribdv(index: GLuint, pname: GLenum, params: [*c]GLdouble) void {
    return glad_glGetVertexAttribdv.?(index, pname, params);
}
pub inline fn glGetVertexAttribfv(index: GLuint, pname: GLenum, params: [*c]GLfloat) void {
    return glad_glGetVertexAttribfv.?(index, pname, params);
}
pub inline fn glGetVertexAttribiv(index: GLuint, pname: GLenum, params: [*c]GLint) void {
    return glad_glGetVertexAttribiv.?(index, pname, params);
}
pub inline fn glGetnCompressedTexImage(target: GLenum, lod: GLint, bufSize: GLsizei, pixels: ?*anyopaque) void {
    return glad_glGetnCompressedTexImage.?(target, lod, bufSize, pixels);
}
pub inline fn glGetnTexImage(target: GLenum, level: GLint, format: GLenum, @"type": GLenum, bufSize: GLsizei, pixels: ?*anyopaque) void {
    return glad_glGetnTexImage.?(target, level, format, @"type", bufSize, pixels);
}
pub inline fn glGetnUniformdv(program: GLuint, location: GLint, bufSize: GLsizei, params: [*c]GLdouble) void {
    return glad_glGetnUniformdv.?(program, location, bufSize, params);
}
pub inline fn glGetnUniformfv(program: GLuint, location: GLint, bufSize: GLsizei, params: [*c]GLfloat) void {
    return glad_glGetnUniformfv.?(program, location, bufSize, params);
}
pub inline fn glGetnUniformiv(program: GLuint, location: GLint, bufSize: GLsizei, params: [*c]GLint) void {
    return glad_glGetnUniformiv.?(program, location, bufSize, params);
}
pub inline fn glGetnUniformuiv(program: GLuint, location: GLint, bufSize: GLsizei, params: [*c]GLuint) void {
    return glad_glGetnUniformuiv.?(program, location, bufSize, params);
}
pub inline fn glHint(target: GLenum, mode: GLenum) void {
    return glad_glHint.?(target, mode);
}
pub inline fn glInvalidateBufferData(buffer: GLuint) void {
    return glad_glInvalidateBufferData.?(buffer);
}
pub inline fn glInvalidateBufferSubData(buffer: GLuint, offset: GLintptr, length: GLsizeiptr) void {
    return glad_glInvalidateBufferSubData.?(buffer, offset, length);
}
pub inline fn glInvalidateFramebuffer(target: GLenum, numAttachments: GLsizei, attachments: [*c]const GLenum) void {
    return glad_glInvalidateFramebuffer.?(target, numAttachments, attachments);
}
pub inline fn glInvalidateNamedFramebufferData(framebuffer: GLuint, numAttachments: GLsizei, attachments: [*c]const GLenum) void {
    return glad_glInvalidateNamedFramebufferData.?(framebuffer, numAttachments, attachments);
}
pub inline fn glInvalidateNamedFramebufferSubData(framebuffer: GLuint, numAttachments: GLsizei, attachments: [*c]const GLenum, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
    return glad_glInvalidateNamedFramebufferSubData.?(framebuffer, numAttachments, attachments, x, y, width, height);
}
pub inline fn glInvalidateSubFramebuffer(target: GLenum, numAttachments: GLsizei, attachments: [*c]const GLenum, x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
    return glad_glInvalidateSubFramebuffer.?(target, numAttachments, attachments, x, y, width, height);
}
pub inline fn glInvalidateTexImage(texture: GLuint, level: GLint) void {
    return glad_glInvalidateTexImage.?(texture, level);
}
pub inline fn glInvalidateTexSubImage(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei) void {
    return glad_glInvalidateTexSubImage.?(texture, level, xoffset, yoffset, zoffset, width, height, depth);
}
pub inline fn glIsBuffer(buffer: GLuint) GLboolean {
    return glad_glIsBuffer.?(buffer);
}
pub inline fn glIsEnabled(cap: GLenum) GLboolean {
    return glad_glIsEnabled.?(cap);
}
pub inline fn glIsEnabledi(target: GLenum, index: GLuint) GLboolean {
    return glad_glIsEnabledi.?(target, index);
}
pub inline fn glIsFramebuffer(framebuffer: GLuint) GLboolean {
    return glad_glIsFramebuffer.?(framebuffer);
}
pub inline fn glIsProgram(program: GLuint) GLboolean {
    return glad_glIsProgram.?(program);
}
pub inline fn glIsProgramPipeline(pipeline: GLuint) GLboolean {
    return glad_glIsProgramPipeline.?(pipeline);
}
pub inline fn glIsQuery(id: GLuint) GLboolean {
    return glad_glIsQuery.?(id);
}
pub inline fn glIsRenderbuffer(renderbuffer: GLuint) GLboolean {
    return glad_glIsRenderbuffer.?(renderbuffer);
}
pub inline fn glIsSampler(sampler: GLuint) GLboolean {
    return glad_glIsSampler.?(sampler);
}
pub inline fn glIsShader(shader: GLuint) GLboolean {
    return glad_glIsShader.?(shader);
}
pub inline fn glIsSync(sync: GLsync) GLboolean {
    return glad_glIsSync.?(sync);
}
pub inline fn glIsTexture(texture: GLuint) GLboolean {
    return glad_glIsTexture.?(texture);
}
pub inline fn glIsTransformFeedback(id: GLuint) GLboolean {
    return glad_glIsTransformFeedback.?(id);
}
pub inline fn glIsVertexArray(array: GLuint) GLboolean {
    return glad_glIsVertexArray.?(array);
}
pub inline fn glLineWidth(width: GLfloat) void {
    return glad_glLineWidth.?(width);
}
pub inline fn glLinkProgram(program: GLuint) void {
    return glad_glLinkProgram.?(program);
}
pub inline fn glLogicOp(opcode: GLenum) void {
    return glad_glLogicOp.?(opcode);
}
pub inline fn glMapBuffer(target: GLenum, access: GLenum) ?*anyopaque {
    return glad_glMapBuffer.?(target, access);
}
pub inline fn glMapBufferRange(target: GLenum, offset: GLintptr, length: GLsizeiptr, access: GLbitfield) ?*anyopaque {
    return glad_glMapBufferRange.?(target, offset, length, access);
}
pub inline fn glMapNamedBuffer(buffer: GLuint, access: GLenum) ?*anyopaque {
    return glad_glMapNamedBuffer.?(buffer, access);
}
pub inline fn glMapNamedBufferRange(buffer: GLuint, offset: GLintptr, length: GLsizeiptr, access: GLbitfield) ?*anyopaque {
    return glad_glMapNamedBufferRange.?(buffer, offset, length, access);
}
pub inline fn glMemoryBarrier(barriers: GLbitfield) void {
    return glad_glMemoryBarrier.?(barriers);
}
pub inline fn glMemoryBarrierByRegion(barriers: GLbitfield) void {
    return glad_glMemoryBarrierByRegion.?(barriers);
}
pub inline fn glMinSampleShading(value: GLfloat) void {
    return glad_glMinSampleShading.?(value);
}
pub inline fn glMultiDrawArrays(mode: GLenum, first: [*c]const GLint, count: [*c]const GLsizei, drawcount: GLsizei) void {
    return glad_glMultiDrawArrays.?(mode, first, count, drawcount);
}
pub inline fn glMultiDrawArraysIndirect(mode: GLenum, indirect: ?*const anyopaque, drawcount: GLsizei, stride: GLsizei) void {
    return glad_glMultiDrawArraysIndirect.?(mode, indirect, drawcount, stride);
}
pub inline fn glMultiDrawArraysIndirectCount(mode: GLenum, indirect: ?*const anyopaque, drawcount: GLintptr, maxdrawcount: GLsizei, stride: GLsizei) void {
    return glad_glMultiDrawArraysIndirectCount.?(mode, indirect, drawcount, maxdrawcount, stride);
}
pub inline fn glMultiDrawElements(mode: GLenum, count: [*c]const GLsizei, @"type": GLenum, indices: [*c]const ?*const anyopaque, drawcount: GLsizei) void {
    return glad_glMultiDrawElements.?(mode, count, @"type", indices, drawcount);
}
pub inline fn glMultiDrawElementsBaseVertex(mode: GLenum, count: [*c]const GLsizei, @"type": GLenum, indices: [*c]const ?*const anyopaque, drawcount: GLsizei, basevertex: [*c]const GLint) void {
    return glad_glMultiDrawElementsBaseVertex.?(mode, count, @"type", indices, drawcount, basevertex);
}
pub inline fn glMultiDrawElementsIndirect(mode: GLenum, @"type": GLenum, indirect: ?*const anyopaque, drawcount: GLsizei, stride: GLsizei) void {
    return glad_glMultiDrawElementsIndirect.?(mode, @"type", indirect, drawcount, stride);
}
pub inline fn glMultiDrawElementsIndirectCount(mode: GLenum, @"type": GLenum, indirect: ?*const anyopaque, drawcount: GLintptr, maxdrawcount: GLsizei, stride: GLsizei) void {
    return glad_glMultiDrawElementsIndirectCount.?(mode, @"type", indirect, drawcount, maxdrawcount, stride);
}
pub inline fn glNamedBufferData(buffer: GLuint, size: GLsizeiptr, data: ?*const anyopaque, usage: GLenum) void {
    return glad_glNamedBufferData.?(buffer, size, data, usage);
}
pub inline fn glNamedBufferStorage(buffer: GLuint, size: GLsizeiptr, data: ?*const anyopaque, flags: GLbitfield) void {
    return glad_glNamedBufferStorage.?(buffer, size, data, flags);
}
pub inline fn glNamedBufferSubData(buffer: GLuint, offset: GLintptr, size: GLsizeiptr, data: ?*const anyopaque) void {
    return glad_glNamedBufferSubData.?(buffer, offset, size, data);
}
pub inline fn glNamedFramebufferDrawBuffer(framebuffer: GLuint, buf: GLenum) void {
    return glad_glNamedFramebufferDrawBuffer.?(framebuffer, buf);
}
pub inline fn glNamedFramebufferDrawBuffers(framebuffer: GLuint, n: GLsizei, bufs: [*c]const GLenum) void {
    return glad_glNamedFramebufferDrawBuffers.?(framebuffer, n, bufs);
}
pub inline fn glNamedFramebufferParameteri(framebuffer: GLuint, pname: GLenum, param: GLint) void {
    return glad_glNamedFramebufferParameteri.?(framebuffer, pname, param);
}
pub inline fn glNamedFramebufferReadBuffer(framebuffer: GLuint, src: GLenum) void {
    return glad_glNamedFramebufferReadBuffer.?(framebuffer, src);
}
pub inline fn glNamedFramebufferRenderbuffer(framebuffer: GLuint, attachment: GLenum, renderbuffertarget: GLenum, renderbuffer: GLuint) void {
    return glad_glNamedFramebufferRenderbuffer.?(framebuffer, attachment, renderbuffertarget, renderbuffer);
}
pub inline fn glNamedFramebufferTexture(framebuffer: GLuint, attachment: GLenum, texture: GLuint, level: GLint) void {
    return glad_glNamedFramebufferTexture.?(framebuffer, attachment, texture, level);
}
pub inline fn glNamedFramebufferTextureLayer(framebuffer: GLuint, attachment: GLenum, texture: GLuint, level: GLint, layer: GLint) void {
    return glad_glNamedFramebufferTextureLayer.?(framebuffer, attachment, texture, level, layer);
}
pub inline fn glNamedRenderbufferStorage(renderbuffer: GLuint, internalformat: GLenum, width: GLsizei, height: GLsizei) void {
    return glad_glNamedRenderbufferStorage.?(renderbuffer, internalformat, width, height);
}
pub inline fn glNamedRenderbufferStorageMultisample(renderbuffer: GLuint, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) void {
    return glad_glNamedRenderbufferStorageMultisample.?(renderbuffer, samples, internalformat, width, height);
}
pub inline fn glObjectLabel(identifier: GLenum, name: GLuint, length: GLsizei, label: [*c]const GLchar) void {
    return glad_glObjectLabel.?(identifier, name, length, label);
}
pub inline fn glObjectPtrLabel(ptr: ?*const anyopaque, length: GLsizei, label: [*c]const GLchar) void {
    return glad_glObjectPtrLabel.?(ptr, length, label);
}
pub inline fn glPatchParameterfv(pname: GLenum, values: [*c]const GLfloat) void {
    return glad_glPatchParameterfv.?(pname, values);
}
pub inline fn glPatchParameteri(pname: GLenum, value: GLint) void {
    return glad_glPatchParameteri.?(pname, value);
}
pub inline fn glPauseTransformFeedback() void {
    return glad_glPauseTransformFeedback.?();
}
pub inline fn glPixelStoref(pname: GLenum, param: GLfloat) void {
    return glad_glPixelStoref.?(pname, param);
}
pub inline fn glPixelStorei(pname: GLenum, param: GLint) void {
    return glad_glPixelStorei.?(pname, param);
}
pub inline fn glPointParameterf(pname: GLenum, param: GLfloat) void {
    return glad_glPointParameterf.?(pname, param);
}
pub inline fn glPointParameterfv(pname: GLenum, params: [*c]const GLfloat) void {
    return glad_glPointParameterfv.?(pname, params);
}
pub inline fn glPointParameteri(pname: GLenum, param: GLint) void {
    return glad_glPointParameteri.?(pname, param);
}
pub inline fn glPointParameteriv(pname: GLenum, params: [*c]const GLint) void {
    return glad_glPointParameteriv.?(pname, params);
}
pub inline fn glPointSize(size: GLfloat) void {
    return glad_glPointSize.?(size);
}
pub inline fn glPolygonMode(face: GLenum, mode: GLenum) void {
    return glad_glPolygonMode.?(face, mode);
}
pub inline fn glPolygonOffset(factor: GLfloat, units: GLfloat) void {
    return glad_glPolygonOffset.?(factor, units);
}
pub inline fn glPolygonOffsetClamp(factor: GLfloat, units: GLfloat, clamp: GLfloat) void {
    return glad_glPolygonOffsetClamp.?(factor, units, clamp);
}
pub inline fn glPopDebugGroup() void {
    return glad_glPopDebugGroup.?();
}
pub inline fn glPrimitiveRestartIndex(index: GLuint) void {
    return glad_glPrimitiveRestartIndex.?(index);
}
pub inline fn glProgramBinary(program: GLuint, binaryFormat: GLenum, binary: ?*const anyopaque, length: GLsizei) void {
    return glad_glProgramBinary.?(program, binaryFormat, binary, length);
}
pub inline fn glProgramParameteri(program: GLuint, pname: GLenum, value: GLint) void {
    return glad_glProgramParameteri.?(program, pname, value);
}
pub inline fn glProgramUniform1d(program: GLuint, location: GLint, v0: GLdouble) void {
    return glad_glProgramUniform1d.?(program, location, v0);
}
pub inline fn glProgramUniform1dv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLdouble) void {
    return glad_glProgramUniform1dv.?(program, location, count, value);
}
pub inline fn glProgramUniform1f(program: GLuint, location: GLint, v0: GLfloat) void {
    return glad_glProgramUniform1f.?(program, location, v0);
}
pub inline fn glProgramUniform1fv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    return glad_glProgramUniform1fv.?(program, location, count, value);
}
pub inline fn glProgramUniform1i(program: GLuint, location: GLint, v0: GLint) void {
    return glad_glProgramUniform1i.?(program, location, v0);
}
pub inline fn glProgramUniform1iv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLint) void {
    return glad_glProgramUniform1iv.?(program, location, count, value);
}
pub inline fn glProgramUniform1ui(program: GLuint, location: GLint, v0: GLuint) void {
    return glad_glProgramUniform1ui.?(program, location, v0);
}
pub inline fn glProgramUniform1uiv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLuint) void {
    return glad_glProgramUniform1uiv.?(program, location, count, value);
}
pub inline fn glProgramUniform2d(program: GLuint, location: GLint, v0: GLdouble, v1: GLdouble) void {
    return glad_glProgramUniform2d.?(program, location, v0, v1);
}
pub inline fn glProgramUniform2dv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLdouble) void {
    return glad_glProgramUniform2dv.?(program, location, count, value);
}
pub inline fn glProgramUniform2f(program: GLuint, location: GLint, v0: GLfloat, v1: GLfloat) void {
    return glad_glProgramUniform2f.?(program, location, v0, v1);
}
pub inline fn glProgramUniform2fv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    return glad_glProgramUniform2fv.?(program, location, count, value);
}
pub inline fn glProgramUniform2i(program: GLuint, location: GLint, v0: GLint, v1: GLint) void {
    return glad_glProgramUniform2i.?(program, location, v0, v1);
}
pub inline fn glProgramUniform2iv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLint) void {
    return glad_glProgramUniform2iv.?(program, location, count, value);
}
pub inline fn glProgramUniform2ui(program: GLuint, location: GLint, v0: GLuint, v1: GLuint) void {
    return glad_glProgramUniform2ui.?(program, location, v0, v1);
}
pub inline fn glProgramUniform2uiv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLuint) void {
    return glad_glProgramUniform2uiv.?(program, location, count, value);
}
pub inline fn glProgramUniform3d(program: GLuint, location: GLint, v0: GLdouble, v1: GLdouble, v2: GLdouble) void {
    return glad_glProgramUniform3d.?(program, location, v0, v1, v2);
}
pub inline fn glProgramUniform3dv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLdouble) void {
    return glad_glProgramUniform3dv.?(program, location, count, value);
}
pub inline fn glProgramUniform3f(program: GLuint, location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) void {
    return glad_glProgramUniform3f.?(program, location, v0, v1, v2);
}
pub inline fn glProgramUniform3fv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    return glad_glProgramUniform3fv.?(program, location, count, value);
}
pub inline fn glProgramUniform3i(program: GLuint, location: GLint, v0: GLint, v1: GLint, v2: GLint) void {
    return glad_glProgramUniform3i.?(program, location, v0, v1, v2);
}
pub inline fn glProgramUniform3iv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLint) void {
    return glad_glProgramUniform3iv.?(program, location, count, value);
}
pub inline fn glProgramUniform3ui(program: GLuint, location: GLint, v0: GLuint, v1: GLuint, v2: GLuint) void {
    return glad_glProgramUniform3ui.?(program, location, v0, v1, v2);
}
pub inline fn glProgramUniform3uiv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLuint) void {
    return glad_glProgramUniform3uiv.?(program, location, count, value);
}
pub inline fn glProgramUniform4d(program: GLuint, location: GLint, v0: GLdouble, v1: GLdouble, v2: GLdouble, v3: GLdouble) void {
    return glad_glProgramUniform4d.?(program, location, v0, v1, v2, v3);
}
pub inline fn glProgramUniform4dv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLdouble) void {
    return glad_glProgramUniform4dv.?(program, location, count, value);
}
pub inline fn glProgramUniform4f(program: GLuint, location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat, v3: GLfloat) void {
    return glad_glProgramUniform4f.?(program, location, v0, v1, v2, v3);
}
pub inline fn glProgramUniform4fv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    return glad_glProgramUniform4fv.?(program, location, count, value);
}
pub inline fn glProgramUniform4i(program: GLuint, location: GLint, v0: GLint, v1: GLint, v2: GLint, v3: GLint) void {
    return glad_glProgramUniform4i.?(program, location, v0, v1, v2, v3);
}
pub inline fn glProgramUniform4iv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLint) void {
    return glad_glProgramUniform4iv.?(program, location, count, value);
}
pub inline fn glProgramUniform4ui(program: GLuint, location: GLint, v0: GLuint, v1: GLuint, v2: GLuint, v3: GLuint) void {
    return glad_glProgramUniform4ui.?(program, location, v0, v1, v2, v3);
}
pub inline fn glProgramUniform4uiv(program: GLuint, location: GLint, count: GLsizei, value: [*c]const GLuint) void {
    return glad_glProgramUniform4uiv.?(program, location, count, value);
}
pub inline fn glProgramUniformMatrix2dv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glProgramUniformMatrix2dv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix2fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glProgramUniformMatrix2fv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix2x3dv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glProgramUniformMatrix2x3dv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix2x3fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glProgramUniformMatrix2x3fv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix2x4dv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glProgramUniformMatrix2x4dv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix2x4fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glProgramUniformMatrix2x4fv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix3dv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glProgramUniformMatrix3dv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix3fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glProgramUniformMatrix3fv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix3x2dv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glProgramUniformMatrix3x2dv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix3x2fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glProgramUniformMatrix3x2fv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix3x4dv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glProgramUniformMatrix3x4dv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix3x4fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glProgramUniformMatrix3x4fv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix4dv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glProgramUniformMatrix4dv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix4fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glProgramUniformMatrix4fv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix4x2dv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glProgramUniformMatrix4x2dv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix4x2fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glProgramUniformMatrix4x2fv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix4x3dv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glProgramUniformMatrix4x3dv.?(program, location, count, transpose, value);
}
pub inline fn glProgramUniformMatrix4x3fv(program: GLuint, location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glProgramUniformMatrix4x3fv.?(program, location, count, transpose, value);
}
pub inline fn glProvokingVertex(mode: GLenum) void {
    return glad_glProvokingVertex.?(mode);
}
pub inline fn glPushDebugGroup(source: GLenum, id: GLuint, length: GLsizei, message: [*c]const GLchar) void {
    return glad_glPushDebugGroup.?(source, id, length, message);
}
pub inline fn glQueryCounter(id: GLuint, target: GLenum) void {
    return glad_glQueryCounter.?(id, target);
}
pub inline fn glReadBuffer(src: GLenum) void {
    return glad_glReadBuffer.?(src);
}
pub inline fn glReadPixels(x: GLint, y: GLint, width: GLsizei, height: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*anyopaque) void {
    return glad_glReadPixels.?(x, y, width, height, format, @"type", pixels);
}
pub inline fn glReadnPixels(x: GLint, y: GLint, width: GLsizei, height: GLsizei, format: GLenum, @"type": GLenum, bufSize: GLsizei, data: ?*anyopaque) void {
    return glad_glReadnPixels.?(x, y, width, height, format, @"type", bufSize, data);
}
pub inline fn glReleaseShaderCompiler() void {
    return glad_glReleaseShaderCompiler.?();
}
pub inline fn glRenderbufferStorage(target: GLenum, internalformat: GLenum, width: GLsizei, height: GLsizei) void {
    return glad_glRenderbufferStorage.?(target, internalformat, width, height);
}
pub inline fn glRenderbufferStorageMultisample(target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) void {
    return glad_glRenderbufferStorageMultisample.?(target, samples, internalformat, width, height);
}
pub inline fn glResumeTransformFeedback() void {
    return glad_glResumeTransformFeedback.?();
}
pub inline fn glSampleCoverage(value: GLfloat, invert: GLboolean) void {
    return glad_glSampleCoverage.?(value, invert);
}
pub inline fn glSampleMaski(maskNumber: GLuint, mask: GLbitfield) void {
    return glad_glSampleMaski.?(maskNumber, mask);
}
pub inline fn glSamplerParameterIiv(sampler: GLuint, pname: GLenum, param: [*c]const GLint) void {
    return glad_glSamplerParameterIiv.?(sampler, pname, param);
}
pub inline fn glSamplerParameterIuiv(sampler: GLuint, pname: GLenum, param: [*c]const GLuint) void {
    return glad_glSamplerParameterIuiv.?(sampler, pname, param);
}
pub inline fn glSamplerParameterf(sampler: GLuint, pname: GLenum, param: GLfloat) void {
    return glad_glSamplerParameterf.?(sampler, pname, param);
}
pub inline fn glSamplerParameterfv(sampler: GLuint, pname: GLenum, param: [*c]const GLfloat) void {
    return glad_glSamplerParameterfv.?(sampler, pname, param);
}
pub inline fn glSamplerParameteri(sampler: GLuint, pname: GLenum, param: GLint) void {
    return glad_glSamplerParameteri.?(sampler, pname, param);
}
pub inline fn glSamplerParameteriv(sampler: GLuint, pname: GLenum, param: [*c]const GLint) void {
    return glad_glSamplerParameteriv.?(sampler, pname, param);
}
pub inline fn glScissor(x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
    return glad_glScissor.?(x, y, width, height);
}
pub inline fn glScissorArrayv(first: GLuint, count: GLsizei, v: [*c]const GLint) void {
    return glad_glScissorArrayv.?(first, count, v);
}
pub inline fn glScissorIndexed(index: GLuint, left: GLint, bottom: GLint, width: GLsizei, height: GLsizei) void {
    return glad_glScissorIndexed.?(index, left, bottom, width, height);
}
pub inline fn glScissorIndexedv(index: GLuint, v: [*c]const GLint) void {
    return glad_glScissorIndexedv.?(index, v);
}
pub inline fn glShaderBinary(count: GLsizei, shaders: [*c]const GLuint, binaryFormat: GLenum, binary: ?*const anyopaque, length: GLsizei) void {
    return glad_glShaderBinary.?(count, shaders, binaryFormat, binary, length);
}
pub inline fn glShaderSource(shader: GLuint, count: GLsizei, string: [*c]const [*c]const GLchar, length: [*c]const GLint) void {
    return glad_glShaderSource.?(shader, count, string, length);
}
pub inline fn glShaderStorageBlockBinding(program: GLuint, storageBlockIndex: GLuint, storageBlockBinding: GLuint) void {
    return glad_glShaderStorageBlockBinding.?(program, storageBlockIndex, storageBlockBinding);
}
pub inline fn glSpecializeShader(shader: GLuint, pEntryPoint: [*c]const GLchar, numSpecializationConstants: GLuint, pConstantIndex: [*c]const GLuint, pConstantValue: [*c]const GLuint) void {
    return glad_glSpecializeShader.?(shader, pEntryPoint, numSpecializationConstants, pConstantIndex, pConstantValue);
}
pub inline fn glStencilFunc(func: GLenum, ref: GLint, mask: GLuint) void {
    return glad_glStencilFunc.?(func, ref, mask);
}
pub inline fn glStencilFuncSeparate(face: GLenum, func: GLenum, ref: GLint, mask: GLuint) void {
    return glad_glStencilFuncSeparate.?(face, func, ref, mask);
}
pub inline fn glStencilMask(mask: GLuint) void {
    return glad_glStencilMask.?(mask);
}
pub inline fn glStencilMaskSeparate(face: GLenum, mask: GLuint) void {
    return glad_glStencilMaskSeparate.?(face, mask);
}
pub inline fn glStencilOp(fail: GLenum, zfail: GLenum, zpass: GLenum) void {
    return glad_glStencilOp.?(fail, zfail, zpass);
}
pub inline fn glStencilOpSeparate(face: GLenum, sfail: GLenum, dpfail: GLenum, dppass: GLenum) void {
    return glad_glStencilOpSeparate.?(face, sfail, dpfail, dppass);
}
pub inline fn glTexBuffer(target: GLenum, internalformat: GLenum, buffer: GLuint) void {
    return glad_glTexBuffer.?(target, internalformat, buffer);
}
pub inline fn glTexBufferRange(target: GLenum, internalformat: GLenum, buffer: GLuint, offset: GLintptr, size: GLsizeiptr) void {
    return glad_glTexBufferRange.?(target, internalformat, buffer, offset, size);
}
pub inline fn glTexImage1D(target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, border: GLint, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) void {
    return glad_glTexImage1D.?(target, level, internalformat, width, border, format, @"type", pixels);
}
pub inline fn glTexImage2D(target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, height: GLsizei, border: GLint, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) void {
    return glad_glTexImage2D.?(target, level, internalformat, width, height, border, format, @"type", pixels);
}
pub inline fn glTexImage2DMultisample(target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, fixedsamplelocations: GLboolean) void {
    return glad_glTexImage2DMultisample.?(target, samples, internalformat, width, height, fixedsamplelocations);
}
pub inline fn glTexImage3D(target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, border: GLint, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) void {
    return glad_glTexImage3D.?(target, level, internalformat, width, height, depth, border, format, @"type", pixels);
}
pub inline fn glTexImage3DMultisample(target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, fixedsamplelocations: GLboolean) void {
    return glad_glTexImage3DMultisample.?(target, samples, internalformat, width, height, depth, fixedsamplelocations);
}
pub inline fn glTexParameterIiv(target: GLenum, pname: GLenum, params: [*c]const GLint) void {
    return glad_glTexParameterIiv.?(target, pname, params);
}
pub inline fn glTexParameterIuiv(target: GLenum, pname: GLenum, params: [*c]const GLuint) void {
    return glad_glTexParameterIuiv.?(target, pname, params);
}
pub inline fn glTexParameterf(target: GLenum, pname: GLenum, param: GLfloat) void {
    return glad_glTexParameterf.?(target, pname, param);
}
pub inline fn glTexParameterfv(target: GLenum, pname: GLenum, params: [*c]const GLfloat) void {
    return glad_glTexParameterfv.?(target, pname, params);
}
pub inline fn glTexParameteri(target: GLenum, pname: GLenum, param: GLint) void {
    return glad_glTexParameteri.?(target, pname, param);
}
pub inline fn glTexParameteriv(target: GLenum, pname: GLenum, params: [*c]const GLint) void {
    return glad_glTexParameteriv.?(target, pname, params);
}
pub inline fn glTexStorage1D(target: GLenum, levels: GLsizei, internalformat: GLenum, width: GLsizei) void {
    return glad_glTexStorage1D.?(target, levels, internalformat, width);
}
pub inline fn glTexStorage2D(target: GLenum, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) void {
    return glad_glTexStorage2D.?(target, levels, internalformat, width, height);
}
pub inline fn glTexStorage2DMultisample(target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, fixedsamplelocations: GLboolean) void {
    return glad_glTexStorage2DMultisample.?(target, samples, internalformat, width, height, fixedsamplelocations);
}
pub inline fn glTexStorage3D(target: GLenum, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei) void {
    return glad_glTexStorage3D.?(target, levels, internalformat, width, height, depth);
}
pub inline fn glTexStorage3DMultisample(target: GLenum, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, fixedsamplelocations: GLboolean) void {
    return glad_glTexStorage3DMultisample.?(target, samples, internalformat, width, height, depth, fixedsamplelocations);
}
pub inline fn glTexSubImage1D(target: GLenum, level: GLint, xoffset: GLint, width: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) void {
    return glad_glTexSubImage1D.?(target, level, xoffset, width, format, @"type", pixels);
}
pub inline fn glTexSubImage2D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) void {
    return glad_glTexSubImage2D.?(target, level, xoffset, yoffset, width, height, format, @"type", pixels);
}
pub inline fn glTexSubImage3D(target: GLenum, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) void {
    return glad_glTexSubImage3D.?(target, level, xoffset, yoffset, zoffset, width, height, depth, format, @"type", pixels);
}
pub inline fn glTextureBarrier() void {
    return glad_glTextureBarrier.?();
}
pub inline fn glTextureBuffer(texture: GLuint, internalformat: GLenum, buffer: GLuint) void {
    return glad_glTextureBuffer.?(texture, internalformat, buffer);
}
pub inline fn glTextureBufferRange(texture: GLuint, internalformat: GLenum, buffer: GLuint, offset: GLintptr, size: GLsizeiptr) void {
    return glad_glTextureBufferRange.?(texture, internalformat, buffer, offset, size);
}
pub inline fn glTextureParameterIiv(texture: GLuint, pname: GLenum, params: [*c]const GLint) void {
    return glad_glTextureParameterIiv.?(texture, pname, params);
}
pub inline fn glTextureParameterIuiv(texture: GLuint, pname: GLenum, params: [*c]const GLuint) void {
    return glad_glTextureParameterIuiv.?(texture, pname, params);
}
pub inline fn glTextureParameterf(texture: GLuint, pname: GLenum, param: GLfloat) void {
    return glad_glTextureParameterf.?(texture, pname, param);
}
pub inline fn glTextureParameterfv(texture: GLuint, pname: GLenum, param: [*c]const GLfloat) void {
    return glad_glTextureParameterfv.?(texture, pname, param);
}
pub inline fn glTextureParameteri(texture: GLuint, pname: GLenum, param: GLint) void {
    return glad_glTextureParameteri.?(texture, pname, param);
}
pub inline fn glTextureParameteriv(texture: GLuint, pname: GLenum, param: [*c]const GLint) void {
    return glad_glTextureParameteriv.?(texture, pname, param);
}
pub inline fn glTextureStorage1D(texture: GLuint, levels: GLsizei, internalformat: GLenum, width: GLsizei) void {
    return glad_glTextureStorage1D.?(texture, levels, internalformat, width);
}
pub inline fn glTextureStorage2D(texture: GLuint, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei) void {
    return glad_glTextureStorage2D.?(texture, levels, internalformat, width, height);
}
pub inline fn glTextureStorage2DMultisample(texture: GLuint, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, fixedsamplelocations: GLboolean) void {
    return glad_glTextureStorage2DMultisample.?(texture, samples, internalformat, width, height, fixedsamplelocations);
}
pub inline fn glTextureStorage3D(texture: GLuint, levels: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei) void {
    return glad_glTextureStorage3D.?(texture, levels, internalformat, width, height, depth);
}
pub inline fn glTextureStorage3DMultisample(texture: GLuint, samples: GLsizei, internalformat: GLenum, width: GLsizei, height: GLsizei, depth: GLsizei, fixedsamplelocations: GLboolean) void {
    return glad_glTextureStorage3DMultisample.?(texture, samples, internalformat, width, height, depth, fixedsamplelocations);
}
pub inline fn glTextureSubImage1D(texture: GLuint, level: GLint, xoffset: GLint, width: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) void {
    return glad_glTextureSubImage1D.?(texture, level, xoffset, width, format, @"type", pixels);
}
pub inline fn glTextureSubImage2D(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, width: GLsizei, height: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) void {
    return glad_glTextureSubImage2D.?(texture, level, xoffset, yoffset, width, height, format, @"type", pixels);
}
pub inline fn glTextureSubImage3D(texture: GLuint, level: GLint, xoffset: GLint, yoffset: GLint, zoffset: GLint, width: GLsizei, height: GLsizei, depth: GLsizei, format: GLenum, @"type": GLenum, pixels: ?*const anyopaque) void {
    return glad_glTextureSubImage3D.?(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, @"type", pixels);
}
pub inline fn glTextureView(texture: GLuint, target: GLenum, origtexture: GLuint, internalformat: GLenum, minlevel: GLuint, numlevels: GLuint, minlayer: GLuint, numlayers: GLuint) void {
    return glad_glTextureView.?(texture, target, origtexture, internalformat, minlevel, numlevels, minlayer, numlayers);
}
pub inline fn glTransformFeedbackBufferBase(xfb: GLuint, index: GLuint, buffer: GLuint) void {
    return glad_glTransformFeedbackBufferBase.?(xfb, index, buffer);
}
pub inline fn glTransformFeedbackBufferRange(xfb: GLuint, index: GLuint, buffer: GLuint, offset: GLintptr, size: GLsizeiptr) void {
    return glad_glTransformFeedbackBufferRange.?(xfb, index, buffer, offset, size);
}
pub inline fn glTransformFeedbackVaryings(program: GLuint, count: GLsizei, varyings: [*c]const [*c]const GLchar, bufferMode: GLenum) void {
    return glad_glTransformFeedbackVaryings.?(program, count, varyings, bufferMode);
}
pub inline fn glUniform1d(location: GLint, x: GLdouble) void {
    return glad_glUniform1d.?(location, x);
}
pub inline fn glUniform1dv(location: GLint, count: GLsizei, value: [*c]const GLdouble) void {
    return glad_glUniform1dv.?(location, count, value);
}
pub inline fn glUniform1f(location: GLint, v0: GLfloat) void {
    return glad_glUniform1f.?(location, v0);
}
pub inline fn glUniform1fv(location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    return glad_glUniform1fv.?(location, count, value);
}
pub inline fn glUniform1i(location: GLint, v0: GLint) void {
    return glad_glUniform1i.?(location, v0);
}
pub inline fn glUniform1iv(location: GLint, count: GLsizei, value: [*c]const GLint) void {
    return glad_glUniform1iv.?(location, count, value);
}
pub inline fn glUniform1ui(location: GLint, v0: GLuint) void {
    return glad_glUniform1ui.?(location, v0);
}
pub inline fn glUniform1uiv(location: GLint, count: GLsizei, value: [*c]const GLuint) void {
    return glad_glUniform1uiv.?(location, count, value);
}
pub inline fn glUniform2d(location: GLint, x: GLdouble, y: GLdouble) void {
    return glad_glUniform2d.?(location, x, y);
}
pub inline fn glUniform2dv(location: GLint, count: GLsizei, value: [*c]const GLdouble) void {
    return glad_glUniform2dv.?(location, count, value);
}
pub inline fn glUniform2f(location: GLint, v0: GLfloat, v1: GLfloat) void {
    return glad_glUniform2f.?(location, v0, v1);
}
pub inline fn glUniform2fv(location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    return glad_glUniform2fv.?(location, count, value);
}
pub inline fn glUniform2i(location: GLint, v0: GLint, v1: GLint) void {
    return glad_glUniform2i.?(location, v0, v1);
}
pub inline fn glUniform2iv(location: GLint, count: GLsizei, value: [*c]const GLint) void {
    return glad_glUniform2iv.?(location, count, value);
}
pub inline fn glUniform2ui(location: GLint, v0: GLuint, v1: GLuint) void {
    return glad_glUniform2ui.?(location, v0, v1);
}
pub inline fn glUniform2uiv(location: GLint, count: GLsizei, value: [*c]const GLuint) void {
    return glad_glUniform2uiv.?(location, count, value);
}
pub inline fn glUniform3d(location: GLint, x: GLdouble, y: GLdouble, z: GLdouble) void {
    return glad_glUniform3d.?(location, x, y, z);
}
pub inline fn glUniform3dv(location: GLint, count: GLsizei, value: [*c]const GLdouble) void {
    return glad_glUniform3dv.?(location, count, value);
}
pub inline fn glUniform3f(location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat) void {
    return glad_glUniform3f.?(location, v0, v1, v2);
}
pub inline fn glUniform3fv(location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    return glad_glUniform3fv.?(location, count, value);
}
pub inline fn glUniform3i(location: GLint, v0: GLint, v1: GLint, v2: GLint) void {
    return glad_glUniform3i.?(location, v0, v1, v2);
}
pub inline fn glUniform3iv(location: GLint, count: GLsizei, value: [*c]const GLint) void {
    return glad_glUniform3iv.?(location, count, value);
}
pub inline fn glUniform3ui(location: GLint, v0: GLuint, v1: GLuint, v2: GLuint) void {
    return glad_glUniform3ui.?(location, v0, v1, v2);
}
pub inline fn glUniform3uiv(location: GLint, count: GLsizei, value: [*c]const GLuint) void {
    return glad_glUniform3uiv.?(location, count, value);
}
pub inline fn glUniform4d(location: GLint, x: GLdouble, y: GLdouble, z: GLdouble, w: GLdouble) void {
    return glad_glUniform4d.?(location, x, y, z, w);
}
pub inline fn glUniform4dv(location: GLint, count: GLsizei, value: [*c]const GLdouble) void {
    return glad_glUniform4dv.?(location, count, value);
}
pub inline fn glUniform4f(location: GLint, v0: GLfloat, v1: GLfloat, v2: GLfloat, v3: GLfloat) void {
    return glad_glUniform4f.?(location, v0, v1, v2, v3);
}
pub inline fn glUniform4fv(location: GLint, count: GLsizei, value: [*c]const GLfloat) void {
    return glad_glUniform4fv.?(location, count, value);
}
pub inline fn glUniform4i(location: GLint, v0: GLint, v1: GLint, v2: GLint, v3: GLint) void {
    return glad_glUniform4i.?(location, v0, v1, v2, v3);
}
pub inline fn glUniform4iv(location: GLint, count: GLsizei, value: [*c]const GLint) void {
    return glad_glUniform4iv.?(location, count, value);
}
pub inline fn glUniform4ui(location: GLint, v0: GLuint, v1: GLuint, v2: GLuint, v3: GLuint) void {
    return glad_glUniform4ui.?(location, v0, v1, v2, v3);
}
pub inline fn glUniform4uiv(location: GLint, count: GLsizei, value: [*c]const GLuint) void {
    return glad_glUniform4uiv.?(location, count, value);
}
pub inline fn glUniformBlockBinding(program: GLuint, uniformBlockIndex: GLuint, uniformBlockBinding: GLuint) void {
    return glad_glUniformBlockBinding.?(program, uniformBlockIndex, uniformBlockBinding);
}
pub inline fn glUniformMatrix2dv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glUniformMatrix2dv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix2fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glUniformMatrix2fv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix2x3dv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glUniformMatrix2x3dv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix2x3fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glUniformMatrix2x3fv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix2x4dv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glUniformMatrix2x4dv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix2x4fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glUniformMatrix2x4fv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix3dv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glUniformMatrix3dv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix3fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glUniformMatrix3fv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix3x2dv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glUniformMatrix3x2dv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix3x2fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glUniformMatrix3x2fv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix3x4dv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glUniformMatrix3x4dv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix3x4fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glUniformMatrix3x4fv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix4dv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glUniformMatrix4dv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix4fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glUniformMatrix4fv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix4x2dv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glUniformMatrix4x2dv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix4x2fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glUniformMatrix4x2fv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix4x3dv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLdouble) void {
    return glad_glUniformMatrix4x3dv.?(location, count, transpose, value);
}
pub inline fn glUniformMatrix4x3fv(location: GLint, count: GLsizei, transpose: GLboolean, value: [*c]const GLfloat) void {
    return glad_glUniformMatrix4x3fv.?(location, count, transpose, value);
}
pub inline fn glUniformSubroutinesuiv(shadertype: GLenum, count: GLsizei, indices: [*c]const GLuint) void {
    return glad_glUniformSubroutinesuiv.?(shadertype, count, indices);
}
pub inline fn glUnmapBuffer(target: GLenum) GLboolean {
    return glad_glUnmapBuffer.?(target);
}
pub inline fn glUnmapNamedBuffer(buffer: GLuint) GLboolean {
    return glad_glUnmapNamedBuffer.?(buffer);
}
pub inline fn glUseProgram(program: GLuint) void {
    return glad_glUseProgram.?(program);
}
pub inline fn glUseProgramStages(pipeline: GLuint, stages: GLbitfield, program: GLuint) void {
    return glad_glUseProgramStages.?(pipeline, stages, program);
}
pub inline fn glValidateProgram(program: GLuint) void {
    return glad_glValidateProgram.?(program);
}
pub inline fn glValidateProgramPipeline(pipeline: GLuint) void {
    return glad_glValidateProgramPipeline.?(pipeline);
}
pub inline fn glVertexArrayAttribBinding(vaobj: GLuint, attribindex: GLuint, bindingindex: GLuint) void {
    return glad_glVertexArrayAttribBinding.?(vaobj, attribindex, bindingindex);
}
pub inline fn glVertexArrayAttribFormat(vaobj: GLuint, attribindex: GLuint, size: GLint, @"type": GLenum, normalized: GLboolean, relativeoffset: GLuint) void {
    return glad_glVertexArrayAttribFormat.?(vaobj, attribindex, size, @"type", normalized, relativeoffset);
}
pub inline fn glVertexArrayAttribIFormat(vaobj: GLuint, attribindex: GLuint, size: GLint, @"type": GLenum, relativeoffset: GLuint) void {
    return glad_glVertexArrayAttribIFormat.?(vaobj, attribindex, size, @"type", relativeoffset);
}
pub inline fn glVertexArrayAttribLFormat(vaobj: GLuint, attribindex: GLuint, size: GLint, @"type": GLenum, relativeoffset: GLuint) void {
    return glad_glVertexArrayAttribLFormat.?(vaobj, attribindex, size, @"type", relativeoffset);
}
pub inline fn glVertexArrayBindingDivisor(vaobj: GLuint, bindingindex: GLuint, divisor: GLuint) void {
    return glad_glVertexArrayBindingDivisor.?(vaobj, bindingindex, divisor);
}
pub inline fn glVertexArrayElementBuffer(vaobj: GLuint, buffer: GLuint) void {
    return glad_glVertexArrayElementBuffer.?(vaobj, buffer);
}
pub inline fn glVertexArrayVertexBuffer(vaobj: GLuint, bindingindex: GLuint, buffer: GLuint, offset: GLintptr, stride: GLsizei) void {
    return glad_glVertexArrayVertexBuffer.?(vaobj, bindingindex, buffer, offset, stride);
}
pub inline fn glVertexArrayVertexBuffers(vaobj: GLuint, first: GLuint, count: GLsizei, buffers: [*c]const GLuint, offsets: [*c]const GLintptr, strides: [*c]const GLsizei) void {
    return glad_glVertexArrayVertexBuffers.?(vaobj, first, count, buffers, offsets, strides);
}
pub inline fn glVertexAttrib1d(index: GLuint, x: GLdouble) void {
    return glad_glVertexAttrib1d.?(index, x);
}
pub inline fn glVertexAttrib1dv(index: GLuint, v: [*c]const GLdouble) void {
    return glad_glVertexAttrib1dv.?(index, v);
}
pub inline fn glVertexAttrib1f(index: GLuint, x: GLfloat) void {
    return glad_glVertexAttrib1f.?(index, x);
}
pub inline fn glVertexAttrib1fv(index: GLuint, v: [*c]const GLfloat) void {
    return glad_glVertexAttrib1fv.?(index, v);
}
pub inline fn glVertexAttrib1s(index: GLuint, x: GLshort) void {
    return glad_glVertexAttrib1s.?(index, x);
}
pub inline fn glVertexAttrib1sv(index: GLuint, v: [*c]const GLshort) void {
    return glad_glVertexAttrib1sv.?(index, v);
}
pub inline fn glVertexAttrib2d(index: GLuint, x: GLdouble, y: GLdouble) void {
    return glad_glVertexAttrib2d.?(index, x, y);
}
pub inline fn glVertexAttrib2dv(index: GLuint, v: [*c]const GLdouble) void {
    return glad_glVertexAttrib2dv.?(index, v);
}
pub inline fn glVertexAttrib2f(index: GLuint, x: GLfloat, y: GLfloat) void {
    return glad_glVertexAttrib2f.?(index, x, y);
}
pub inline fn glVertexAttrib2fv(index: GLuint, v: [*c]const GLfloat) void {
    return glad_glVertexAttrib2fv.?(index, v);
}
pub inline fn glVertexAttrib2s(index: GLuint, x: GLshort, y: GLshort) void {
    return glad_glVertexAttrib2s.?(index, x, y);
}
pub inline fn glVertexAttrib2sv(index: GLuint, v: [*c]const GLshort) void {
    return glad_glVertexAttrib2sv.?(index, v);
}
pub inline fn glVertexAttrib3d(index: GLuint, x: GLdouble, y: GLdouble, z: GLdouble) void {
    return glad_glVertexAttrib3d.?(index, x, y, z);
}
pub inline fn glVertexAttrib3dv(index: GLuint, v: [*c]const GLdouble) void {
    return glad_glVertexAttrib3dv.?(index, v);
}
pub inline fn glVertexAttrib3f(index: GLuint, x: GLfloat, y: GLfloat, z: GLfloat) void {
    return glad_glVertexAttrib3f.?(index, x, y, z);
}
pub inline fn glVertexAttrib3fv(index: GLuint, v: [*c]const GLfloat) void {
    return glad_glVertexAttrib3fv.?(index, v);
}
pub inline fn glVertexAttrib3s(index: GLuint, x: GLshort, y: GLshort, z: GLshort) void {
    return glad_glVertexAttrib3s.?(index, x, y, z);
}
pub inline fn glVertexAttrib3sv(index: GLuint, v: [*c]const GLshort) void {
    return glad_glVertexAttrib3sv.?(index, v);
}
pub inline fn glVertexAttrib4Nbv(index: GLuint, v: [*c]const GLbyte) void {
    return glad_glVertexAttrib4Nbv.?(index, v);
}
pub inline fn glVertexAttrib4Niv(index: GLuint, v: [*c]const GLint) void {
    return glad_glVertexAttrib4Niv.?(index, v);
}
pub inline fn glVertexAttrib4Nsv(index: GLuint, v: [*c]const GLshort) void {
    return glad_glVertexAttrib4Nsv.?(index, v);
}
pub inline fn glVertexAttrib4Nub(index: GLuint, x: GLubyte, y: GLubyte, z: GLubyte, w: GLubyte) void {
    return glad_glVertexAttrib4Nub.?(index, x, y, z, w);
}
pub inline fn glVertexAttrib4Nubv(index: GLuint, v: [*c]const GLubyte) void {
    return glad_glVertexAttrib4Nubv.?(index, v);
}
pub inline fn glVertexAttrib4Nuiv(index: GLuint, v: [*c]const GLuint) void {
    return glad_glVertexAttrib4Nuiv.?(index, v);
}
pub inline fn glVertexAttrib4Nusv(index: GLuint, v: [*c]const GLushort) void {
    return glad_glVertexAttrib4Nusv.?(index, v);
}
pub inline fn glVertexAttrib4bv(index: GLuint, v: [*c]const GLbyte) void {
    return glad_glVertexAttrib4bv.?(index, v);
}
pub inline fn glVertexAttrib4d(index: GLuint, x: GLdouble, y: GLdouble, z: GLdouble, w: GLdouble) void {
    return glad_glVertexAttrib4d.?(index, x, y, z, w);
}
pub inline fn glVertexAttrib4dv(index: GLuint, v: [*c]const GLdouble) void {
    return glad_glVertexAttrib4dv.?(index, v);
}
pub inline fn glVertexAttrib4f(index: GLuint, x: GLfloat, y: GLfloat, z: GLfloat, w: GLfloat) void {
    return glad_glVertexAttrib4f.?(index, x, y, z, w);
}
pub inline fn glVertexAttrib4fv(index: GLuint, v: [*c]const GLfloat) void {
    return glad_glVertexAttrib4fv.?(index, v);
}
pub inline fn glVertexAttrib4iv(index: GLuint, v: [*c]const GLint) void {
    return glad_glVertexAttrib4iv.?(index, v);
}
pub inline fn glVertexAttrib4s(index: GLuint, x: GLshort, y: GLshort, z: GLshort, w: GLshort) void {
    return glad_glVertexAttrib4s.?(index, x, y, z, w);
}
pub inline fn glVertexAttrib4sv(index: GLuint, v: [*c]const GLshort) void {
    return glad_glVertexAttrib4sv.?(index, v);
}
pub inline fn glVertexAttrib4ubv(index: GLuint, v: [*c]const GLubyte) void {
    return glad_glVertexAttrib4ubv.?(index, v);
}
pub inline fn glVertexAttrib4uiv(index: GLuint, v: [*c]const GLuint) void {
    return glad_glVertexAttrib4uiv.?(index, v);
}
pub inline fn glVertexAttrib4usv(index: GLuint, v: [*c]const GLushort) void {
    return glad_glVertexAttrib4usv.?(index, v);
}
pub inline fn glVertexAttribBinding(attribindex: GLuint, bindingindex: GLuint) void {
    return glad_glVertexAttribBinding.?(attribindex, bindingindex);
}
pub inline fn glVertexAttribDivisor(index: GLuint, divisor: GLuint) void {
    return glad_glVertexAttribDivisor.?(index, divisor);
}
pub inline fn glVertexAttribFormat(attribindex: GLuint, size: GLint, @"type": GLenum, normalized: GLboolean, relativeoffset: GLuint) void {
    return glad_glVertexAttribFormat.?(attribindex, size, @"type", normalized, relativeoffset);
}
pub inline fn glVertexAttribI1i(index: GLuint, x: GLint) void {
    return glad_glVertexAttribI1i.?(index, x);
}
pub inline fn glVertexAttribI1iv(index: GLuint, v: [*c]const GLint) void {
    return glad_glVertexAttribI1iv.?(index, v);
}
pub inline fn glVertexAttribI1ui(index: GLuint, x: GLuint) void {
    return glad_glVertexAttribI1ui.?(index, x);
}
pub inline fn glVertexAttribI1uiv(index: GLuint, v: [*c]const GLuint) void {
    return glad_glVertexAttribI1uiv.?(index, v);
}
pub inline fn glVertexAttribI2i(index: GLuint, x: GLint, y: GLint) void {
    return glad_glVertexAttribI2i.?(index, x, y);
}
pub inline fn glVertexAttribI2iv(index: GLuint, v: [*c]const GLint) void {
    return glad_glVertexAttribI2iv.?(index, v);
}
pub inline fn glVertexAttribI2ui(index: GLuint, x: GLuint, y: GLuint) void {
    return glad_glVertexAttribI2ui.?(index, x, y);
}
pub inline fn glVertexAttribI2uiv(index: GLuint, v: [*c]const GLuint) void {
    return glad_glVertexAttribI2uiv.?(index, v);
}
pub inline fn glVertexAttribI3i(index: GLuint, x: GLint, y: GLint, z: GLint) void {
    return glad_glVertexAttribI3i.?(index, x, y, z);
}
pub inline fn glVertexAttribI3iv(index: GLuint, v: [*c]const GLint) void {
    return glad_glVertexAttribI3iv.?(index, v);
}
pub inline fn glVertexAttribI3ui(index: GLuint, x: GLuint, y: GLuint, z: GLuint) void {
    return glad_glVertexAttribI3ui.?(index, x, y, z);
}
pub inline fn glVertexAttribI3uiv(index: GLuint, v: [*c]const GLuint) void {
    return glad_glVertexAttribI3uiv.?(index, v);
}
pub inline fn glVertexAttribI4bv(index: GLuint, v: [*c]const GLbyte) void {
    return glad_glVertexAttribI4bv.?(index, v);
}
pub inline fn glVertexAttribI4i(index: GLuint, x: GLint, y: GLint, z: GLint, w: GLint) void {
    return glad_glVertexAttribI4i.?(index, x, y, z, w);
}
pub inline fn glVertexAttribI4iv(index: GLuint, v: [*c]const GLint) void {
    return glad_glVertexAttribI4iv.?(index, v);
}
pub inline fn glVertexAttribI4sv(index: GLuint, v: [*c]const GLshort) void {
    return glad_glVertexAttribI4sv.?(index, v);
}
pub inline fn glVertexAttribI4ubv(index: GLuint, v: [*c]const GLubyte) void {
    return glad_glVertexAttribI4ubv.?(index, v);
}
pub inline fn glVertexAttribI4ui(index: GLuint, x: GLuint, y: GLuint, z: GLuint, w: GLuint) void {
    return glad_glVertexAttribI4ui.?(index, x, y, z, w);
}
pub inline fn glVertexAttribI4uiv(index: GLuint, v: [*c]const GLuint) void {
    return glad_glVertexAttribI4uiv.?(index, v);
}
pub inline fn glVertexAttribI4usv(index: GLuint, v: [*c]const GLushort) void {
    return glad_glVertexAttribI4usv.?(index, v);
}
pub inline fn glVertexAttribIFormat(attribindex: GLuint, size: GLint, @"type": GLenum, relativeoffset: GLuint) void {
    return glad_glVertexAttribIFormat.?(attribindex, size, @"type", relativeoffset);
}
pub inline fn glVertexAttribIPointer(index: GLuint, size: GLint, @"type": GLenum, stride: GLsizei, pointer: ?*const anyopaque) void {
    return glad_glVertexAttribIPointer.?(index, size, @"type", stride, pointer);
}
pub inline fn glVertexAttribL1d(index: GLuint, x: GLdouble) void {
    return glad_glVertexAttribL1d.?(index, x);
}
pub inline fn glVertexAttribL1dv(index: GLuint, v: [*c]const GLdouble) void {
    return glad_glVertexAttribL1dv.?(index, v);
}
pub inline fn glVertexAttribL2d(index: GLuint, x: GLdouble, y: GLdouble) void {
    return glad_glVertexAttribL2d.?(index, x, y);
}
pub inline fn glVertexAttribL2dv(index: GLuint, v: [*c]const GLdouble) void {
    return glad_glVertexAttribL2dv.?(index, v);
}
pub inline fn glVertexAttribL3d(index: GLuint, x: GLdouble, y: GLdouble, z: GLdouble) void {
    return glad_glVertexAttribL3d.?(index, x, y, z);
}
pub inline fn glVertexAttribL3dv(index: GLuint, v: [*c]const GLdouble) void {
    return glad_glVertexAttribL3dv.?(index, v);
}
pub inline fn glVertexAttribL4d(index: GLuint, x: GLdouble, y: GLdouble, z: GLdouble, w: GLdouble) void {
    return glad_glVertexAttribL4d.?(index, x, y, z, w);
}
pub inline fn glVertexAttribL4dv(index: GLuint, v: [*c]const GLdouble) void {
    return glad_glVertexAttribL4dv.?(index, v);
}
pub inline fn glVertexAttribLFormat(attribindex: GLuint, size: GLint, @"type": GLenum, relativeoffset: GLuint) void {
    return glad_glVertexAttribLFormat.?(attribindex, size, @"type", relativeoffset);
}
pub inline fn glVertexAttribLPointer(index: GLuint, size: GLint, @"type": GLenum, stride: GLsizei, pointer: ?*const anyopaque) void {
    return glad_glVertexAttribLPointer.?(index, size, @"type", stride, pointer);
}
pub inline fn glVertexAttribP1ui(index: GLuint, @"type": GLenum, normalized: GLboolean, value: GLuint) void {
    return glad_glVertexAttribP1ui.?(index, @"type", normalized, value);
}
pub inline fn glVertexAttribP1uiv(index: GLuint, @"type": GLenum, normalized: GLboolean, value: [*c]const GLuint) void {
    return glad_glVertexAttribP1uiv.?(index, @"type", normalized, value);
}
pub inline fn glVertexAttribP2ui(index: GLuint, @"type": GLenum, normalized: GLboolean, value: GLuint) void {
    return glad_glVertexAttribP2ui.?(index, @"type", normalized, value);
}
pub inline fn glVertexAttribP2uiv(index: GLuint, @"type": GLenum, normalized: GLboolean, value: [*c]const GLuint) void {
    return glad_glVertexAttribP2uiv.?(index, @"type", normalized, value);
}
pub inline fn glVertexAttribP3ui(index: GLuint, @"type": GLenum, normalized: GLboolean, value: GLuint) void {
    return glad_glVertexAttribP3ui.?(index, @"type", normalized, value);
}
pub inline fn glVertexAttribP3uiv(index: GLuint, @"type": GLenum, normalized: GLboolean, value: [*c]const GLuint) void {
    return glad_glVertexAttribP3uiv.?(index, @"type", normalized, value);
}
pub inline fn glVertexAttribP4ui(index: GLuint, @"type": GLenum, normalized: GLboolean, value: GLuint) void {
    return glad_glVertexAttribP4ui.?(index, @"type", normalized, value);
}
pub inline fn glVertexAttribP4uiv(index: GLuint, @"type": GLenum, normalized: GLboolean, value: [*c]const GLuint) void {
    return glad_glVertexAttribP4uiv.?(index, @"type", normalized, value);
}
pub inline fn glVertexAttribPointer(index: GLuint, size: GLint, @"type": GLenum, normalized: GLboolean, stride: GLsizei, pointer: ?*const anyopaque) void {
    return glad_glVertexAttribPointer.?(index, size, @"type", normalized, stride, pointer);
}
pub inline fn glVertexBindingDivisor(bindingindex: GLuint, divisor: GLuint) void {
    return glad_glVertexBindingDivisor.?(bindingindex, divisor);
}
pub inline fn glViewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
    return glad_glViewport.?(x, y, width, height);
}
pub inline fn glViewportArrayv(first: GLuint, count: GLsizei, v: [*c]const GLfloat) void {
    return glad_glViewportArrayv.?(first, count, v);
}
pub inline fn glViewportIndexedf(index: GLuint, x: GLfloat, y: GLfloat, w: GLfloat, h: GLfloat) void {
    return glad_glViewportIndexedf.?(index, x, y, w, h);
}
pub inline fn glViewportIndexedfv(index: GLuint, v: [*c]const GLfloat) void {
    return glad_glViewportIndexedfv.?(index, v);
}
pub inline fn glWaitSync(sync: GLsync, flags: GLbitfield, timeout: GLuint64) void {
    return glad_glWaitSync.?(sync, flags, timeout);
}
pub const threadlocaleinfostruct = struct_threadlocaleinfostruct;
pub const threadmbcinfostruct = struct_threadmbcinfostruct;
pub const __lc_time_data = struct___lc_time_data;
pub const localeinfo_struct = struct_localeinfo_struct;
pub const tagLC_ID = struct_tagLC_ID;
pub const __GLsync = struct___GLsync;
pub const _cl_context = struct__cl_context;
pub const _cl_event = struct__cl_event;
