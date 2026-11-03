const std = @import("std");
const exercise = @import("exercise");

fn roundTrip(allocator: std.mem.Allocator, a: []const u8, b: []const u8) !void {
    const pair = try exercise.makePair(allocator, a, b);
    defer allocator.free(pair.first);
    defer allocator.free(pair.second);

    try std.testing.expectEqualStrings(a, pair.first);
    try std.testing.expectEqualStrings(b, pair.second);
    try std.testing.expect(@intFromPtr(pair.first.ptr) != @intFromPtr(a.ptr));
    try std.testing.expect(@intFromPtr(pair.second.ptr) != @intFromPtr(b.ptr));
}

test "复制两个字符串" {
    try roundTrip(std.testing.allocator, "hello", "zig");
    try roundTrip(std.testing.allocator, "longer first string", "x");
}

test "复制而不是借用输入" {
    var first_input = [_]u8{ 'a', 'b' };
    const pair = try exercise.makePair(std.testing.allocator, &first_input, "z");
    defer std.testing.allocator.free(pair.first);
    defer std.testing.allocator.free(pair.second);

    @memset(&first_input, 'x');
    try std.testing.expectEqualStrings("ab", pair.first);
}

test "第二次分配失败时释放第一次分配" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, roundTrip, .{ "first", "second" });
}

test "空字符串的所有权可释放" {
    const pair = try exercise.makePair(std.testing.allocator, "", "");
    defer std.testing.allocator.free(pair.first);
    defer std.testing.allocator.free(pair.second);
    try std.testing.expectEqualStrings("", pair.first);
    try std.testing.expectEqualStrings("", pair.second);
}
