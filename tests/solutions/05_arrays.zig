pub fn sum(values: [4]i32) i32 {
    var total: i32 = 0;
    var i: usize = 0;
    while (i < values.len) : (i += 1) {
        total += values[i];
    }
    return total;
}
