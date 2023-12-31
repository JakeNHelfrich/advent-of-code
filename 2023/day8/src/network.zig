const std = @import("std");

pub const Network = std.StringHashMap(struct { left: []const u8, right: []const u8 });

pub fn parseNetwork(allocator: std.mem.Allocator, reader: anytype) !Network {
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
