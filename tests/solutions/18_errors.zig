//! 第 18 题参考解：错误集。

pub fn divide(a: u32, b: u32) error{DivisionByZero}!u32 {
    if (b == 0) return error.DivisionByZero;
    return a / b;
}
