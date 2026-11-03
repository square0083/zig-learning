//! 学习进度：严格读取、有效状态计算和原子保存。
//!
//! 进度文件固定为工作区下的 `.zig-learning/progress.json`，课程题号使用
//! `catalog.zig` 的顺序。记录使用定长数组保存，不引入哈希表。

const std = @import("std");
const context_mod = @import("context.zig");
const catalog = @import("course/catalog.zig");

const Context = context_mod.Context;

const progress_version: u32 = 1;
const course_version: u32 = 1;
const progress_dir_path = ".zig-learning";
const progress_file_name = "progress.json";
const progress_path = progress_dir_path ++ "/" ++ progress_file_name;

comptime {
    std.debug.assert(catalog.exercises.len == 36);
}

pub const State = struct {
    /// 每道题的源码 SHA-256；索引对应 `catalog.exercises` 的顺序。
    /// `null` 表示该题没有有效的通过记录。
    passed: [36]?[64]u8 = @splat(null),

    pub fn record(self: *State, index: usize, hash: ?[64]u8) void {
        std.debug.assert(index < self.passed.len);
        self.passed[index] = hash;
    }

    pub fn save(self: *const State, ctx: Context, dir: std.Io.Dir) !void {
        const SaveEntry = struct {
            id: []const u8,
            source_hash: []const u8,
        };
        const SaveFile = struct {
            version: u32,
            course_version: u32,
            passed: []const SaveEntry,
        };

        var entries: [36]SaveEntry = undefined;
        var count: usize = 0;
        for (0..self.passed.len) |index| {
            if (self.passed[index] == null) continue;
            entries[count] = .{
                .id = catalog.exercises[index].id,
                .source_hash = &self.passed[index].?,
            };
            count += 1;
        }

        const document = SaveFile{
            .version = progress_version,
            .course_version = course_version,
            .passed = entries[0..count],
        };

        var progress_dir = dir.openDir(ctx.io, progress_dir_path, .{}) catch |err|
            return diagnose(ctx, progress_path, err);
        defer progress_dir.close(ctx.io);

        var atomic_file = progress_dir.createFileAtomic(ctx.io, progress_file_name, .{
            .replace = true,
        }) catch |err| return diagnose(ctx, progress_path, err);
        defer atomic_file.deinit(ctx.io);

        var write_buffer: [1024]u8 = undefined;
        var file_writer = atomic_file.file.writer(ctx.io, &write_buffer);

        std.json.Stringify.value(document, .{}, &file_writer.interface) catch |err|
            return diagnose(ctx, progress_path, err);
        file_writer.interface.flush() catch |err| return diagnose(ctx, progress_path, err);
        atomic_file.replace(ctx.io) catch |err| return diagnose(ctx, progress_path, err);
    }

    pub fn status(self: *const State, ctx: Context, dir: std.Io.Dir, index: usize) !Status {
        if (index >= catalog.exercises.len) {
            return diagnose(ctx, "exercises", error.IndexOutOfBounds);
        }

        var path_buffer: [128]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buffer, "exercises/{s}.zig", .{
            catalog.exercises[index].id,
        }) catch |err| return diagnose(ctx, catalog.exercises[index].id, err);

        const source = dir.readFileAlloc(
            ctx.io,
            path,
            ctx.allocator,
            .unlimited,
        ) catch |err| switch (err) {
            error.FileNotFound => return .missing,
            else => return diagnose(ctx, path, err),
        };
        defer ctx.allocator.free(source);

        const expected = self.passed[index] orelse return .pending;
        const actual = sourceHash(source);
        return if (std.mem.eql(u8, &expected, &actual)) .passed else .modified;
    }
};

pub const Status = enum {
    pending,
    passed,
    modified,
    missing,
};

// 标准 JSON 整数解析允许数字字符串和整数值浮点数；进度版本不做这种隐式转换。
const StrictVersion = struct {
    value: u32,

    pub fn jsonParse(_: std.mem.Allocator, source: anytype, _: std.json.ParseOptions) std.json.ParseError(@TypeOf(source.*))!@This() {
        const token = try source.next();
        const number = switch (token) {
            .number => |text| text,
            else => return error.UnexpectedToken,
        };
        for (number) |byte| {
            if (byte < '0' or byte > '9') return error.InvalidNumber;
        }
        return .{ .value = std.fmt.parseInt(u32, number, 10) catch return error.InvalidNumber };
    }
};

