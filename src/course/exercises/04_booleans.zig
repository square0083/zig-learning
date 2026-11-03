//! 第 04 题：布尔逻辑
//! 章节：基础
//!
//! 目标：实现 allowed(age, has_ticket)，只有年龄至少 18 且有票时才返回 true。
//!
//! 前置知识：
//! - bool 值可以用 `and`、`or`、`!` 组合。
//! - `and` 要求两边都为真；`or` 只要一边为真即可。
//!
//! 需要修改：allowed 中的逻辑运算符。
//!
//! 运行命令：zig_learning run 04_booleans

const std = @import("std");

pub fn allowed(age: u8, has_ticket: bool) bool {
    return age >= 18 or has_ticket;
}

test "17 岁即使有票也不能进入" {
    try std.testing.expect(!allowed(17, true));
}
