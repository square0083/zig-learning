const std = @import("std");
const exercise = @import("exercise");

test "后进先出，空栈返回 null" {
    var stack = exercise.Stack(i32, 4){};
    try stack.push(1);
    try stack.push(2);
    try stack.push(3);

    try std.testing.expectEqual(@as(?i32, 3), stack.pop());
    try std.testing.expectEqual(@as(?i32, 2), stack.pop());
    try std.testing.expectEqual(@as(?i32, 1), stack.pop());
    try std.testing.expectEqual(@as(?i32, null), stack.pop());
}

test "满栈返回 Full 且不改变已有数据" {
    var stack = exercise.Stack(u8, 2){};
    try stack.push(10);
    try stack.push(20);
    try std.testing.expectError(error.Full, stack.push(30));

    try std.testing.expectEqual(@as(?u8, 20), stack.pop());
    try std.testing.expectEqual(@as(?u8, 10), stack.pop());
    try std.testing.expectEqual(@as(?u8, null), stack.pop());
}

test "容量为 0 的栈总是满" {
    var stack = exercise.Stack(u8, 0){};
    try std.testing.expectError(error.Full, stack.push(1));
    try std.testing.expectEqual(@as(?u8, null), stack.pop());
}

test "重新压入可以继续使用" {
    var stack = exercise.Stack(u8, 1){};
    try stack.push(9);
    try std.testing.expectError(error.Full, stack.push(8));
    try std.testing.expectEqual(@as(?u8, 9), stack.pop());
    try stack.push(7);
    try std.testing.expectEqual(@as(?u8, 7), stack.pop());
}
