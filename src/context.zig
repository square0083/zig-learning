const std = @import("std");

pub const Context = struct {
    allocator: std.mem.Allocator,
    io: std.Io,
    environ: *const std.process.Environ.Map,
    out: *std.Io.Writer,
    err: *std.Io.Writer,
};
