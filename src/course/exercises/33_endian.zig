//! 第 33 题：字节序（数据处理）
//!
//! 目标：实现 decodeLittle，把恰好 4 个字节按小端序解释为 u32；
//! 长度不是 4 时返回 error.InvalidLength。
//! 前置知识：std.mem.readInt(T, *const [N]u8, endian)、小端与大端的区别。
//! 需要修改：当前按大端序读取，字节顺序反了。
//! 运行：zig_learning run 33_endian

const std = @import("std");

pub fn decodeLittle(bytes: []const u8) error{InvalidLength}!u32 {
    if (bytes.len != 4) return error.InvalidLength;
    return std.mem.readInt(u32, bytes[0..4], .big);
}
