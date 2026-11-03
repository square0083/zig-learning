const std = @import("std");

pub fn sumCsv(text: []const u8) error{ InvalidCharacter, Overflow }!u32 {
    if (std.mem.trim(u8, text, " \t\r\n").len == 0) return 0;

    var total: u32 = 0;
    var fields = std.mem.splitScalar(u8, text, ',');
    while (fields.next()) |raw| {
        const field = std.mem.trim(u8, raw, " \t\r\n");
        if (field.len == 0) return error.InvalidCharacter;
        if (field[0] == '-') return error.InvalidCharacter;

        const value = std.fmt.parseInt(u32, field, 10) catch |err| switch (err) {
            error.InvalidCharacter => return error.InvalidCharacter,
            error.Overflow => return error.Overflow,
        };
        total = try std.math.add(u32, total, value);
    }
    return total;
}
