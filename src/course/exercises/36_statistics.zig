//! 第 36 题：统计汇总（综合练习）
//!
//! 目标：实现 summarize，逐行解析有符号十进制 i32，返回行数、总和、最小值、最大值。
//! - 每行先去掉首尾空格、制表符、CR；空行跳过；
//! - 没有任何数据时 count = 0、total = 0、min 和 max 都是 null；
//! - 非法字符返回 error.InvalidCharacter，数值越界或累加溢出返回 error.Overflow，
//!   出错时不返回部分结果。
//!
//! 前置知识：splitScalar 按行切分、可选类型、std.math.add。
//! 需要修改：第一条非空数据把 min 初始化为 0，导致全正数数据的最小值错误。
//! 运行：zig_learning run 36_statistics

const std = @import("std");

pub const Stats = struct {
    count: usize,
    total: i64,
    min: ?i32,
    max: ?i32,
};

pub fn summarize(text: []const u8) error{ InvalidCharacter, Overflow }!Stats {
    var count: usize = 0;
    var total: i64 = 0;
    var min: ?i32 = null;
    var max: ?i32 = null;

    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0) continue;

        const value = std.fmt.parseInt(i32, line, 10) catch |err| switch (err) {
            error.InvalidCharacter => return error.InvalidCharacter,
            error.Overflow => return error.Overflow,
        };

        count += 1;
        total = try std.math.add(i64, total, @as(i64, value));
        min = if (min) |current| @min(current, value) else @min(@as(i32, 0), value);
        max = if (max) |current| @max(current, value) else value;
    }

    return .{ .count = count, .total = total, .min = min, .max = max };
}
