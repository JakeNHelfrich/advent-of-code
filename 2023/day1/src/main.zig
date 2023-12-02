const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    var file = try fs.cwd().openFile("input.txt", fs.File.OpenFlags{ .mode = .read_only });
    defer file.close();
    var reader = file.reader();

    var arraylist = std.ArrayList(u8).init(std.heap.page_allocator);

    try reader.streamUntilDelimiter(arraylist.writer(), '\n', null);
    while (arraylist.items.len > 0) {
        std.debug.print("{s} \n", .{arraylist.items});
        arraylist.clearAndFree();
        reader.streamUntilDelimiter(arraylist.writer(), '\n', null) catch return;
    }
}
