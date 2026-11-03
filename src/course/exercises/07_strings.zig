//! 第 07 题：字符串与 UTF-8
//! 章节：基础
//!
//! 目标：让 greeting() 返回完整字符串 `你好，Zig！`。
//!
//! 前置知识：
//! - Zig 的字符串字面量是 UTF-8 字节切片，类型为 `[]const u8`。
//! - 字符串长度按字节计数，一个汉字通常占多个字节。
//!
//! 需要修改：greeting 返回的字符串内容（注意结尾的全角感叹号）。
//!
//! 运行命令：zig_learning run 07_strings

const std = @import("std");

pub fn greeting() []const u8 {
    return "你好，Zig";
}

test "greeting 返回完整问候语" {
    try std.testing.expectEqualStrings("你好，Zig！", greeting());
}
