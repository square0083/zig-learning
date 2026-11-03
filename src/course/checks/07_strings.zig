const std = @import("std");
const exercise = @import("exercise");

test "greeting 返回完整的 UTF-8 字节串" {
    try std.testing.expectEqualStrings("你好，Zig！", exercise.greeting());
    try std.testing.expectEqual(@as(usize, 15), exercise.greeting().len);
}
