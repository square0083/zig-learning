const std = @import("std");
const exercise = @import("exercise");

test "integer payload is preserved" {
    try std.testing.expectEqual(@as(i32, 42), exercise.asInt(.{ .integer = 42 }));
    try std.testing.expectEqual(@as(i32, -7), exercise.asInt(.{ .integer = -7 }));
    try std.testing.expectEqual(@as(i32, 0), exercise.asInt(.{ .integer = 0 }));
}

test "flag payload becomes 1 or 0" {
    try std.testing.expectEqual(@as(i32, 1), exercise.asInt(.{ .flag = true }));
    try std.testing.expectEqual(@as(i32, 0), exercise.asInt(.{ .flag = false }));
}
