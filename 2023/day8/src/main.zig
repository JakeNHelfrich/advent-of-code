const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();

    var buffer = std.ArrayList(u8).init(std.heap.page_allocator);

    try reader.streamUntilDelimiter(buffer.writer(), '\n', null);
    const instructions = try buffer.toOwnedSlice();
    buffer.clearAndFree();
    std.debug.print("{s} \n", .{instructions});

    while (reader.streamUntilDelimiter(buffer.writer(), '\n', null)) : (buffer.clearAndFree()) {
        const line = buffer.items;
        if (line.len == 0) continue;

        var iter = std.mem.splitSequence(u8, line, " = ");
        const node = iter.first();
        const rest = iter.next().?;

        var childSeq = std.mem.splitSequence(u8, rest[1..(rest.len - 1)], ", ");
        const left = childSeq.first();
        const right = childSeq.rest();

        std.debug.print("{s} {s} {s}\n", .{ node, left, right });
    } else |err| {
        _ = err catch null;
    }
}
