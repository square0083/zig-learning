//! 第 05 题：数组遍历
//! 章节：基础
//!
//! 目标：实现 sum(values)，返回固定长度数组 [4]i32 中所有元素的和。
//!
//! 前置知识：
//! - `[4]i32` 是长度为 4 的数组类型，`values.len` 是编译期已知的长度。
//! - 用 `while` 遍历时必须让索引覆盖 0 到 len-1 的每个位置。
//!
//! 需要修改：循环结束条件，使最后一个元素也被累加。
//!
//! 运行命令：zig_learning run 05_arrays

const std = @import("std");

pub fn sum(values: [4]i32) i32 {
    var total: i32 = 0;
    var i: usize = 0;
    while (i < values.len - 1) : (i += 1) {
        total += values[i];
    }
    return total;
}

test "1 2 3 4 的和是 10" {
    try std.testing.expectEqual(@as(i32, 10), sum(.{ 1, 2, 3, 4 }));
}
