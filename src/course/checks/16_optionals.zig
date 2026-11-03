const std = @import("std");
const exercise = @import("exercise");

test "empty slice yields null" {
    const empty: []const i32 = &.{};
    try std.testing.expect(exercise.first(empty) == null);
}

test "non-empty slice yields its first element" {
    const values = [_]i32{ 7, 8 };
    try std.testing.expectEqual(@as(?i32, 7), exercise.first(&values));
}

test "single element slice" {
    const values = [_]i32{-3};
    try std.testing.expectEqual(@as(?i32, -3), exercise.first(&values));
}
