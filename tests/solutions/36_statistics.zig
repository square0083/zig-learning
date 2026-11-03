const std = @import("std");

pub const Stats = struct {
    count: usize,
    total: i64,
    min: ?i32,
    max: ?i32,
};

pub fn summarize(text: []const u8) error{ InvalidCharacter, Overflow }!Stats {
    var count: usize = 0;
    var total: i64 = 0;
    var min: ?i32 = null;
    var max: ?i32 = null;

    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |raw| {
        const line = std.mem.trim(u8, raw, " \t\r");
        if (line.len == 0) continue;

        const value = std.fmt.parseInt(i32, line, 10) catch |err| switch (err) {
            error.InvalidCharacter => return error.InvalidCharacter,
            error.Overflow => return error.Overflow,
        };

        count += 1;
        total = try std.math.add(i64, total, @as(i64, value));
        min = if (min) |current| @min(current, value) else value;
        max = if (max) |current| @max(current, value) else value;
    }

    return .{ .count = count, .total = total, .min = min, .max = max };
}
