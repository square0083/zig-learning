const std = @import("std");
const exercise = @import("exercise");

test "squaredLength of (3, 4)" {
    const p = exercise.Point{ .x = 3, .y = 4 };
    try std.testing.expectEqual(@as(i32, 25), p.squaredLength());
}

test "squaredLength of (-3, 0)" {
    const p = exercise.Point{ .x = -3, .y = 0 };
    try std.testing.expectEqual(@as(i32, 9), p.squaredLength());
}

test "squaredLength at coordinate bounds" {
    const far = exercise.Point{ .x = 1000, .y = 1000 };
    try std.testing.expectEqual(@as(i32, 2_000_000), far.squaredLength());

    const negative = exercise.Point{ .x = -1000, .y = 0 };
    try std.testing.expectEqual(@as(i32, 1_000_000), negative.squaredLength());
}
