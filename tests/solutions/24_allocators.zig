//! 第 24 题参考解：分配器。

const std = @import("std");

pub fn copy(allocator: std.mem.Allocator, input: []const u8) std.mem.Allocator.Error![]u8 {
    return allocator.dupe(u8, input);
}