pub fn load(ctx: Context, dir: std.Io.Dir) !State {
    const data = dir.readFileAlloc(
        ctx.io,
        progress_path,
        ctx.allocator,
        .unlimited,
    ) catch |err| return diagnose(ctx, progress_path, err);
    defer ctx.allocator.free(data);

    const RawEntry = struct {
        id: []const u8,
        source_hash: []const u8,
    };
    const RawProgress = struct {
        version: StrictVersion,
        course_version: StrictVersion,
        passed: []const RawEntry,
    };

    const parsed = std.json.parseFromSlice(RawProgress, ctx.allocator, data, .{}) catch |err|
        return invalid(ctx, progress_path, @errorName(err));
    defer parsed.deinit();

    if (parsed.value.version.value != progress_version) {
        return invalid(ctx, progress_path, "version 不受支持");
    }
    if (parsed.value.course_version.value != course_version) {
        return invalid(ctx, progress_path, "course_version 不受支持");
    }

    var state: State = .{};
    for (parsed.value.passed) |entry| {
        const index = find(entry.id) orelse
            return invalid(ctx, progress_path, "未知题号");
        if (state.passed[index] != null) {
            return invalid(ctx, progress_path, "题号重复");
        }
        const hash = parseHash(entry.source_hash) orelse
            return invalid(ctx, progress_path, "源码哈希格式无效");
        state.passed[index] = hash;
    }

    return state;
}

pub fn sourceHash(source: []const u8) [64]u8 {
    var digest: [32]u8 = undefined;
    std.crypto.hash.sha2.Sha256.hash(source, &digest, .{});
    return std.fmt.bytesToHex(digest, .lower);
}

pub fn find(id: []const u8) ?usize {
    for (catalog.exercises, 0..) |exercise, index| {
        if (std.mem.eql(u8, exercise.id, id)) return index;
    }
    return null;
}

fn parseHash(text: []const u8) ?[64]u8 {
    if (text.len != 64) return null;
    for (text) |byte| {
        const valid = (byte >= '0' and byte <= '9') or
            (byte >= 'a' and byte <= 'f');
        if (!valid) return null;
    }
    var hash: [64]u8 = undefined;
    @memcpy(&hash, text);
    return hash;
}

fn diagnose(ctx: Context, path: []const u8, err: anyerror) error{Diagnosed} {
    ctx.err.print("无法访问 {s}：{s}\n", .{ path, @errorName(err) }) catch {};
    return error.Diagnosed;
}

fn invalid(ctx: Context, path: []const u8, reason: []const u8) error{Diagnosed} {
    ctx.err.print("进度文件 {s} 无效：{s}\n", .{ path, reason }) catch {};
    return error.Diagnosed;
}

const TestEnv = struct {
    environ: std.process.Environ.Map,
    sink_buffer: [1024]u8 = undefined,
    sink: std.Io.Writer.Discarding,

    fn init() TestEnv {
        return .{
            .environ = std.process.Environ.Map.init(std.testing.allocator),
            .sink = undefined,
        };
    }

    fn context(self: *TestEnv) Context {
        self.sink = .init(&self.sink_buffer);
        return .{
            .allocator = std.testing.allocator,
            .io = std.testing.io,
            .environ = &self.environ,
            .out = &self.sink.writer,
            .err = &self.sink.writer,
        };
    }

    fn deinit(self: *TestEnv) void {
        self.environ.deinit();
    }
};

fn writeProgress(dir: std.Io.Dir, text: []const u8) !void {
    try dir.createDirPath(std.testing.io, ".zig-learning");
    try dir.writeFile(std.testing.io, .{
        .sub_path = progress_path,
        .data = text,
    });
}

fn writeOneEntry(
    buffer: []u8,
    id: []const u8,
    hash_text: []const u8,
    version: u32,
    course_version_value: u32,
) ![]const u8 {
    return std.fmt.bufPrint(
        buffer,
        "{{\"version\":{d},\"course_version\":{d},\"passed\":[{{\"id\":\"{s}\",\"source_hash\":\"{s}\"}}]}}",
        .{ version, course_version_value, id, hash_text },
    );
}

