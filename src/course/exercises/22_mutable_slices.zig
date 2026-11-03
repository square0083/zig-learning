//! 第 22 题：可变切片（指针与所有权）
//!
//! 目标：实现 reverse，原地反转字节切片的顺序。
//! 前置知识：可变切片 []u8、下标赋值、首尾成对交换。
//! 需要修改：循环的中间位置算错了，偶数长度时漏掉中央的那一对。
//! 运行：zig_learning run 22_mutable_slices

pub fn reverse(bytes: []u8) void {
    if (bytes.len < 2) return;
    const mid = (bytes.len - 1) / 2;
    var i: usize = 0;
    while (i < mid) : (i += 1) {
        const j = bytes.len - 1 - i;
        const tmp = bytes[i];
        bytes[i] = bytes[j];
        bytes[j] = tmp;
    }
}
