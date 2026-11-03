const std = @import("std");
const exercise = @import("exercise");

test "reverses an even-length slice" {
    var buf = [_]u8{ 'a', 'b', 'c', 'd' };
    exercise.reverse(&buf);
    try std.testing.expectEqualStrings("dcba", &buf);
}

test "reverses an odd-length slice" {
    var buf = [_]u8{ 'a', 'b', 'c' };
    exercise.reverse(&buf);
    try std.testing.expectEqualStrings("cba", &buf);
}

test "empty and single element slices are unchanged" {
    var empty: [0]u8 = .{};
    exercise.reverse(&empty);
    try std.testing.expectEqual(@as(usize, 0), empty.len);

    var single = [_]u8{'x'};
    exercise.reverse(&single);
    try std.testing.expectEqualStrings("x", &single);
}

test "two element slice" {
    var buf = [_]u8{ 'x', 'y' };
    exercise.reverse(&buf);
    try std.testing.expectEqualStrings("yx", &buf);
}
