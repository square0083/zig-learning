//! 第 20 题：catch（可选值与错误）
//!
//! 目标：实现 parseOrZero，解析十进制 u8；文本非法或数值溢出时返回 0。
//! 前置知识：catch 运算符为错误提供兜底值。
//! 需要修改：目前解析失败时返回 255，应该返回 0。
//! 运行：zig_learning run 20_catch

const std = @import("std");

pub fn parseOrZero(text: []const u8) u8 {
    return std.fmt.parseInt(u8, text, 10) catch 255;
}
