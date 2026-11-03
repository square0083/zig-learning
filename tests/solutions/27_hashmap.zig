const std = @import("std");

pub fn uniqueCount(allocator: std.mem.Allocator, words: []const []const u8) std.mem.Allocator.Error!usize {
    var seen = std.StringHashMap(void).init(allocator);
    defer seen.deinit();

    for (words) |word| {
        try seen.put(word, {});
    }
    return @intCast(seen.count());
}
