pub fn at(values: []const i32, index: usize) error{OutOfBounds}!i32 {
    if (index >= values.len) return error.OutOfBounds;
    return values[index];
}
