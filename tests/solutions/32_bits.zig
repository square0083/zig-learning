pub fn setBit(value: u8, bit: u3) u8 {
    return value | (@as(u8, 1) << bit);
}
