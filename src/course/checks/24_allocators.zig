const std = @import("std");
const exercise = @import("exercise");

test "returns an independent copy with the same contents" {
    var original = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    const copied = try exercise.copy(std.testing.allocator, &original);
    defer std.testing.allocator.free(copied);

    try std.testing.expectEqualSlices(u8, &original, copied);

    copied[0] = 'H';
    try std.testing.expectEqualStrings("hello", &original);
    try std.testing.expectEqualStrings("Hello", copied);
}

test "empty input produces a freeable empty slice" {
    const input: []const u8 = "";
    const copied = try exercise.copy(std.testing.allocator, input);
    defer std.testing.allocator.free(copied);

    try std.testing.expectEqual(@as(usize, 0), copied.len);
}

test "copy of a larger buffer keeps every byte" {
    const input = "Zig 学习笔记";
    const copied = try exercise.copy(std.testing.allocator, input);
    defer std.testing.allocator.free(copied);

    try std.testing.expectEqualSlices(u8, input, copied);
}
