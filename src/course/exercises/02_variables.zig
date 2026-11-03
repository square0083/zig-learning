//! 第 02 题：可变变量
//! 章节：基础
//!
//! 目标：让 count() 从 1 开始，把同一个变量修改两次，最后返回 3。
//!
//! 前置知识：
//! - `const` 声明的名字只能绑定一次，之后不能重新赋值。
//! - `var` 声明的变量可以重新赋值，并且需要显式写类型或让编译器推断。
//!
//! 需要修改：count 中保存计数的绑定声明。
//!
//! 运行命令：zig_learning run 02_variables

const std = @import("std");

pub fn count() u8 {
    const value: u8 = 1;
    value += 1;
    value += 1;
    return value;
}

test "count 依次加一后返回 3" {
    try std.testing.expectEqual(@as(u8, 3), count());
}
