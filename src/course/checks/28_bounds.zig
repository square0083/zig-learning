const std = @import("std");
const exercise = @import("exercise");

test "合法索引返回对应元素" {
    const values = [_]i32{ 10, 20, 30 };
    try std.testing.expectEqual(@as(i32, 10), try exercise.at(&values, 0));
    try std.testing.expectEqual(@as(i32, 20), try exercise.at(&values, 1));
    try std.testing.expectEqual(@as(i32, 30), try exercise.at(&values, 2));
}

test "空切片任何索引都越界" {
    const empty: []const i32 = &.{};
    try std.testing.expectError(error.OutOfBounds, exercise.at(empty, 0));
}

test "等于长度的索引越界" {
    const values = [_]i32{1};
    try std.testing.expectError(error.OutOfBounds, exercise.at(&values, 1));
}

test "超大索引不越界访问" {
    const values = [_]i32{ 1, 2, 3 };
    try std.testing.expectError(error.OutOfBounds, exercise.at(&values, 4));
    try std.testing.expectError(error.OutOfBounds, exercise.at(&values, std.math.maxInt(usize)));
}
