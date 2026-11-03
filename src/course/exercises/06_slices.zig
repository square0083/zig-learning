//! 第 06 题：切片
//! 章节：基础
//!
//! 目标：实现 sum(values)，返回任意长度只读切片 []const i32 中所有元素的和。
//!
//! 前置知识：
//! - 切片由指针和长度组成，长度在运行时确定，可以为 0。
//! - 合法的索引范围是 0 到 len-1，遍历应从索引 0 开始。
//!
//! 需要修改：循环的起始索引。
//!
//! 运行命令：zig_learning run 06_slices

const std = @import("std");

pub fn sum(values: []const i32) i32 {
    var total: i32 = 0;
    var i: usize = 1;
    while (i < values.len) : (i += 1) {
        total += values[i];
    }
    return total;
}

test "2 -1 4 的和是 5" {
    try std.testing.expectEqual(@as(i32, 5), sum(&[_]i32{ 2, -1, 4 }));
}
