const std = @import("std");
const exercise = @import("exercise");

test "answer 返回 42" {
    try std.testing.expectEqual(@as(u8, 42), exercise.answer());
}
