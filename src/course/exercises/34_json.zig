//! 第 34 题：JSON（数据处理）
//!
//! 目标：实现 parse，把 `{"name": "...", "retries": 数字}` 解析为 Config。
//! 返回的 std.json.Parsed(Config) 必须由调用者 deinit；
//! 其中的 name 字符串归 Parsed 所有，解析后修改输入缓冲区不能影响结果。
//! 前置知识：std.json.parseFromSlice、std.json.ParseOptions 的 allocate 选项。
//! 需要修改：目前使用默认的 .alloc_if_needed，名字会直接借用输入缓冲区。
//! 运行：zig_learning run 34_json

const std = @import("std");

pub const Config = struct {
    name: []const u8,
    retries: u8,
};

pub fn parse(allocator: std.mem.Allocator, text: []const u8) std.json.ParseError(std.json.Scanner)!std.json.Parsed(Config) {
    return std.json.parseFromSlice(Config, allocator, text, .{});
}
