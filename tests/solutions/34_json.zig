const std = @import("std");

pub const Config = struct {
    name: []const u8,
    retries: u8,
};

pub fn parse(allocator: std.mem.Allocator, text: []const u8) std.json.ParseError(std.json.Scanner)!std.json.Parsed(Config) {
    return std.json.parseFromSlice(Config, allocator, text, .{ .allocate = .alloc_always });
}
