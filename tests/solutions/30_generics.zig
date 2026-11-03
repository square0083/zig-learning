pub fn max(comptime T: type, a: T, b: T) T {
    switch (@typeInfo(T)) {
        .int, .float, .comptime_int, .comptime_float => {},
        else => @compileError("max 只支持数值类型"),
    }
    return if (a > b) a else b;
}
