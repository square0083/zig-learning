//! 第 24 题：分配器（内存与容器）
//!
//! 目标：实现 copy，用分配器返回 input 的一份独立副本，调用者负责释放。
//! 前置知识：std.mem.Allocator、allocator.dupe、切片的 const 限定。
//! 需要修改：目前直接返回借用的只读 input，类型与所有权都不正确。
//! 运行：zig_learning run 24_allocators

const std = @import("std");

pub fn copy(allocator: std.mem.Allocator, input: []const u8) std.mem.Allocator.Error![]u8 {
    return input;
}
