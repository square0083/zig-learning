pub fn countEven(values: []const i32) usize {
    var count: usize = 0;
    for (values) |value| {
        if (@mod(value, 2) == 0) {
            count += 1;
        }
    }
    return count;
}
