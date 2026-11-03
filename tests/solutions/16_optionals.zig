//! 第 16 题参考解：可选值。

pub fn first(values: []const i32) ?i32 {
    if (values.len == 0) return null;
    return values[0];
}
