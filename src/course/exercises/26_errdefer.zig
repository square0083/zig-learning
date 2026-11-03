//! 第 26 题：errdefer（内存与容器）
//!
//! 目标：实现 makePair，把两个字符串各复制一份放进 Pair 返回。
//! 成功后调用者分别 free(first) 和 free(second)；任意一次分配失败都不能泄漏。
//! 前置知识：errdefer 只在函数以错误返回时执行；allocator.dupe 复制字符串。
//! 需要修改：第二次分配失败时，第一次分配的内存会泄漏。
//! 运行：zig_learning run 26_errdefer

const std = @import("std");

pub const Pair = struct {
    first: []u8,
    second: []u8,
};

pub fn makePair(allocator: std.mem.Allocator, a: []const u8, b: []const u8) std.mem.Allocator.Error!Pair {
    const first = try allocator.dupe(u8, a);
    const second = try allocator.dupe(u8, b);
    return .{ .first = first, .second = second };
}
