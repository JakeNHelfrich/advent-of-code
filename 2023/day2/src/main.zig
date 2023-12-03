const std = @import("std");

pub fn main() !void {
    const file = std.fs.cwd().openFile("input.txt", .{ .mode = .read_only }) catch return;
    defer file.close();

    const reader = file.reader();
    var varBuffer = std.ArrayList(u8).init(std.heap.page_allocator);

    try reader.streamUntilDelimiter(varBuffer.writer(), '\n', null);
    std.debug.print("First Line: {s} \n", .{varBuffer.allocatedSlice()});
}
