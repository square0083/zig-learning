const std = @import("std");
const exercise = @import("exercise");

test "切片求和包含第一个元素并处理空切片" {
    try std.testing.expectEqual(@as(i32, 0), exercise.sum(&[_]i32{}));
    try std.testing.expectEqual(@as(i32, 5), exercise.sum(&[_]i32{ 2, -1, 4 }));
    try std.testing.expectEqual(@as(i32, -2), exercise.sum(&[_]i32{-2}));
}
