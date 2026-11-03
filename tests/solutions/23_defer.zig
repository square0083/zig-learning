//! 第 23 题参考解：defer。

pub fn readThenIncrement(value: *u8) u8 {
    defer value.* += 1;
    return value.*;
}
