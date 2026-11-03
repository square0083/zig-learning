const std = @import("std");
const exercise = @import("exercise");

test "最高位和最低位" {
    try std.testing.expectEqual(@as(u8, 128), exercise.setBit(0, 7));
    try std.testing.expectEqual(@as(u8, 1), exercise.setBit(0, 0));
}

test "保留其他位" {
    try std.testing.expectEqual(@as(u8, 0x81), exercise.setBit(0x80, 0));
    try std.testing.expectEqual(@as(u8, 0x81), exercise.setBit(0x01, 7));
    try std.testing.expectEqual(@as(u8, 0xB5), exercise.setBit(0xA5, 4));
}

test "重复设置同一位不改变结果" {
    try std.testing.expectEqual(@as(u8, 0b0000_0010), exercise.setBit(0b0000_0010, 1));
    try std.testing.expectEqual(@as(u8, 255), exercise.setBit(255, 3));
}
