//! 学习工作区：初始化课程目录、打开已存在的学习根目录。
//!
//! `init` 在写入任何内容前先确认目标目录中的 `exercises` 与
//! `.zig-learning` 都不存在；已存在时拒绝覆盖、拒绝合并，也不删除用户
//! 文件。所有练习与检查文件都用独占创建写入；初始进度最后写入。
//!
//! 初始化中途失败时不回滚已写入的文件，错误信息会明确指出失败位置并
//! 建议使用新的目标目录重试。

const std = @import("std");

const catalog = @import("course/catalog.zig");
const templates = @import("course/templates.zig");
const progress = @import("progress.zig");
const context = @import("context.zig");

const Context = context.Context;

pub const Workspace = struct {
    dir: std.Io.Dir,
    /// 绝对路径，由上下文分配器分配，`deinit` 负责释放。
    path: []const u8,

    pub fn deinit(self: *Workspace, ctx: Context) void {
        self.dir.close(ctx.io);
        ctx.allocator.free(self.path);
    }
};

/// 打开一个已存在的学习根目录。
///
/// 先把用户给出的路径解析为规范绝对路径，再以该路径打开目录，避免后续
/// 命令依赖进程当前工作目录的变化。
pub fn open(ctx: Context, path: []const u8) !Workspace {
    if (path.len == 0) {
        return fail(ctx, "无效的学习目录路径：路径为空。\n", .{});
    }

    var buffer: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const cwd = std.Io.Dir.cwd();
    const absolute_len = cwd.realPathFile(ctx.io, path, &buffer) catch |err| {
        return fail(ctx, "无法打开学习目录 {s}：{s}\n", .{ path, @errorName(err) });
    };
    const absolute = ctx.allocator.dupe(u8, buffer[0..absolute_len]) catch |err| {
        return fail(ctx, "无法打开学习目录 {s}：{s}\n", .{ path, @errorName(err) });
    };
    errdefer ctx.allocator.free(absolute);

    const dir = std.Io.Dir.openDirAbsolute(ctx.io, absolute, .{}) catch |err| {
        return fail(ctx, "无法打开学习目录 {s}：{s}\n", .{ path, @errorName(err) });
    };

    return .{ .dir = dir, .path = absolute };
}

