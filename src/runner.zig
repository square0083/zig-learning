const std = @import("std");
const Context = @import("context.zig").Context;
const Workspace = @import("workspace.zig").Workspace;
const progress = @import("progress.zig");
const catalog = @import("course/catalog.zig");

pub const Result = enum { passed, failed, changed };

pub const Runner = struct {
    zig_path: []const u8,
    version_checked: bool = false,

    pub fn init(ctx: Context, executable: []const u8) !Runner {
        const has_separator = std.mem.indexOfAny(u8, executable, "/\\") != null;
        if (has_separator and !std.fs.path.isAbsolute(executable)) {
            const cwd = try std.process.currentPathAlloc(ctx.io, ctx.allocator);
            defer ctx.allocator.free(cwd);
            return .{ .zig_path = try std.fs.path.resolve(ctx.allocator, &.{ cwd, executable }) };
        }
        return .{ .zig_path = try ctx.allocator.dupe(u8, executable) };
    }

    pub fn deinit(self: *Runner, ctx: Context) void {
        ctx.allocator.free(self.zig_path);
    }

    fn checkVersion(self: *Runner, ctx: Context) !void {
        if (self.version_checked) return;
        try ctx.out.flush();
        try ctx.err.flush();
        const version = std.process.run(ctx.allocator, ctx.io, .{
            .argv = &.{ self.zig_path, "version" },
            .environ_map = ctx.environ,
            .create_no_window = false,
        }) catch |err| return diagnose(ctx, self.zig_path, err);
        defer ctx.allocator.free(version.stdout);
        defer ctx.allocator.free(version.stderr);
        const actual = std.mem.trim(u8, version.stdout, " \t\r\n");
        if (!version.term.success() or !std.mem.eql(u8, actual, "0.17.0")) {
            try ctx.err.print("编译器版本不匹配：需要 Zig 0.17.0，实际输出为「{s}」（{s}）。\n", .{ actual, self.zig_path });
            if (version.stderr.len != 0) try ctx.err.writeAll(version.stderr);
            return error.Diagnosed;
        }
        self.version_checked = true;
    }

    pub fn run(self: *Runner, ctx: Context, ws: *const Workspace, state: *progress.State, index: usize) !Result {
        const before = (try readSource(ctx, ws, index)) orelse return error.ExerciseMissing;
        defer ctx.allocator.free(before);
        const id = catalog.exercises[index].id;
        var check_buffer: [128]u8 = undefined;
        const check_relative = try std.fmt.bufPrint(&check_buffer, ".zig-learning/checks/{s}.zig", .{id});
        const check_file = ws.dir.openFile(ctx.io, check_relative, .{}) catch |err| return diagnose(ctx, check_relative, err);
        check_file.close(ctx.io);
        try self.checkVersion(ctx);

        const check_path = try std.fs.path.join(ctx.allocator, &.{ ws.path, check_relative });
        defer ctx.allocator.free(check_path);
        var source_buffer: [128]u8 = undefined;
        const source_relative = try std.fmt.bufPrint(&source_buffer, "exercises/{s}.zig", .{id});
        const source_path = try std.fs.path.join(ctx.allocator, &.{ ws.path, source_relative });
        defer ctx.allocator.free(source_path);
        const root_arg = try std.fmt.allocPrint(ctx.allocator, "-Mroot={s}", .{check_path});
        defer ctx.allocator.free(root_arg);
        const exercise_arg = try std.fmt.allocPrint(ctx.allocator, "-Mexercise={s}", .{source_path});
        defer ctx.allocator.free(exercise_arg);

        try ctx.out.print("正在检查 {s}：{s}\n", .{ id, catalog.exercises[index].title });
        try ctx.out.flush();
        try ctx.err.flush();
        var child = std.process.spawn(ctx.io, .{
            .argv = &.{ self.zig_path, "test", "--color", "off", "--dep", "exercise", root_arg, exercise_arg },
            .cwd = .{ .path = ws.path },
            .environ_map = ctx.environ,
            .stdin = .ignore,
            .stdout = .inherit,
            .stderr = .inherit,
            .create_no_window = false,
        }) catch |err| return diagnose(ctx, self.zig_path, err);
        defer child.kill(ctx.io);
        const term = child.wait(ctx.io) catch |err| return diagnose(ctx, self.zig_path, err);
        const after = try readSource(ctx, ws, index);
        defer if (after) |source| ctx.allocator.free(source);
        const unchanged = if (after) |source| std.mem.eql(u8, before, source) else false;
        const result: Result = if (!unchanged) .changed else if (term.success()) .passed else .failed;
        state.record(index, if (result == .passed) progress.sourceHash(before) else null);
        try state.save(ctx, ws.dir);
        switch (result) {
            .passed => try ctx.out.print("已通过 {s}，进度已保存。\n", .{id}),
            .failed => try ctx.out.print("未通过 {s}，请修改练习后重试。\n", .{id}),
            .changed => try ctx.out.writeAll("文件已变化，请重新检查\n"),
        }
        return result;
    }
};

/// 缺失与空文件不同：null 表示缺失；调用者释放非 null 的内容。
pub fn readSource(ctx: Context, ws: *const Workspace, index: usize) !?[]u8 {
    var buffer: [128]u8 = undefined;
    const path = try std.fmt.bufPrint(&buffer, "exercises/{s}.zig", .{catalog.exercises[index].id});
    return ws.dir.readFileAlloc(ctx.io, path, ctx.allocator, .unlimited) catch |err| switch (err) {
        error.FileNotFound => null,
        else => return diagnose(ctx, path, err),
    };
}

fn diagnose(ctx: Context, path: []const u8, err: anyerror) error{Diagnosed} {
    ctx.err.print("检查环境或文件错误（{s}）：{s}\n", .{ path, @errorName(err) }) catch {};
    return error.Diagnosed;
}
