//! 第 13 题：结构体（数据建模）
//!
//! 目标：为 Point 实现 squaredLength 方法，返回坐标的平方和 x*x + y*y。
//! 前置知识：结构体声明、pub const、结构体方法（第一个参数为 self）。
//! 需要修改：squaredLength 的方法体把平方和写成了坐标和。
//! 运行：zig_learning run 13_structs

pub const Point = struct {
    x: i32,
    y: i32,

    pub fn squaredLength(self: Point) i32 {
        return self.x + self.y;
    }
};
