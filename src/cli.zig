const std = @import("std");
pub const Context = @import("context.zig").Context;
const workspace = @import("workspace.zig");
const progress = @import("progress.zig");
const runner = @import("runner.zig");
const catalog = @import("course/catalog.zig");

const Command = enum { init, list, run, hint, watch, verify };
const Options = struct {
    command: Command = .watch,
    path: ?[]const u8 = null,
    zig: ?[]const u8 = null,
    positional: ?[]const u8 = null,
    level: ?u8 = null,
    help: bool = false,
    version: bool = false,
};

const usage =
    \\中文 Zig 练习（需要 Zig 0.17.0）
    \\用法：zig_learning [选项] <命令> [参数] [选项]
    \\  init [path]                 初始化（默认 zig-exercises），不覆盖已有课程
    \\  list                        按课程顺序查看状态
    \\  run [id]                    检查指定题或第一道未完成题
    \\  hint [id] [--level 1|2|3]    查看前 N 层中文提示（默认 1）
    \\  watch                       保存后自动检查（无命令时默认）
    \\  verify                      检查全部 36 题，普通失败不中断
    \\  --help                      显示帮助，不打开工作区
    \\  --version                   显示应用版本
    \\选项：--path <目录> 用于非 init 命令，默认当前目录；不向上查找。
    \\      --zig <可执行文件> 仅用于 run/watch/verify，默认从 PATH 查找 zig。
    \\题号必须完整，例如 01_values；选项可以在命令前后出现，不可重复。
    \\退出码：0 成功；1 已执行的练习未通过；2 参数、环境、文件或进度错误。
    \\用外部编辑器修改 exercises 下的文件；另一个终端运行 hint 查看提示。
    \\本地练习会直接执行，不是沙箱；仅运行你信任的代码。
    \\同一学习目录仅支持一个写进度的进程；不要同时运行多个 run/watch/verify。
    \\Ctrl+C 结束前台程序；Windows 终端请使用 UTF-8（必要时运行 chcp 65001）。
    \\
;

fn parse(args: []const []const u8) !Options {
    var options: Options = .{};
    var command_seen = false;
    var index: usize = 0;
    while (index < args.len) : (index += 1) {
        const arg = args[index];
        if (std.mem.eql(u8, arg, "--help")) {
            if (options.help) return error.DuplicateOption;
            options.help = true;
        } else if (std.mem.eql(u8, arg, "--version")) {
            if (options.version) return error.DuplicateOption;
            options.version = true;
        } else if (std.mem.eql(u8, arg, "--path") or std.mem.eql(u8, arg, "--zig") or std.mem.eql(u8, arg, "--level")) {
            index += 1;
            if (index == args.len or args[index].len == 0 or std.mem.startsWith(u8, args[index], "--")) return error.MissingValue;
            const value = args[index];
            if (std.mem.eql(u8, arg, "--path")) {
                if (options.path != null) return error.DuplicateOption;
                options.path = value;
            } else if (std.mem.eql(u8, arg, "--zig")) {
                if (options.zig != null) return error.DuplicateOption;
                options.zig = value;
            } else {
                if (options.level != null) return error.DuplicateOption;
                if (value.len != 1 or value[0] < '1' or value[0] > '3') return error.InvalidLevel;
                options.level = value[0] - '0';
            }
        } else if (std.mem.startsWith(u8, arg, "-")) {
            return error.UnknownOption;
        } else if (!command_seen) {
            options.command = std.meta.stringToEnum(Command, arg) orelse return error.UnknownCommand;
            command_seen = true;
        } else {
            if (options.positional != null) return error.ExtraArgument;
            options.positional = arg;
        }
    }
    if (options.command == .init and options.path != null) return error.InvalidOption;
    if (options.zig != null and options.command != .run and options.command != .watch and options.command != .verify) return error.InvalidOption;
    if (options.level != null and options.command != .hint) return error.InvalidOption;
    if (options.positional != null and options.command != .init and options.command != .run and options.command != .hint) return error.ExtraArgument;
    return options;
}

