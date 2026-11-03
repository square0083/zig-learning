//! 第 21 题参考解：指针。

pub fn increment(value: *i32) void {
    value.* += 1;
}
