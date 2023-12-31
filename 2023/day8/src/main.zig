const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();

    var buffer = std.ArrayList(u8).init(std.heap.page_allocator);

    try reader.streamUntilDelimiter(buffer.writer(), '\n', null);
    const instructions = std.mem.trim(u8, try buffer.toOwnedSlice(), "\n");
    buffer.clearAndFree();
    std.debug.print("{s} \n", .{instructions});

    const network = try parseNetwork(std.heap.page_allocator, reader);

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

const Network = std.StringHashMap(struct { left: []const u8, right: []const u8 });

fn parseNetwork(allocator: std.mem.Allocator, reader: anytype) !Network {
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();
    var network = Network.init(allocator);

    while (reader.streamUntilDelimiter(buffer.writer(), '\n', null)) : (buffer.clearAndFree()) {
        const line = try buffer.toOwnedSlice();
        if (line.len == 0) continue;

        var iter = std.mem.splitSequence(u8, line, " = ");
        const node = iter.first();
        const rest = iter.next().?;

        var childSeq = std.mem.splitSequence(u8, rest[1..(rest.len - 1)], ", ");
        const left = childSeq.first();
        const right = childSeq.rest();

        try network.put(node, .{ .left = left, .right = right });
    } else |err| {
        _ = err catch null;
    }

    return network;
}
