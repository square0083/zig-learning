const std = @import("std");
const exercise = @import("exercise");

test "解析合法配置" {
    const parsed = try exercise.parse(std.testing.allocator, "{\"name\":\"demo\",\"retries\":3}");
    defer parsed.deinit();
    try std.testing.expectEqualStrings("demo", parsed.value.name);
    try std.testing.expectEqual(@as(u8, 3), parsed.value.retries);
}

test "解析结果拥有字符串，修改输入缓冲区后不变" {
    const text = "{\"name\":\"demo\",\"retries\":1}";
    var buffer: [text.len]u8 = undefined;
    @memcpy(&buffer, text);

    const parsed = try exercise.parse(std.testing.allocator, &buffer);
    defer parsed.deinit();

    @memset(&buffer, 'x');
    try std.testing.expectEqualStrings("demo", parsed.value.name);
    try std.testing.expectEqual(@as(u8, 1), parsed.value.retries);
}

test "缺少字段返回 MissingField" {
    try std.testing.expectError(error.MissingField, exercise.parse(std.testing.allocator, "{\"name\":\"a\"}"));
    try std.testing.expectError(error.MissingField, exercise.parse(std.testing.allocator, "{\"retries\":2}"));
}

test "字段类型不符返回错误" {
    try std.testing.expectError(error.UnexpectedToken, exercise.parse(std.testing.allocator, "{\"name\":\"a\",\"retries\":true}"));
    try std.testing.expectError(error.UnexpectedToken, exercise.parse(std.testing.allocator, "{\"name\":\"a\",\"retries\":[3]}"));
}

test "retries 超出 u8 范围返回 Overflow" {
    try std.testing.expectError(error.Overflow, exercise.parse(std.testing.allocator, "{\"name\":\"a\",\"retries\":300}"));
}

test "非法 JSON 返回语法错误" {
    try std.testing.expectError(error.SyntaxError, exercise.parse(std.testing.allocator, "not json"));
    try std.testing.expectError(error.SyntaxError, exercise.parse(std.testing.allocator, "{\"name\" \"a\"}"));
    try std.testing.expectError(error.SyntaxError, exercise.parse(std.testing.allocator, "{name:1}"));
}
