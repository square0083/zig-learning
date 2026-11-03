//! 第 21 题：指针（指针与所有权）
//!
//! 目标：实现 increment，把指针指向的整数在原位加 1。
//! 前置知识：单元素指针 *i32、解引用语法 value.*。
//! 需要修改：目前直接对指针本身做加法，忘记解引用。
//! 运行：zig_learning run 21_pointers

pub fn increment(value: *i32) void {
    value += 1;
}
