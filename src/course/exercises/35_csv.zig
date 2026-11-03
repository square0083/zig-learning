//! 第 35 题：CSV 求和（综合练习）
//!
//! 目标：实现 sumCsv，把逗号分隔的无符号十进制整数求和（u32）。
//! - 空文本或全空白返回 0；
//! - 每个字段去掉首尾空格、制表符、CR、LF 后再解析；
//! - 出现空字段、负数或非法字符返回 error.InvalidCharacter；
//! - 单个数字或累加结果超出 u32 返回 error.Overflow。
//!
//! 前置知识：splitScalar 保留空字段、tokenizeScalar 会跳过空字段、std.math.add。
//! 需要修改：目前用 tokenizeScalar 切分，像 "1,,2" 这样的空字段被跳过，不再报错。
//! 运行：zig_learning run 35_csv

const std = @import("std");

pub fn sumCsv(text: []const u8) error{ InvalidCharacter, Overflow }!u32 {
    if (std.mem.trim(u8, text, " \t\r\n").len == 0) return 0;

    var total: u32 = 0;
    var fields = std.mem.tokenizeScalar(u8, text, ',');
    while (fields.next()) |raw| {
        const field = std.mem.trim(u8, raw, " \t\r\n");
        if (field.len == 0) return error.InvalidCharacter;
        if (field[0] == '-') return error.InvalidCharacter;

        const value = std.fmt.parseInt(u32, field, 10) catch |err| switch (err) {
            error.InvalidCharacter => return error.InvalidCharacter,
            error.Overflow => return error.Overflow,
        };
        total = try std.math.add(u32, total, value);
    }
    return total;
}
