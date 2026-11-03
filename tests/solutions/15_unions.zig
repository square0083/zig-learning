//! 第 15 题参考解：联合体。

pub const Value = union(enum) {
    integer: i32,
    flag: bool,
};

pub fn asInt(value: Value) i32 {
    return switch (value) {
        .integer => |n| n,
        .flag => |b| if (b) 1 else 0,
    };
}
