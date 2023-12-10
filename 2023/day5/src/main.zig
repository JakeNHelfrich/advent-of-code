const std = @import("std");
const parser = @import("./parse.zig");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    var reader = file.reader();

    const almanac = try parser.parseAlmanac(reader, std.heap.page_allocator);

    var seeds = almanac.seeds;
    for (almanac.maps) |map| {
        for (0..seeds.len) |seedInd| {
            const dst = mapSrcToDest(seeds[seedInd], map);
            seeds[seedInd] = dst;
        }
    }

    const min = std.mem.min(i64, seeds);
    std.debug.print("{d} \n", .{min});
}

fn mapSrcToDest(src: i64, map: parser.AlmanacMap) i64 {
    for (map) |range| {
        if (src >= range.srcStart and src < range.srcStart + range.len) {
            const dist = src - range.srcStart;
            const dst = range.dstStart + dist;
            return dst;
        }
    }

    return src;
}
