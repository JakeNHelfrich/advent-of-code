const std = @import("std");
const parse = @import("./parse.zig");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();
    const game = try parse.parseGame(reader, std.heap.page_allocator);

    for (game) |hand| {
        std.debug.print("{s} \n", .{@tagName(hand.type)});
    }
}
