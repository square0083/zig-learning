const std = @import("std");
const exercise = @import("exercise");

test "空文本与全空白返回 0" {
    try std.testing.expectEqual(@as(u32, 0), try exercise.sumCsv(""));
    try std.testing.expectEqual(@as(u32, 0), try exercise.sumCsv("  \t\r\n "));
}

test "正常求和并裁剪空白" {
    try std.testing.expectEqual(@as(u32, 6), try exercise.sumCsv("1, 2,3"));
    try std.testing.expectEqual(@as(u32, 6), try exercise.sumCsv("1,2,3\n"));
    try std.testing.expectEqual(@as(u32, 6), try exercise.sumCsv(" 1 ,\t2 , 3 "));
    try std.testing.expectEqual(@as(u32, 0), try exercise.sumCsv("0"));
}

test "空字段非法" {
    try std.testing.expectError(error.InvalidCharacter, exercise.sumCsv("1,,2"));
    try std.testing.expectError(error.InvalidCharacter, exercise.sumCsv(",1"));
    try std.testing.expectError(error.InvalidCharacter, exercise.sumCsv("1,"));
    try std.testing.expectError(error.InvalidCharacter, exercise.sumCsv("1, ,2"));
}

test "非法字符与负数" {
    try std.testing.expectError(error.InvalidCharacter, exercise.sumCsv("1,x"));
    try std.testing.expectError(error.InvalidCharacter, exercise.sumCsv("1,-2"));
    try std.testing.expectError(error.InvalidCharacter, exercise.sumCsv("1.5"));
}

test "溢出返回 Overflow" {
    try std.testing.expectError(error.Overflow, exercise.sumCsv("4294967295,1"));
    try std.testing.expectError(error.Overflow, exercise.sumCsv("4294967296"));
    try std.testing.expectEqual(@as(u32, 4294967295), try exercise.sumCsv("4294967295"));
}
