//! 第 23 题：defer（指针与所有权）
//!
//! 目标：实现 readThenIncrement，先返回指针当前的值，函数退出时再把该值加 1。
//! 题目限定输入小于 255，不必处理溢出。
//! 前置知识：defer 语句在作用域退出时执行。
//! 需要修改：目前先自增再返回，返回值多了一次。
//! 运行：zig_learning run 23_defer

pub fn readThenIncrement(value: *u8) u8 {
    value.* += 1;
    return value.*;
}
