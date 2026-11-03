//! 第 12 题：函数与边界值
//! 章节：控制流
//!
//! 目标：实现 clamp(value, lo, hi)，把 value 限制在闭区间 [lo, hi] 内。题目保证 lo <= hi。
//!
//! 前置知识：
//! - 低于下限时应返回下限 lo，高于上限时应返回上限 hi。
//! - 位于区间内（包括等于 lo 或 hi）时返回原值。
//!
//! 需要修改：低于下限分支的返回值。
//!
//! 运行命令：zig_learning run 12_functions

const std = @import("std");

pub fn clamp(value: i32, lo: i32, hi: i32) i32 {
    if (value < lo) {
        return hi;
    }
    if (value > hi) {
        return hi;
    }
    return value;
}

test "低于下限时返回下限" {
    try std.testing.expectEqual(@as(i32, 0), clamp(-1, 0, 10));
}
