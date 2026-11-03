const std = @import("std");
const exercise = @import("exercise");

test "increments in place" {
    var value: i32 = 5;
    exercise.increment(&value);
    try std.testing.expectEqual(@as(i32, 6), value);
}

test "increments negative values and zero" {
    var negative: i32 = -1;
    exercise.increment(&negative);
    try std.testing.expectEqual(@as(i32, 0), negative);

    var zero: i32 = 0;
    exercise.increment(&zero);
    try std.testing.expectEqual(@as(i32, 1), zero);
}
