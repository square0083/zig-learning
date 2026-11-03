const std = @import("std");
const exercise = @import("exercise");

test "parses both parts and widens before adding" {
    try std.testing.expectEqual(@as(u16, 510), try exercise.parsePairSum("255", "255"));
    try std.testing.expectEqual(@as(u16, 3), try exercise.parsePairSum("1", "2"));
    try std.testing.expectEqual(@as(u16, 0), try exercise.parsePairSum("0", "0"));
    try std.testing.expectEqual(@as(u16, 200), try exercise.parsePairSum("100", "100"));
}

test "invalid characters propagate the parse error" {
    try std.testing.expectError(error.InvalidCharacter, exercise.parsePairSum("x", "1"));
    try std.testing.expectError(error.InvalidCharacter, exercise.parsePairSum("1", "x"));
    try std.testing.expectError(error.InvalidCharacter, exercise.parsePairSum("", "1"));
}

test "overflow propagates the parse error" {
    try std.testing.expectError(error.Overflow, exercise.parsePairSum("256", "1"));
    try std.testing.expectError(error.Overflow, exercise.parsePairSum("1", "256"));
}