/// 初始化学习目录。
///
/// `path` 可以不存在，也可以已经存在，但只要其中已经有 `exercises` 或
/// `.zig-learning`，就立即失败且不写入任何文件。
pub fn initialize(ctx: Context, path: []const u8) !void {
    if (path.len == 0) {
        return fail(ctx, "无效的学习目录路径：路径为空。\n", .{});
    }

    const cwd = std.Io.Dir.cwd();

    // 目标目录不存在时，两个课程目录必然也不存在；目标目录已存在时先
    // 打开它，再在写入任何文件前预检。
    var root_dir: std.Io.Dir = undefined;
    if (cwd.openDir(ctx.io, path, .{})) |dir| {
        root_dir = dir;
    } else |err| switch (err) {
        error.FileNotFound => {
            cwd.createDirPath(ctx.io, path) catch |create_err| {
                return fail(ctx, "无法创建学习目录 {s}：{s}\n", .{ path, @errorName(create_err) });
            };
            root_dir = cwd.openDir(ctx.io, path, .{}) catch |open_err| {
                return fail(ctx, "无法打开新建的学习目录 {s}：{s}\n", .{ path, @errorName(open_err) });
            };
        },
        else => return fail(ctx, "无法打开学习目录 {s}：{s}\n", .{ path, @errorName(err) }),
    }
    defer root_dir.close(ctx.io);

    // 第二次预检覆盖“目标目录刚由本进程创建”的情况，也缩小其它进程在这
    // 短暂窗口内抢先写入目录的竞态。
    try preflight(ctx, path, root_dir);

    root_dir.createDir(ctx.io, "exercises", .default_dir) catch |err| {
        return fail(ctx, "无法初始化学习目录 {s}：创建 exercises 失败（{s}）；不会回滚已写入的内容，请使用新的目标目录重试。\n", .{ path, @errorName(err) });
    };
    const exercises = root_dir.openDir(ctx.io, "exercises", .{}) catch |err| {
        return fail(ctx, "无法初始化学习目录 {s}：打开 exercises 失败（{s}）；不会回滚已写入的内容，请使用新的目标目录重试。\n", .{ path, @errorName(err) });
    };
    defer exercises.close(ctx.io);

    root_dir.createDir(ctx.io, ".zig-learning", .default_dir) catch |err| {
        return fail(ctx, "无法初始化学习目录 {s}：创建 .zig-learning 失败（{s}）；不会回滚已写入的内容，请使用新的目标目录重试。\n", .{ path, @errorName(err) });
    };
    const meta = root_dir.openDir(ctx.io, ".zig-learning", .{}) catch |err| {
        return fail(ctx, "无法初始化学习目录 {s}：打开 .zig-learning 失败（{s}）；不会回滚已写入的内容，请使用新的目标目录重试。\n", .{ path, @errorName(err) });
    };
    defer meta.close(ctx.io);

    meta.createDir(ctx.io, "checks", .default_dir) catch |err| {
        return fail(ctx, "无法初始化学习目录 {s}：创建 .zig-learning/checks 失败（{s}）；不会回滚已写入的内容，请使用新的目标目录重试。\n", .{ path, @errorName(err) });
    };
    const checks = meta.openDir(ctx.io, "checks", .{}) catch |err| {
        return fail(ctx, "无法初始化学习目录 {s}：打开 .zig-learning/checks 失败（{s}）；不会回滚已写入的内容，请使用新的目标目录重试。\n", .{ path, @errorName(err) });
    };
    defer checks.close(ctx.io);

    for (catalog.exercises, 0..) |exercise, index| {
        try writeExclusive(ctx, exercises, "exercises", exercise.id, templates.starters[index]);
    }
    for (catalog.exercises, 0..) |exercise, index| {
        try writeExclusive(ctx, checks, ".zig-learning/checks", exercise.id, templates.checks[index]);
    }

    // 进度文件最后写入：前面的文件都已成功落盘后才建立初始状态。
    const state = progress.State{};
    state.save(ctx, root_dir) catch |err| {
        try ctx.err.print("初始化未完成：{s} 中已写入的文件已保留，请使用新的目标目录重试。\n", .{path});
        return err;
    };
}

/// 确认学习目录中两个课程目录都不存在。
fn preflight(ctx: Context, root_path: []const u8, root: std.Io.Dir) !void {
    const names = [_][]const u8{ "exercises", ".zig-learning" };
    for (names) |name| {
        if (root.statFile(ctx.io, name, .{ .follow_symlinks = false })) |_| {
            return fail(ctx, "无法初始化学习目录 {s}：{s} 已存在，未写入任何文件；请使用新的目标目录。\n", .{ root_path, name });
        } else |err| switch (err) {
            error.FileNotFound => {},
            else => return fail(ctx, "无法检查学习目录 {s} 中的 {s}：{s}\n未写入任何文件。\n", .{ root_path, name, @errorName(err) }),
        }
    }
}

/// 以独占方式创建一个课程文件，不覆盖已有内容。
fn writeExclusive(
    ctx: Context,
    dir: std.Io.Dir,
    display_dir: []const u8,
    id: []const u8,
    contents: []const u8,
) !void {
    var name_buffer: [64]u8 = undefined;
    const name = std.fmt.bufPrint(&name_buffer, "{s}.zig", .{id}) catch {
        return fail(ctx, "初始化失败（{s}/{s}.zig）：文件名过长\n已写入的文件已保留；请使用新的目标目录重试。\n", .{ display_dir, id });
    };

    const file = dir.createFile(ctx.io, name, .{ .exclusive = true, .truncate = false }) catch |err| {
        return fail(ctx, "初始化失败（{s}/{s}）：{s}\n已写入的文件已保留；请使用新的目标目录重试。\n", .{ display_dir, name, @errorName(err) });
    };
    defer file.close(ctx.io);

    file.writeStreamingAll(ctx.io, contents) catch |err| {
        return fail(ctx, "初始化失败（{s}/{s}）：{s}\n已写入的文件已保留；请使用新的目标目录重试。\n", .{ display_dir, name, @errorName(err) });
    };
}

