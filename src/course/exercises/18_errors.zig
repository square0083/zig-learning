//! 第 18 题：错误集（可选值与错误）
//!
//! 目标：实现 divide，整数除法；除数为 0 时返回 error.DivisionByZero。
//! 前置知识：错误集类型 error{...}!u32、return error.名字。
//! 需要修改：目前除数为 0 时返回 0，而不是返回错误。
//! 运行：zig_learning run 18_errors

pub fn divide(a: u32, b: u32) error{DivisionByZero}!u32 {
    if (b == 0) return 0;
    return a / b;
}
