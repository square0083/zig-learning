const std = @import("std");
const exercise = @import("exercise");

test "按小端序解码" {
    const bytes = [_]u8{ 0x78, 0x56, 0x34, 0x12 };
    try std.testing.expectEqual(@as(u32, 0x12345678), try exercise.decodeLittle(&bytes));
}

test "全零与最大值" {
    const zeros = [_]u8{ 0, 0, 0, 0 };
    try std.testing.expectEqual(@as(u32, 0), try exercise.decodeLittle(&zeros));

    const max = [_]u8{ 0xFF, 0xFF, 0xFF, 0xFF };
    try std.testing.expectEqual(@as(u32, 0xFFFFFFFF), try exercise.decodeLittle(&max));

    const one = [_]u8{ 1, 0, 0, 0 };
    try std.testing.expectEqual(@as(u32, 1), try exercise.decodeLittle(&one));
}

test "长度不是 4 返回 InvalidLength" {
    const empty: []const u8 = &.{};
    try std.testing.expectError(error.InvalidLength, exercise.decodeLittle(empty));

    const three = [_]u8{ 1, 2, 3 };
    try std.testing.expectError(error.InvalidLength, exercise.decodeLittle(&three));

    const five = [_]u8{ 1, 2, 3, 4, 5 };
    try std.testing.expectError(error.InvalidLength, exercise.decodeLittle(&five));
}