fn testExercisePath(buffer: []u8, index: usize) ![]const u8 {
    return std.fmt.bufPrint(buffer, "exercises/{s}.zig", .{
        catalog.exercises[index].id,
    });
}

fn readProgress(dir: std.Io.Dir) ![]u8 {
    return dir.readFileAlloc(
        std.testing.io,
        progress_path,
        std.testing.allocator,
        .unlimited,
    );
}

test "sourceHash 产生固定的小写 SHA-256" {
    const actual = sourceHash("hello");
    try std.testing.expectEqualStrings(
        "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824",
        actual[0..],
    );
}

test "缺少进度文件时报告诊断错误" {
    var env: TestEnv = .init();
    defer env.deinit();
    const ctx = env.context();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));
}

test "无效 JSON 被拒绝且不改写文件" {
    var env: TestEnv = .init();
    defer env.deinit();
    const ctx = env.context();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const bad = "{\"version\":1,";
    try writeProgress(tmp.dir, bad);

    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));

    const after = try readProgress(tmp.dir);
    defer std.testing.allocator.free(after);
    try std.testing.expectEqualStrings(bad, after);
}

test "重复题号被拒绝" {
    var env: TestEnv = .init();
    defer env.deinit();
    const ctx = env.context();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const id = catalog.exercises[0].id;
    var hash_text: [64]u8 = undefined;
    @memset(&hash_text, 'a');
    var buffer: [512]u8 = undefined;
    const text = try std.fmt.bufPrint(
        &buffer,
        "{{\"version\":1,\"course_version\":1,\"passed\":[{{\"id\":\"{s}\",\"source_hash\":\"{s}\"}},{{\"id\":\"{s}\",\"source_hash\":\"{s}\"}}]}}",
        .{ id, hash_text[0..], id, hash_text[0..] },
    );
    try writeProgress(tmp.dir, text);

    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));
}

test "未知题号被拒绝" {
    var env: TestEnv = .init();
    defer env.deinit();
    const ctx = env.context();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    var hash_text: [64]u8 = undefined;
    @memset(&hash_text, 'a');
    var buffer: [256]u8 = undefined;
    const text = try writeOneEntry(&buffer, "99_unknown", hash_text[0..], 1, 1);
    try writeProgress(tmp.dir, text);

    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));
}

test "版本、课程版本和哈希格式被严格校验" {
    var env: TestEnv = .init();
    defer env.deinit();
    const ctx = env.context();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const id = catalog.exercises[0].id;
    var hash_text: [64]u8 = undefined;
    @memset(&hash_text, 'a');
    var buffer: [512]u8 = undefined;

    try writeProgress(tmp.dir, try writeOneEntry(&buffer, id, hash_text[0..], 2, 1));
    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));

    try writeProgress(tmp.dir, try writeOneEntry(&buffer, id, hash_text[0..], 1, 2));
    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));

    try writeProgress(tmp.dir, try writeOneEntry(&buffer, id, hash_text[0 .. hash_text.len - 1], 1, 1));
    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));

    @memset(&hash_text, 'A');
    try writeProgress(tmp.dir, try writeOneEntry(&buffer, id, hash_text[0..], 1, 1));
    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));
}

test "未知字段和缺失字段被拒绝" {
    var env: TestEnv = .init();
    defer env.deinit();
    const ctx = env.context();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const with_extra =
        "{\"version\":1,\"course_version\":1,\"passed\":[],\"extra\":true}";
    try writeProgress(tmp.dir, with_extra);
    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));

    var buffer: [256]u8 = undefined;
    const with_missing = try std.fmt.bufPrint(
        &buffer,
        "{{\"version\":1,\"course_version\":1,\"passed\":[{{\"id\":\"{s}\"}}]}}",
        .{catalog.exercises[0].id},
    );
    try writeProgress(tmp.dir, with_missing);
    try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));
    const invalid_documents = [_][]const u8{
        "{\"version\":\"1\",\"course_version\":1,\"passed\":[]}",
        "{\"version\":1.0,\"course_version\":1,\"passed\":[]}",
        "{\"version\":1,\"course_version\":\"1\",\"passed\":[]}",
        "{\"version\":1,\"course_version\":1e0,\"passed\":[]}",
        "{\"version\":1,\"version\":1,\"course_version\":1,\"passed\":[]}",
    };
    for (invalid_documents) |document| {
        try writeProgress(tmp.dir, document);
        try std.testing.expectError(error.Diagnosed, load(ctx, tmp.dir));
        const unchanged = try readProgress(tmp.dir);
        defer std.testing.allocator.free(unchanged);
        try std.testing.expectEqualStrings(document, unchanged);
    }
}

