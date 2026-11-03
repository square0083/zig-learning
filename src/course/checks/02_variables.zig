const std = @import("std");
const exercise = @import("exercise");

test "count 从 1 开始修改两次后返回 3" {
    try std.testing.expectEqual(@as(u8, 3), exercise.count());
}
