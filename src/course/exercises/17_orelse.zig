//! 第 17 题：orelse（可选值与错误）
//!
//! 目标：实现 orDefault，值为 null 时返回 fallback，否则返回原值；合法的 0 不能被替换。
//! 前置知识：orelse 运算符用于展开可选值并提供默认值。
//! 需要修改：目前把值为 0 的情况也当成了缺失。
//! 运行：zig_learning run 17_orelse

pub fn orDefault(value: ?i32, fallback: i32) i32 {
    const present = value orelse fallback;
    if (present == 0) return fallback;
    return present;
}
