//! 第 29 题：编译期参数（编译期与泛型）
//!
//! 目标：实现 repeat，返回长度为 n、每个元素都是 value 的数组；n = 0 时返回零长数组。
//! 前置知识：数组长度必须是编译期已知值；comptime 函数参数。
//! 需要修改：n 目前是运行时参数，不能用作数组长度。
//! 运行：zig_learning run 29_comptime

pub fn repeat(n: usize, value: u8) [n]u8 {
    var bytes: [n]u8 = undefined;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        bytes[i] = value;
    }
    return bytes;
}
