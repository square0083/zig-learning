//! 第 01 题：值与返回值
//! 章节：基础
//!
//! 目标：让 answer() 返回 42。
//!
//! 前置知识：
//! - Zig 函数用 `fn` 声明，返回值类型写在参数列表之后。
//! - `return` 后面的表达式必须能转换为声明的返回类型。
//!
//! 需要修改：answer 函数返回的数值。
//!
//! 运行命令：zig_learning run 01_values
//! （在仓库中也可以使用：zig build run -- run 01_values）

const std = @import("std");

pub fn answer() u8 {
    return 41;
}

test "answer 返回 42" {
    try std.testing.expectEqual(@as(u8, 42), answer());
}
