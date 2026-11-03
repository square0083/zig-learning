const std = @import("std");
const exercise = @import("exercise");

test "null uses the fallback" {
    try std.testing.expectEqual(@as(i32, -3), exercise.orDefault(null, -3));
    try std.testing.expectEqual(@as(i32, 9), exercise.orDefault(null, 9));
}

test "zero is a real value and is kept" {
    try std.testing.expectEqual(@as(i32, 0), exercise.orDefault(0, 99));
}

test "present values are returned unchanged" {
    try std.testing.expectEqual(@as(i32, 5), exercise.orDefault(5, 99));
    try std.testing.expectEqual(@as(i32, -12), exercise.orDefault(-12, 0));
}
