const std = @import("std");

pub fn main() !void {
    const file = std.fs.cwd().openFile("input.txt", .{ .mode = .read_only }) catch return;
    defer file.close();

    const reader = file.reader();
    var varBuffer = std.ArrayList(u8).init(std.heap.page_allocator);

    while (reader.streamUntilDelimiter(varBuffer.writer(), '\n', null)) {
        std.debug.print("{s} \n", .{varBuffer.allocatedSlice()});
        varBuffer.clearAndFree();
    } else |err| {
        _ = err catch null;
    }
}
