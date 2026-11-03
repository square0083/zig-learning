//! 第 14 题参考解：枚举。

pub const Color = enum { red, green, blue };

pub fn code(color: Color) u8 {
    return switch (color) {
        .red => 1,
        .green => 2,
        .blue => 3,
    };
}
