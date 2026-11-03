const std = @import("std");
const exercise = @import("exercise");

test "数组全部元素参与求和" {
    try std.testing.expectEqual(@as(i32, 10), exercise.sum(.{ 1, 2, 3, 4 }));
    try std.testing.expectEqual(@as(i32, 0), exercise.sum(.{ -2, 0, 2, 0 }));
    try std.testing.expectEqual(@as(i32, -6), exercise.sum(.{ -1, -2, -3, 0 }));
}
