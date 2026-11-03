//! 第 27 题：哈希表（内存与容器）
//!
//! 目标：实现 uniqueCount，返回 words 中不同字符串的个数；空输入返回 0。
//! 不得修改、复制或释放调用者传入的 word。
//! 前置知识：std.StringHashMap(V) 的 init(allocator)、put(key, value)、count()、deinit()。
//! 需要修改：目前每读到一个词就加一，重复词也被重复计数。
//! 运行：zig_learning run 27_hashmap

const std = @import("std");

pub fn uniqueCount(allocator: std.mem.Allocator, words: []const []const u8) std.mem.Allocator.Error!usize {
    var seen = std.StringHashMap(void).init(allocator);
    defer seen.deinit();

    var count: usize = 0;
    for (words) |word| {
        try seen.put(word, {});
        count += 1;
    }
    return count;
}
