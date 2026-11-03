const std = @import("std");
const exercise = @import("exercise");

test "countEven 统计所有偶数包括 0 和负数" {
    try std.testing.expectEqual(@as(usize, 0), exercise.countEven(&[_]i32{}));
    try std.testing.expectEqual(@as(usize, 3), exercise.countEven(&[_]i32{ -2, -1, 0, 3, 4 }));
    try std.testing.expectEqual(@as(usize, 0), exercise.countEven(&[_]i32{ 1, 3, 5 }));
    try std.testing.expectEqual(@as(usize, 4), exercise.countEven(&[_]i32{ -4, -2, 0, 2 }));
}
