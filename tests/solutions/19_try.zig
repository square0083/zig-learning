//! 第 19 题参考解：try。

const std = @import("std");

pub fn parsePairSum(a: []const u8, b: []const u8) std.fmt.ParseIntError!u16 {
    const x = try std.fmt.parseInt(u8, a, 10);
    const y = try std.fmt.parseInt(u8, b, 10);
    return @as(u16, x) + @as(u16, y);
}
