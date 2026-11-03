const std = @import("std");
const exercise = @import("exercise");

test "多行数据正常统计" {
    const stats = try exercise.summarize("3\n-2\n5\n");
    try std.testing.expectEqual(@as(usize, 3), stats.count);
    try std.testing.expectEqual(@as(i64, 6), stats.total);
    try std.testing.expectEqual(@as(?i32, -2), stats.min);
    try std.testing.expectEqual(@as(?i32, 5), stats.max);
}

test "空输入得到空统计" {
    const stats = try exercise.summarize("");
    try std.testing.expectEqual(@as(usize, 0), stats.count);
    try std.testing.expectEqual(@as(i64, 0), stats.total);
    try std.testing.expect(stats.min == null);
    try std.testing.expect(stats.max == null);

    const blank = try exercise.summarize("\n \t\r\n  \n");
    try std.testing.expectEqual(@as(usize, 0), blank.count);
    try std.testing.expect(blank.min == null);
    try std.testing.expect(blank.max == null);
}

test "全正数时 min 是真实最小值" {
    const stats = try exercise.summarize("4\n9\n7");
    try std.testing.expectEqual(@as(usize, 3), stats.count);
    try std.testing.expectEqual(@as(i64, 20), stats.total);
    try std.testing.expectEqual(@as(?i32, 4), stats.min);
    try std.testing.expectEqual(@as(?i32, 9), stats.max);
}

test "全负数与单个数据" {
    const negative = try exercise.summarize("-1\n-5\n");
    try std.testing.expectEqual(@as(?i32, -5), negative.min);
    try std.testing.expectEqual(@as(?i32, -1), negative.max);
    try std.testing.expectEqual(@as(i64, -6), negative.total);

    const single = try exercise.summarize("42");
    try std.testing.expectEqual(@as(usize, 1), single.count);
    try std.testing.expectEqual(@as(?i32, 42), single.min);
    try std.testing.expectEqual(@as(?i32, 42), single.max);
}

test "跳过空白行并支持 CRLF" {
    const stats = try exercise.summarize("  \n1\r\n\n 2 \n");
    try std.testing.expectEqual(@as(usize, 2), stats.count);
    try std.testing.expectEqual(@as(i64, 3), stats.total);
    try std.testing.expectEqual(@as(?i32, 1), stats.min);
    try std.testing.expectEqual(@as(?i32, 2), stats.max);
}

test "i32 边界值" {
    const stats = try exercise.summarize("2147483647\n-2147483648");
    try std.testing.expectEqual(@as(i64, -1), stats.total);
    try std.testing.expectEqual(@as(?i32, -2147483648), stats.min);
    try std.testing.expectEqual(@as(?i32, 2147483647), stats.max);
}

test "非法行与越界数值" {
    try std.testing.expectError(error.InvalidCharacter, exercise.summarize("1\nx\n"));
    try std.testing.expectError(error.InvalidCharacter, exercise.summarize("1.5"));
    try std.testing.expectError(error.InvalidCharacter, exercise.summarize("1,,2"));
    try std.testing.expectError(error.Overflow, exercise.summarize("2147483648"));
    try std.testing.expectError(error.Overflow, exercise.summarize("-2147483649"));
}
