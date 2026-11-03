const std = @import("std");
const exercise = @import("exercise");

test "重复词只计一次" {
    const words = [_][]const u8{ "a", "b", "a" };
    try std.testing.expectEqual(@as(usize, 2), try exercise.uniqueCount(std.testing.allocator, &words));
}

test "空输入" {
    const words: []const []const u8 = &.{};
    try std.testing.expectEqual(@as(usize, 0), try exercise.uniqueCount(std.testing.allocator, words));
}

test "全部不同" {
    const words = [_][]const u8{ "x", "y", "z" };
    try std.testing.expectEqual(@as(usize, 3), try exercise.uniqueCount(std.testing.allocator, &words));
}

test "全部相同" {
    const words = [_][]const u8{ "same", "same", "same", "same" };
    try std.testing.expectEqual(@as(usize, 1), try exercise.uniqueCount(std.testing.allocator, &words));
}

test "空字符串也是一项" {
    const words = [_][]const u8{ "", "a", "" };
    try std.testing.expectEqual(@as(usize, 2), try exercise.uniqueCount(std.testing.allocator, &words));
}
