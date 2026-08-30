const std = @import("std");
const e = @import("example");
const Io = std.Io;

// const DVAP = @import("DVAP");

pub fn main(init: std.process.Init) !void {
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const arena: std.mem.Allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);
    for (args, 0..args.len) |arg, i| {
        std.log.info("arg: {s} {}", .{ arg, arg[i] });
    }

    const io = init.io;

    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, &stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    const a = e.chicken(0);
    const b = e.amongus(0.003);
    _ = &a;

    std.debug.print("from c: {} {} \n", .{ a, b });

    // try DVAP.printAnotherMessage(stdout_writer);

    try stdout_writer.flush(); // Don't forget to flush!
}
