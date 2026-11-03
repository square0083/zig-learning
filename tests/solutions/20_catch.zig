//! 第 20 题参考解：catch。

const std = @import("std");

pub fn parseOrZero(text: []const u8) u8 {
    return std.fmt.parseInt(u8, text, 10) catch 0;
}
