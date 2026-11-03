const std = @import("std");
const zig_learning = @import("zig_learning");

pub fn main(init: std.process.Init) void {
    const code = execute(init);
    std.process.exit(code);
}

fn execute(init: std.process.Init) u8 {
    var stdout_buffer: [4096]u8 = undefined;
    var stderr_buffer: [4096]u8 = undefined;
    var stdout = std.Io.File.stdout().writer(init.io, &stdout_buffer);
    var stderr = std.Io.File.stderr().writer(init.io, &stderr_buffer);
    const args = init.minimal.args.toSlice(init.arena.allocator()) catch |err| {
        stderr.interface.print("无法读取命令行参数：{s}\n", .{@errorName(err)}) catch {};
        stderr.interface.flush() catch {};
        return 2;
    };
    var code = zig_learning.cli.run(.{
        .allocator = init.gpa,
        .io = init.io,
        .environ = init.environ_map,
        .out = &stdout.interface,
        .err = &stderr.interface,
    }, args[1..]) catch |err| blk: {
        stderr.interface.print("执行命令失败：{s}\n", .{@errorName(err)}) catch {};
        break :blk 2;
    };
    stdout.interface.flush() catch {
        code = 2;
    };
    stderr.interface.flush() catch {
        code = 2;
    };
    return code;
}
