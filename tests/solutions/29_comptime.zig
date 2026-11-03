pub fn repeat(comptime n: usize, value: u8) [n]u8 {
    var bytes: [n]u8 = undefined;
    var i: usize = 0;
    while (i < n) : (i += 1) {
        bytes[i] = value;
    }
    return bytes;
}
