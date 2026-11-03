const std = @import("std");
const exercise = @import("exercise");

test "n = 0 返回零长数组" {
    const result = exercise.repeat(0, 7);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "n = 3 填充同一个值" {
    const result = exercise.repeat(3, 7);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 7, 7, 7 }, &result);
}

test "n = 1 与边界值" {
    const one = exercise.repeat(1, 255);
    try std.testing.expectEqualSlices(u8, &[_]u8{255}, &one);

    const zero_value = exercise.repeat(2, 0);
    try std.testing.expectEqualSlices(u8, &[_]u8{ 0, 0 }, &zero_value);
}
