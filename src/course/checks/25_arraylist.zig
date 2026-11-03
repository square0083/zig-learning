const std = @import("std");
const exercise = @import("exercise");

test "保序筛选偶数" {
    const input = [_]i32{ -2, -1, 0, 3, 4 };
    const result = try exercise.evens(std.testing.allocator, &input);
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualSlices(i32, &[_]i32{ -2, 0, 4 }, result);
}

test "空输入返回空切片" {
    const empty: []const i32 = &.{};
    const result = try exercise.evens(std.testing.allocator, empty);
    defer std.testing.allocator.free(result);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "没有偶数时结果为空" {
    const input = [_]i32{ 1, -3, 7 };
    const result = try exercise.evens(std.testing.allocator, &input);
    defer std.testing.allocator.free(result);
    try std.testing.expectEqual(@as(usize, 0), result.len);
}

test "全部是偶数" {
    const input = [_]i32{ 0, 2, -4 };
    const result = try exercise.evens(std.testing.allocator, &input);
    defer std.testing.allocator.free(result);
    try std.testing.expectEqualSlices(i32, &[_]i32{ 0, 2, -4 }, result);
}

fn allocationRoundTrip(allocator: std.mem.Allocator) !void {
    const result = try exercise.evens(allocator, &.{ 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24 });
    defer allocator.free(result);
    try std.testing.expectEqualSlices(i32, &.{ 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24 }, result);
}

test "分配失败释放已增长的列表" {
    try std.testing.checkAllAllocationFailures(std.testing.allocator, allocationRoundTrip, .{});
}
