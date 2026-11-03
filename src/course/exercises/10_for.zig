//! 第 10 题：for 循环与条件统计
//! 章节：控制流
//!
//! 目标：实现 countEven(values)，统计切片中偶数的个数（包括 0 和负偶数）。
//!
//! 前置知识：
//! - `for (values) |v|` 可以依次访问切片中的每个元素。
//! - 有符号整数判断偶数用 `@mod(v, 2) == 0`，不要额外限制必须是正数。
//!
//! 需要修改：统计条件，使负偶数和 0 也被计入。
//!
//! 运行命令：zig_learning run 10_for

const std = @import("std");

pub fn countEven(values: []const i32) usize {
    var count: usize = 0;
    for (values) |value| {
        if (value > 0 and @mod(value, 2) == 0) {
            count += 1;
        }
    }
    return count;
}

test "-2 -1 0 3 4 中有 3 个偶数" {
    try std.testing.expectEqual(@as(usize, 3), countEven(&[_]i32{ -2, -1, 0, 3, 4 }));
}
