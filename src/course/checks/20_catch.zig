const std = @import("std");
const exercise = @import("exercise");

test "valid decimal text is parsed" {
    try std.testing.expectEqual(@as(u8, 42), exercise.parseOrZero("42"));
    try std.testing.expectEqual(@as(u8, 0), exercise.parseOrZero("0"));
    try std.testing.expectEqual(@as(u8, 255), exercise.parseOrZero("255"));
}

test "invalid text yields zero" {
    try std.testing.expectEqual(@as(u8, 0), exercise.parseOrZero("abc"));
    try std.testing.expectEqual(@as(u8, 0), exercise.parseOrZero(""));
    try std.testing.expectEqual(@as(u8, 0), exercise.parseOrZero("-1"));
}

test "overflow yields zero" {
    try std.testing.expectEqual(@as(u8, 0), exercise.parseOrZero("256"));
    try std.testing.expectEqual(@as(u8, 0), exercise.parseOrZero("99999999999999999999"));
}