pub fn run(ctx: Context, args: []const []const u8) !u8 {
    const options = parse(args) catch |err| {
        const reason = switch (err) {
            error.DuplicateOption => "选项重复",
            error.MissingValue => "选项缺少参数",
            error.InvalidLevel => "提示层级必须是 1、2 或 3",
            error.UnknownOption => "未知选项",
            error.UnknownCommand => "未知命令",
            error.ExtraArgument => "多余的命令参数",
            error.InvalidOption => "该命令不支持此选项",
        };
        try ctx.err.print("参数错误：{s}\n{s}", .{ reason, usage });
        return 2;
    };
    if (options.help) {
        try ctx.out.writeAll(usage);
        return 0;
    }
    if (options.version) {
        try ctx.out.writeAll("zig_learning 0.0.0 (Zig 0.17.0; course 1)\n");
        return 0;
    }
    return dispatch(ctx, options) catch |err| switch (err) {
        error.Diagnosed => 2,
        else => return err,
    };
}

fn dispatch(ctx: Context, options: Options) !u8 {
    if (options.command == .init) {
        const path = options.positional orelse "zig-exercises";
        try workspace.initialize(ctx, path);
        try ctx.out.print("已初始化 {s}：36 道练习。\n本地代码将直接运行，不是沙箱；只运行你信任的代码。\n用外部编辑器修改 exercises 下的文件，然后运行 zig_learning watch --path \"{s}\"。\n", .{ path, path });
        return 0;
    }
    const requested: ?usize = if (options.positional) |id| progress.find(id) orelse {
        try ctx.err.print("参数错误：未知题号 {s}。\n{s}", .{ id, usage });
        return 2;
    } else null;
    var ws = try workspace.open(ctx, options.path orelse ".");
    defer ws.deinit(ctx);
    var state = try progress.load(ctx, ws.dir);
    if (options.command == .list) {
        var count: usize = 0;
        for (catalog.exercises, 0..) |exercise, index| {
            const status = try state.status(ctx, ws.dir, index);
            if (status == .passed) count += 1;
            const label = switch (status) {
                .pending => "未完成",
                .passed => "已通过",
                .modified => "已修改",
                .missing => "文件缺失",
            };
            try ctx.out.print("{s}  {s}  [{s}]  {s}\n", .{ exercise.id, exercise.title, exercise.chapter, label });
        }
        try ctx.out.print("有效进度：{d}/36\n", .{count});
        return 0;
    }
    if (options.command == .hint) {
        const index = requested orelse (try summarize(ctx, &ws, &state)).first orelse return complete(ctx);
        const exercise = catalog.exercises[index];
        try ctx.out.print("{s}：{s}\n目标：{s}\n", .{ exercise.id, exercise.title, exercise.objective });
        for (exercise.hints[0 .. options.level orelse 1], 1..) |hint, level| {
            try ctx.out.print("提示 {d}：{s}\n", .{ level, hint });
        }
        return 0;
    }
    var grader = try runner.Runner.init(ctx, options.zig orelse "zig");
    defer grader.deinit(ctx);
    switch (options.command) {
        .run => {
            const index = requested orelse (try summarize(ctx, &ws, &state)).first orelse return complete(ctx);
            const result = grader.run(ctx, &ws, &state, index) catch |err| switch (err) {
                error.ExerciseMissing => return missing(ctx, index),
                else => return err,
            };
            return if (result == .passed) 0 else 1;
        },
        .verify => {
            var failed = false;
            for (0..catalog.exercises.len) |index| {
                const result = grader.run(ctx, &ws, &state, index) catch |err| switch (err) {
                    error.ExerciseMissing => return missing(ctx, index),
                    else => return err,
                };
                if (result != .passed) failed = true;
            }
            const summary = try summarize(ctx, &ws, &state);
            try ctx.out.print("检查完成，有效进度：{d}/36\n", .{summary.count});
            return if (failed) 1 else 0;
        },
        .watch => return watch(ctx, &ws, &state, &grader),
        else => unreachable,
    }
}