/// 打印中文诊断并返回统一的用户可见错误，供 CLI 映射为退出码 2。
fn fail(ctx: Context, comptime fmt: []const u8, args: anytype) error{Diagnosed} {
    ctx.err.print(fmt, args) catch {};
    return error.Diagnosed;
}

const TestContext = struct {
    env: std.process.Environ.Map,
    out_buffer: [512]u8 = undefined,
    err_buffer: [2048]u8 = undefined,
    out: std.Io.Writer.Discarding,
    err: std.Io.Writer.Discarding,

    fn init(allocator: std.mem.Allocator) TestContext {
        return .{
            .env = std.process.Environ.Map.init(allocator),
            .out = undefined,
            .err = undefined,
        };
    }

    fn context(self: *TestContext, allocator: std.mem.Allocator) Context {
        self.out = std.Io.Writer.Discarding.init(&self.out_buffer);
        self.err = std.Io.Writer.Discarding.init(&self.err_buffer);
        return .{
            .allocator = allocator,
            .io = std.testing.io,
            .environ = &self.env,
            .out = &self.out.writer,
            .err = &self.err.writer,
        };
    }

    fn deinit(self: *TestContext) void {
        self.env.deinit();
    }
};

/// 取得测试临时目录的规范绝对路径。
fn tempAbsolutePath(tmp: *std.testing.TmpDir, buffer: []u8) ![]const u8 {
    const n = try tmp.dir.realPath(std.testing.io, buffer);
    return buffer[0..n];
}

test "initialize 拒绝覆盖已有的课程目录" {
    const allocator = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var buffer: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const path = try tempAbsolutePath(&tmp, &buffer);

    var test_context = TestContext.init(allocator);
    defer test_context.deinit();
    const ctx = test_context.context(allocator);

    try initialize(ctx, path);

    // 改成哨兵内容，第二次初始化必须原样保留它。
    const exercises = try tmp.dir.openDir(std.testing.io, "exercises", .{});
    defer exercises.close(std.testing.io);
    try exercises.writeFile(std.testing.io, .{
        .sub_path = "01_values.zig",
        .data = "sentinel",
    });

    try std.testing.expectError(error.Diagnosed, initialize(ctx, path));

    const contents = try exercises.readFileAlloc(std.testing.io, "01_values.zig", allocator, .unlimited);
    defer allocator.free(contents);
    try std.testing.expectEqualStrings("sentinel", contents);
}

test "initialize 在已有 .zig-learning 时不写入任何练习" {
    const allocator = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var buffer: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const path = try tempAbsolutePath(&tmp, &buffer);

    try tmp.dir.createDir(std.testing.io, ".zig-learning", .default_dir);

    var test_context = TestContext.init(allocator);
    defer test_context.deinit();
    const ctx = test_context.context(allocator);

    try std.testing.expectError(error.Diagnosed, initialize(ctx, path));
    try std.testing.expectError(error.FileNotFound, tmp.dir.access(std.testing.io, "exercises", .{}));
}

test "open 返回规范绝对路径并可读取课程目录" {
    const allocator = std.testing.allocator;
    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var buffer: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const path = try tempAbsolutePath(&tmp, &buffer);

    var test_context = TestContext.init(allocator);
    defer test_context.deinit();
    const ctx = test_context.context(allocator);

    try initialize(ctx, path);

    var workspace = try open(ctx, path);
    defer workspace.deinit(ctx);

    try std.testing.expect(std.fs.path.isAbsolute(workspace.path));
    try workspace.dir.access(std.testing.io, "exercises", .{});
    try workspace.dir.access(std.testing.io, ".zig-learning", .{});
}
