const std = @import("std");
const exercise = @import("exercise");

test "阶乘覆盖 0、普通值和上限 20" {
    try std.testing.expectEqual(@as(u64, 1), exercise.factorial(0));
    try std.testing.expectEqual(@as(u64, 1), exercise.factorial(1));
    try std.testing.expectEqual(@as(u64, 120), exercise.factorial(5));
    try std.testing.expectEqual(@as(u64, 2432902008176640000), exercise.factorial(20));
}
