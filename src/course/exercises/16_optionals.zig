//! 第 16 题：可选值（可选值与错误）
//!
//! 目标：实现 first，返回切片第一个元素；空切片返回 null。
//! 前置知识：可选类型 ?i32、null 的含义。
//! 需要修改：目前空切片返回 0，正确做法是返回 null。
//! 运行：zig_learning run 16_optionals

pub fn first(values: []const i32) ?i32 {
    if (values.len == 0) return 0;
    return values[0];
}
