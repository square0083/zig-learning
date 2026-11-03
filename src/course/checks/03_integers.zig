const std = @import("std");
const exercise = @import("exercise");

test "两个 u8 相加使用 u16 保存结果" {
    try std.testing.expectEqual(@as(u16, 510), exercise.addWide(255, 255));
    try std.testing.expectEqual(@as(u16, 0), exercise.addWide(0, 0));
    try std.testing.expectEqual(@as(u16, 200), exercise.addWide(100, 100));
}
