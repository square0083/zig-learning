pub fn clamp(value: i32, lo: i32, hi: i32) i32 {
    if (value < lo) {
        return lo;
    }
    if (value > hi) {
        return hi;
    }
    return value;
}
