//! 第 03 题：整数宽度与溢出
//! 章节：基础
//!
//! 目标：实现 addWide(a, b)，返回两个 u8 之和，结果类型为 u16。
//!
//! 前置知识：
//! - Zig 的整数类型带有位宽，u8 的运算结果仍然是 u8。
//! - 两个 u8 在 u8 中相加可能溢出；应先把操作数扩宽到 u16 再相加。
//!
//! 需要修改：addWide 中相加的顺序。
//!
//! 运行命令：zig_learning run 03_integers

const std = @import("std");

pub fn addWide(a: u8, b: u8) u16 {
    return @as(u16, a + b);
}

test "255 加 255 等于 510" {
    try std.testing.expectEqual(@as(u16, 510), addWide(255, 255));
}
