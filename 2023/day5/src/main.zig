const std = @import("std");
const parser = @import("./parse.zig");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example.txt", .{ .mode = .read_only });
    var reader = file.reader();

    const almanac = try parser.parseAlmanac(reader, std.heap.page_allocator);

    const first = almanac.maps[0];
    const second = first[0];
    std.debug.print("{d} {d} {d}\n", .{ second.dstStart, second.srcStart, second.len });
}

// IDEA:
// Create a "getNextMap" function
// Keep updating the source seeds with the new mapped and pass that into the nxt map
