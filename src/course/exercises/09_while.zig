//! 第 09 题：while 循环
//! 章节：控制流
//!
//! 目标：实现 factorial(n)，返回 n 的阶乘。题目保证 n <= 20。
//!
//! 前置知识：
//! - 0 的阶乘是 1，1 的阶乘也是 1。
//! - 累乘的初始值必须是 1；如果从 0 开始，结果会一直是 0。
//!
//! 需要修改：result 的初始值。
//!
//! 运行命令：zig_learning run 09_while

const std = @import("std");

pub fn factorial(n: u8) u64 {
    var result: u64 = 0;
    var i: u8 = 2;
    while (i <= n) : (i += 1) {
        result *= i;
    }
    return result;
}

test "5 的阶乘是 120" {
    try std.testing.expectEqual(@as(u64, 120), factorial(5));
}
