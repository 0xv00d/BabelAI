const std = @import("std");
const latin = @import("latin");

pub fn main() !void {
    // Letting UTF-8 get printed to Windows cmd.
    _ = std.os.windows.kernel32.SetConsoleOutputCP(65001);

    try latin.instantiateLatinModule();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
