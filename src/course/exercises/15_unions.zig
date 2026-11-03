//! 第 15 题：联合体（数据建模）
//!
//! 目标：实现 asInt，把 Value 转换为整数：整数分支原样返回，flag 为 true 返回 1、为 false 返回 0。
//! 前置知识：带标签的联合体 union(enum)、switch 捕获负载。
//! 需要修改：目前 flag 分支无论真假都返回 1。
//! 运行：zig_learning run 15_unions

pub const Value = union(enum) {
    integer: i32,
    flag: bool,
};

pub fn asInt(value: Value) i32 {
    return switch (value) {
        .integer => |n| n,
        .flag => 1,
    };
}
