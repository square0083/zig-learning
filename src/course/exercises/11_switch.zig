//! 第 11 题：switch 与范围分支
//! 章节：控制流
//!
//! 目标：实现 isDigit(c)：当字节 c 是 ASCII 数字字符 '0' 到 '9' 时返回 true。
//!
//! 前置知识：
//! - `switch` 可以对整数使用范围分支，写法是 `'0'...'9'`。
//! - 字符字面量 '0'、'9' 在 Zig 中是 u8 值，分别对应 48 和 57。
//!
//! 需要修改：switch 范围分支的起点。
//!
//! 运行命令：zig_learning run 11_switch

const std = @import("std");

pub fn isDigit(c: u8) bool {
    return switch (c) {
        '1'...'9' => true,
        else => false,
    };
}

test "'9' 是数字字符" {
    try std.testing.expect(isDigit('9'));
}
