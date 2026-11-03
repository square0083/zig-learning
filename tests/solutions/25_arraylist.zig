const std = @import("std");

pub fn evens(allocator: std.mem.Allocator, input: []const i32) std.mem.Allocator.Error![]i32 {
    var list = std.ArrayList(i32).empty;
    errdefer list.deinit(allocator);

    for (input) |value| {
        if (@mod(value, 2) == 0) {
            try list.append(allocator, value);
        }
    }

    return try list.toOwnedSlice(allocator);
}
