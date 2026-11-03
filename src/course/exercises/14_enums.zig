//! 第 14 题：枚举（数据建模）
//!
//! 目标：实现 code 函数，把 red、green、blue 分别映射为 1、2、3。
//! 前置知识：枚举类型、switch 对枚举值进行穷尽匹配。
//! 需要修改：目前 red 与 blue 的映射写反了。
//! 运行：zig_learning run 14_enums

pub const Color = enum { red, green, blue };

pub fn code(color: Color) u8 {
    return switch (color) {
        .red => 3,
        .green => 2,
        .blue => 1,
    };
}