const Summary = struct { count: usize = 0, first: ?usize = null };
fn summarize(ctx: Context, ws: *const workspace.Workspace, state: *const progress.State) !Summary {
    var summary: Summary = .{};
    for (0..catalog.exercises.len) |index| {
        if (try state.status(ctx, ws.dir, index) == .passed) {
            summary.count += 1;
        } else if (summary.first == null) summary.first = index;
    }
    return summary;
}

fn complete(ctx: Context) !u8 {
    try ctx.out.writeAll("全部 36 道练习已完成\n");
    return 0;
}

fn missing(ctx: Context, index: usize) !u8 {
    try ctx.err.print("练习文件缺失：exercises/{s}.zig\n", .{catalog.exercises[index].id});
    return 2;
}

fn watch(ctx: Context, ws: *const workspace.Workspace, state: *progress.State, grader: *runner.Runner) !u8 {
    try ctx.out.writeAll("自动检查：用外部编辑器保存文件；另一个终端运行 hint 查看提示。Ctrl+C 退出。\n");
    while (true) {
        const summary = try summarize(ctx, ws, state);
        try ctx.out.print("有效进度：{d}/36\n", .{summary.count});
        const index = summary.first orelse return complete(ctx);
        var missing_announced = false;
        while (true) {
            const snapshot = try runner.readSource(ctx, ws, index);
            defer if (snapshot) |source| ctx.allocator.free(source);
            if (snapshot != null) {
                missing_announced = false;
                const result = grader.run(ctx, ws, state, index) catch |err| switch (err) {
                    error.ExerciseMissing => continue,
                    else => return err,
                };
                if (result == .passed) break;
                if (result == .changed) continue;
            } else if (!missing_announced) {
                try ctx.out.print("练习文件缺失：exercises/{s}.zig；等待重建，不会恢复模板。\n", .{catalog.exercises[index].id});
                missing_announced = true;
            }
            try ctx.out.writeAll("等待文件内容变化（每 500ms 检查）……\n");
            try ctx.out.flush();
            while (true) {
                try ctx.io.sleep(.fromMilliseconds(500), .awake);
                const current = try runner.readSource(ctx, ws, index);
                defer if (current) |source| ctx.allocator.free(source);
                const same = if (snapshot) |old| if (current) |now| std.mem.eql(u8, old, now) else false else current == null;
                if (!same) break;
            }
        }
    }
}

test "参数错误不会被解释成另一条命令" {
    try std.testing.expectError(error.DuplicateOption, parse(&.{ "run", "--path", "a", "--path", "b" }));
    try std.testing.expectError(error.MissingValue, parse(&.{ "run", "--zig" }));
    try std.testing.expectError(error.InvalidOption, parse(&.{ "list", "--zig", "zig" }));
    try std.testing.expectError(error.InvalidOption, parse(&.{ "init", "--path", "a" }));
    try std.testing.expectError(error.InvalidLevel, parse(&.{ "hint", "--level", "0" }));
    try std.testing.expectError(error.UnknownCommand, parse(&.{"unknown"}));
    try std.testing.expectError(error.ExtraArgument, parse(&.{ "run", "01_values", "02_variables" }));
}

test "选项在命令前后保持同一含义" {
    const before = try parse(&.{ "--path", "中文 路径", "--zig", "./zig", "run", "01_values" });
    const after = try parse(&.{ "run", "01_values", "--path", "中文 路径", "--zig", "./zig" });
    try std.testing.expectEqual(before.command, after.command);
    try std.testing.expectEqualStrings(before.path.?, after.path.?);
    try std.testing.expectEqualStrings(before.zig.?, after.zig.?);
    try std.testing.expectEqualStrings(before.positional.?, after.positional.?);
}
