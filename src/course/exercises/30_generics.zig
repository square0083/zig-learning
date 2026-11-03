//! 第 30 题：泛型函数（编译期与泛型）
//!
//! 目标：实现 max，返回较大的那个值，同一函数同时适用于整数和浮点类型。
//! T 只允许数值类型，其他类型应在编译期报错。
//! 前置知识：comptime 类型参数、@typeInfo、> 比较运算。
//! 需要修改：目前把两个参数强制转成 i32 再比较，浮点类型实例化会直接编译失败。
//! 运行：zig_learning run 30_generics

pub fn max(comptime T: type, a: T, b: T) T {
    switch (@typeInfo(T)) {
        .int, .float, .comptime_int, .comptime_float => {},
        else => @compileError("max 只支持数值类型"),
    }

    const left: i32 = @intCast(a);
    const right: i32 = @intCast(b);
    return if (left > right) a else b;
}
