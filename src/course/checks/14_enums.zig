const std = @import("std");
const exercise = @import("exercise");

test "each color maps to its code" {
    try std.testing.expectEqual(@as(u8, 1), exercise.code(.red));
    try std.testing.expectEqual(@as(u8, 2), exercise.code(.green));
    try std.testing.expectEqual(@as(u8, 3), exercise.code(.blue));
}
