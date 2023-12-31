const std = @import("std");
const nw = @import("./network.zig");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();

    var buffer = std.ArrayList(u8).init(std.heap.page_allocator);

    try reader.streamUntilDelimiter(buffer.writer(), '\n', null);
    const instructions = std.mem.trim(u8, try buffer.toOwnedSlice(), "\n");
    buffer.clearAndFree();

    const network = try nw.parseNetwork(std.heap.page_allocator, reader);

    var currentNode: []const u8 = "AAA";
    var currentInstruction: usize = 0;
    var count: i32 = 0;
    while (!std.mem.eql(u8, currentNode, "ZZZ")) : ({
        currentInstruction = (currentInstruction + 1) % instructions.len;
        count += 1;
    }) {
        const instruction = instructions[currentInstruction];
        const children = network.get(currentNode).?;

        currentNode = try switch (instruction) {
            'L' => children.left,
            'R' => children.right,
            else => error.InvalidInstruction,
        };
    }

    std.debug.print("Number of steps: {d} \n", .{count});
}
