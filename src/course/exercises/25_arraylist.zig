//! 第 25 题：ArrayList（内存与容器）
//!
//! 目标：实现 evens，保序返回输入中所有偶数组成的新切片；空输入返回空切片。
//! 返回的切片由调用者负责释放（allocator.free），函数内部用 ArrayList 收集结果。
//! 前置知识：std.ArrayList(T) 的 `.empty` 初始值、append(allocator, value)、
//! toOwnedSlice(allocator)、deinit(allocator)。
//! 需要修改：目前的筛选条件写反了，保留下来的是奇数。
//! 运行：zig_learning run 25_arraylist

const std = @import("std");

pub fn evens(allocator: std.mem.Allocator, input: []const i32) std.mem.Allocator.Error![]i32 {
    var list = std.ArrayList(i32).empty;
    errdefer list.deinit(allocator);

    for (input) |value| {
        if (@mod(value, 2) != 0) {
            try list.append(allocator, value);
        }
    }

    return try list.toOwnedSlice(allocator);
}
