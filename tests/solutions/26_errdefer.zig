const std = @import("std");

pub const Pair = struct {
    first: []u8,
    second: []u8,
};

pub fn makePair(allocator: std.mem.Allocator, a: []const u8, b: []const u8) std.mem.Allocator.Error!Pair {
    const first = try allocator.dupe(u8, a);
    errdefer allocator.free(first);
    const second = try allocator.dupe(u8, b);
    return .{ .first = first, .second = second };
}
