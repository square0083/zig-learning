//! 第 19 题：try（可选值与错误）
//!
//! 目标：实现 parsePairSum，把两个十进制字符串分别解析为 u8，扩宽为 u16 后求和。
//! 前置知识：std.fmt.parseInt、错误联合返回类型、try 把错误向上传播。
//! 需要修改：第一个 parseInt 调用缺少 try，导致类型不匹配的编译错误。
//! 运行：zig_learning run 19_try

const std = @import("std");

pub fn parsePairSum(a: []const u8, b: []const u8) std.fmt.ParseIntError!u16 {
    const x: u8 = std.fmt.parseInt(u8, a, 10);
    const y = try std.fmt.parseInt(u8, b, 10);
    return @as(u16, x) + @as(u16, y);
}
