//! 第 22 题参考解：可变切片。

pub fn reverse(bytes: []u8) void {
    const mid = bytes.len / 2;
    var i: usize = 0;
    while (i < mid) : (i += 1) {
        const j = bytes.len - 1 - i;
        const tmp = bytes[i];
        bytes[i] = bytes[j];
        bytes[j] = tmp;
    }
}
