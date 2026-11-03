//! 第 13 题参考解：结构体。

pub const Point = struct {
    x: i32,
    y: i32,

    pub fn squaredLength(self: Point) i32 {
        return self.x * self.x + self.y * self.y;
    }
};
