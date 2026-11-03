//! 第 28 题：切片边界（内存与容器）
//!
//! 目标：实现 at，返回 values[index]；索引非法时返回 error.OutOfBounds，绝不越界访问。
//! 前置知识：切片长度 values.len、边界检查、错误集合 error{OutOfBounds}。
//! 需要修改：当前的边界判断漏掉了 index 恰好等于 len 的情况。
//! 运行：zig_learning run 28_bounds

pub fn at(values: []const i32, index: usize) error{OutOfBounds}!i32 {
    if (index > values.len) return error.OutOfBounds;
    return values[index];
}
