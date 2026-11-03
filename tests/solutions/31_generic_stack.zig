pub fn Stack(comptime T: type, comptime capacity: usize) type {
    return struct {
        items: [capacity]T = undefined,
        len: usize = 0,

        pub fn push(self: *@This(), value: T) error{Full}!void {
            if (capacity == 0) return error.Full;
            if (self.len == capacity) return error.Full;
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
