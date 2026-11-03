//! 第 32 题：位运算（数据处理）
//!
//! 目标：实现 setBit，把 u8 的第 bit 位（0 是最低位，7 是最高位）设为 1，其他位保持不变。
//! 前置知识：位移运算 <<、按位或 |、u3 作为 u8 的位移量类型。
//! 需要修改：目前的位移数被写成了 bit / 2，置位的位置不对。
//! 运行：zig_learning run 32_bits

pub fn setBit(value: u8, bit: u3) u8 {
    const shift: u3 = bit / 2;
    return value | (@as(u8, 1) << shift);
}
