//! 第 08 题：if 表达式
//! 章节：控制流
//!
//! 目标：实现 max(a, b)，返回两个 i32 中较大的一个。
//!
//! 前置知识：
//! - Zig 的 `if` 是表达式，可以产生值。
//! - 比较条件必须写对方向，`a < b` 表示 a 小于 b。
//!
//! 需要修改：max 中的比较方向。
//!
//! 运行命令：zig_learning run 08_if

const std = @import("std");

pub fn max(a: i32, b: i32) i32 {
    if (a < b) {
        return a;
    }
    return b;
}

test "max(3, -5) 返回 3" {
    try std.testing.expectEqual(@as(i32, 3), max(3, -5));
}
