const std = @import("std");
const exercise = @import("exercise");

test "returns the old value and increments afterwards" {
    var value: u8 = 4;
    try std.testing.expectEqual(@as(u8, 4), exercise.readThenIncrement(&value));
    try std.testing.expectEqual(@as(u8, 5), value);
}

test "works for zero and for the largest allowed input" {
    var zero: u8 = 0;
    try std.testing.expectEqual(@as(u8, 0), exercise.readThenIncrement(&zero));
    try std.testing.expectEqual(@as(u8, 1), zero);

    var near_max: u8 = 254;
    try std.testing.expectEqual(@as(u8, 254), exercise.readThenIncrement(&near_max));
    try std.testing.expectEqual(@as(u8, 255), near_max);
}
