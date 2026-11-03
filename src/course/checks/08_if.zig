const std = @import("std");
const exercise = @import("exercise");

test "max 返回较大的值" {
    try std.testing.expectEqual(@as(i32, 3), exercise.max(3, -5));
    try std.testing.expectEqual(@as(i32, 3), exercise.max(-5, 3));
    try std.testing.expectEqual(@as(i32, 7), exercise.max(7, 7));
    try std.testing.expectEqual(@as(i32, -2), exercise.max(-9, -2));
}
