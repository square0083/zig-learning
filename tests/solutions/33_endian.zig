const std = @import("std");

pub fn decodeLittle(bytes: []const u8) error{InvalidLength}!u32 {
    if (bytes.len != 4) return error.InvalidLength;
    return std.mem.readInt(u32, bytes[0..4], .little);
}
