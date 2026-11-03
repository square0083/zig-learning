const std = @import("std");
const exercise = @import("exercise");

test "年龄至少 18 且必须有票" {
    try std.testing.expect(!exercise.allowed(17, false));
    try std.testing.expect(!exercise.allowed(17, true));
    try std.testing.expect(!exercise.allowed(18, false));
    try std.testing.expect(exercise.allowed(18, true));
    try std.testing.expect(exercise.allowed(19, true));
    try std.testing.expect(exercise.allowed(255, true));
}
