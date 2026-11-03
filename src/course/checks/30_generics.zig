const std = @import("std");
const exercise = @import("exercise");

test "i32 比较" {
    try std.testing.expectEqual(@as(i32, 2), exercise.max(i32, -3, 2));
    try std.testing.expectEqual(@as(i32, -3), exercise.max(i32, -3, -7));
    try std.testing.expectEqual(@as(i32, 0), exercise.max(i32, 0, 0));
}

test "f64 比较" {
    try std.testing.expectEqual(@as(f64, 1.5), exercise.max(f64, 1.5, 1.25));
    try std.testing.expectEqual(@as(f64, -0.5), exercise.max(f64, -0.5, -0.75));
}

test "u8 比较" {
    try std.testing.expectEqual(@as(u8, 255), exercise.max(u8, 255, 0));
}
