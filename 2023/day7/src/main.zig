const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();

    var buffer = std.ArrayList(u8).init(std.heap.page_allocator);

    while (reader.streamUntilDelimiter(buffer.writer(), '\n', null)) : (buffer.clearAndFree()) {
        std.debug.print("{s}\n", .{buffer.items});
    } else |err| {
        _ = err catch null;
    }
}
