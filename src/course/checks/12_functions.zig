const std = @import("std");
const exercise = @import("exercise");

test "clamp 处理低于、位于和高于区间" {
    try std.testing.expectEqual(@as(i32, 0), exercise.clamp(-1, 0, 10));
    try std.testing.expectEqual(@as(i32, 5), exercise.clamp(5, 0, 10));
    try std.testing.expectEqual(@as(i32, 10), exercise.clamp(11, 0, 10));
    try std.testing.expectEqual(@as(i32, 0), exercise.clamp(0, 0, 10));
    try std.testing.expectEqual(@as(i32, 10), exercise.clamp(10, 0, 10));
}

test "clamp 在 lo 等于 hi 时返回该值" {
    try std.testing.expectEqual(@as(i32, 4), exercise.clamp(4, 4, 4));
    try std.testing.expectEqual(@as(i32, 4), exercise.clamp(-7, 4, 4));
    try std.testing.expectEqual(@as(i32, 4), exercise.clamp(9, 4, 4));
}
