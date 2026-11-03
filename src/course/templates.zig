//! 编译期内置的课程文件。
//!
//! 练习与检查模块以 `@embedFile` 读取，路径相对于本文件（也就是模
//! 块内的 `src/course/`），顺序与 `catalog.exercises` 完全一致。

const catalog = @import("catalog.zig");

const count = catalog.exercises.len;

/// 与课程顺序一致的学习者初始练习文件内容。
pub const starters: [count][]const u8 = blk: {
    var files: [count][]const u8 = undefined;
    for (catalog.exercises, 0..) |exercise, index| {
        files[index] = @embedFile("exercises/" ++ exercise.id ++ ".zig");
    }
    break :blk files;
};

/// 与课程顺序一致的独立检查模块内容。
pub const checks: [count][]const u8 = blk: {
    var files: [count][]const u8 = undefined;
    for (catalog.exercises, 0..) |exercise, index| {
        files[index] = @embedFile("checks/" ++ exercise.id ++ ".zig");
    }
    break :blk files;
};