test "源码改变后记录失效，缺失文件和未记录题目状态正确" {
    var env: TestEnv = .init();
    defer env.deinit();
    const ctx = env.context();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const id = catalog.exercises[0].id;
    var path_buffer: [128]u8 = undefined;
    const path = try testExercisePath(&path_buffer, 0);
    try tmp.dir.createDirPath(std.testing.io, "exercises");
    try tmp.dir.writeFile(std.testing.io, .{
        .sub_path = path,
        .data = "hello",
    });
    try tmp.dir.writeFile(std.testing.io, .{
        .sub_path = "exercises/02_variables.zig",
        .data = "",
    });

    const hash = sourceHash("hello");
    var buffer: [512]u8 = undefined;
    const text = try writeOneEntry(&buffer, id, hash[0..], 1, 1);
    try writeProgress(tmp.dir, text);

    const loaded = try load(ctx, tmp.dir);
    try std.testing.expectEqual(Status.passed, try loaded.status(ctx, tmp.dir, 0));
    try std.testing.expectEqual(Status.pending, try loaded.status(ctx, tmp.dir, 1));
    try std.testing.expectEqual(Status.missing, try loaded.status(ctx, tmp.dir, 2));

    try tmp.dir.writeFile(std.testing.io, .{
        .sub_path = path,
        .data = "hello!",
    });
    try std.testing.expectEqual(Status.modified, try loaded.status(ctx, tmp.dir, 0));
}

test "失败结果撤销旧通过记录" {
    var env: TestEnv = .init();
    defer env.deinit();
    const ctx = env.context();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();

    const source = "hello";
    var path_buffer: [128]u8 = undefined;
    const path = try testExercisePath(&path_buffer, 0);
    try tmp.dir.createDirPath(std.testing.io, "exercises");
    try tmp.dir.writeFile(std.testing.io, .{
        .sub_path = path,
        .data = source,
    });

    try tmp.dir.createDirPath(std.testing.io, ".zig-learning");
    var state: State = .{};
    state.record(0, sourceHash(source));
    try state.save(ctx, tmp.dir);

    var loaded = try load(ctx, tmp.dir);
    try std.testing.expectEqual(Status.passed, try loaded.status(ctx, tmp.dir, 0));

    loaded.record(0, null);
    try loaded.save(ctx, tmp.dir);

    const reloaded = try load(ctx, tmp.dir);
    try std.testing.expect(reloaded.passed[0] == null);
    try std.testing.expectEqual(Status.pending, try reloaded.status(ctx, tmp.dir, 0));
}

test "保存后重载保持记录与课程顺序" {
    var env: TestEnv = .init();
    defer env.deinit();
    const ctx = env.context();

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    try tmp.dir.createDirPath(std.testing.io, ".zig-learning");

    var state: State = .{};
    const last_hash = sourceHash("last");
    const first_hash = sourceHash("first");
    state.record(35, last_hash);
    state.record(0, first_hash);
    try state.save(ctx, tmp.dir);

    const raw = try readProgress(tmp.dir);
    defer std.testing.allocator.free(raw);
    const first_id = std.mem.indexOf(u8, raw, catalog.exercises[0].id).?;
    const last_id = std.mem.indexOf(u8, raw, catalog.exercises[35].id).?;
    try std.testing.expect(first_id < last_id);

    const loaded = try load(ctx, tmp.dir);
    const actual_first = loaded.passed[0].?;
    const actual_last = loaded.passed[35].?;
    try std.testing.expectEqualSlices(u8, first_hash[0..], actual_first[0..]);
    try std.testing.expectEqualSlices(u8, last_hash[0..], actual_last[0..]);
    try std.testing.expect(loaded.passed[1] == null);
}
