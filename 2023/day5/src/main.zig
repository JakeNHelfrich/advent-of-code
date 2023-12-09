const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example.txt", .{ .mode = .read_only });
    var reader = file.reader();

    var buffer = std.ArrayList(u8).init(std.heap.page_allocator);

    try reader.streamUntilDelimiter(buffer.writer(), '\n', null);

    std.debug.print("{s} \n", .{buffer.items});
}
