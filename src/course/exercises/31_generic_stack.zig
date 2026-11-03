//! 第 31 题：泛型栈（编译期与泛型）
//!
//! 目标：实现 Stack(T, capacity)，返回可用 `.{}` 初始化的栈类型：
//! push 满栈返回 error.Full 且不破坏已有数据，pop 按后进先出返回元素，空栈返回 null。
//! 容量为 0 的栈每次 push 都返回 error.Full。
//! 前置知识：返回类型的泛型函数、@This()、结构体字段默认值、固定长度数组。
//! 需要修改：目前栈满时覆盖最后一个元素并当作成功返回。
//! 运行：zig_learning run 31_generic_stack

pub fn Stack(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T = undefined,
        len: usize = 0,

        pub fn push(self: *@This(), value: T) error{Full}!void {
            if (capacity == 0) return error.Full;
            if (self.len == capacity) {
                if (self.len > 0) {
                    self.items[self.len - 1] = value;
                }
                return;
            }
            self.items[self.len] = value;
            self.len += 1;
        }

        pub fn pop(self: *@This()) ?T {
            if (capacity == 0) return null;
            if (self.len == 0) return null;
            self.len -= 1;
            return self.items[self.len];
        }
    };
}
