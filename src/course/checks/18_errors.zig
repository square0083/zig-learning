const std = @import("std");
const exercise = @import("exercise");

test "normal divisions" {
    try std.testing.expectEqual(@as(u32, 3), try exercise.divide(7, 2));
    try std.testing.expectEqual(@as(u32, 5), try exercise.divide(5, 1));
}

test "zero numerator and numerator smaller than divisor" {
    try std.testing.expectEqual(@as(u32, 0), try exercise.divide(0, 5));
    try std.testing.expectEqual(@as(u32, 0), try exercise.divide(2, 7));
}

test "division by zero reports the declared error" {
    try std.testing.expectError(error.DivisionByZero, exercise.divide(5, 0));
    try std.testing.expectError(error.DivisionByZero, exercise.divide(0, 0));
}
