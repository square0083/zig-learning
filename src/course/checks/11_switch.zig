const std = @import("std");
const exercise = @import("exercise");

test "isDigit 接受 0 到 9 并拒绝相邻字符" {
    try std.testing.expect(exercise.isDigit('0'));
    try std.testing.expect(exercise.isDigit('5'));
    try std.testing.expect(exercise.isDigit('9'));
    try std.testing.expect(!exercise.isDigit('/'));
    try std.testing.expect(!exercise.isDigit(':'));
}
