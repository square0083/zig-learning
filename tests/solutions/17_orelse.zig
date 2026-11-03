//! 第 17 题参考解：orelse。

pub fn orDefault(value: ?i32, fallback: i32) i32 {
    return value orelse fallback;
}
