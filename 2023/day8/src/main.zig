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
    var paths = try getStartingPaths(std.heap.page_allocator, network);

    var currentInstruction: usize = 0;
    var numDone: i32 = 0;
    var numSteps: i32 = 0;
    while (numDone < paths.len) : ({
        currentInstruction = (currentInstruction + 1) % instructions.len;
        numSteps += 1;
    }) {
        numDone = 0;
        const instruction = instructions[currentInstruction];
        for (0..paths.len) |ind| {
            var path = paths[ind];

            const currentNode = path.node;
            const children = network.get(currentNode).?;
            path.node = try switch (instruction) {
                'L' => children.left,
                'R' => children.right,
                else => error.InvalidInstruction,
            };

            if (std.mem.endsWith(u8, path.node, "Z")) {
                numDone += 1;
            }
            // I need to find a better solution to this.
            // I couldn't find a way to mutate in place within a slice.
            paths[ind] = path;
        }

        std.debug.print("{d} {d} {d} \n", .{ paths.len, numDone, numSteps });
    }

    std.debug.print("Number of steps: {d} \n", .{numSteps});
}

const Path = struct { node: []const u8, end: bool };

fn getStartingPaths(allocator: std.mem.Allocator, network: nw.Network) ![]Path {
    var nodeIter = network.keyIterator();
    var startingPaths = std.ArrayList(Path).init(allocator);
    while (nodeIter.next()) |node| {
        if (std.mem.endsWith(u8, node.*, "A")) {
            try startingPaths.append(Path{
                .node = node.*,
                .end = false,
            });
        }
    }

    return startingPaths.items;
}
