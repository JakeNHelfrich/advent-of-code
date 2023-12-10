const std = @import("std");

pub const Range = struct {
    srcStart: i32,
    dstStart: i32,
    len: i32,
};
pub const AlmanacMap = []Range;
pub const Almanac = struct {
    seeds: []i32,
    maps: []AlmanacMap,
};

pub fn parseAlmanac(reader: anytype, alloc: std.mem.Allocator) !Almanac {
    var almanacMaps = std.ArrayList(AlmanacMap).init(alloc);

    var buffer = std.ArrayList(u8).init(alloc);
    try reader.streamUntilDelimiter(buffer.writer(), '\n', null);
    const seeds = try parseSeeds(alloc, buffer.items);
    buffer.clearAndFree();

    while (reader.streamUntilDelimiter(buffer.writer(), '\n', null)) : (buffer.clearAndFree()) {
        if (buffer.items.len == 0) continue;
        var line: []u8 = buffer.items;
        if (std.mem.containsAtLeast(u8, line, 1, "map")) {
            const almanacMap = try parseAlmanacMap(reader, alloc);
            try almanacMaps.append(almanacMap);
        }
    } else |err| {
        _ = err catch null;
    }

    return Almanac{ .seeds = seeds, .maps = almanacMaps.items };
}

fn parseSeeds(alloc: std.mem.Allocator, seedsLine: []u8) ![]i32 {
    var seeds = std.ArrayList(i32).init(alloc);
    var seedsIter = std.mem.splitSequence(u8, seedsLine, ": ");
    _ = seedsIter.first();
    var seedNumbers = seedsIter.rest();
    var seedNumbersIter = std.mem.tokenizeSequence(u8, seedNumbers, " ");

    while (seedNumbersIter.next()) |seedStr| {
        var seed = try std.fmt.parseInt(i32, std.mem.trim(u8, seedStr, "\x00"), 10);
        try seeds.append(seed);
    }

    return seeds.items;
}

fn parseAlmanacMap(reader: anytype, alloc: std.mem.Allocator) !AlmanacMap {
    var buffer = std.ArrayList(u8).init(alloc);
    var almanacMap = std.ArrayList(Range).init(alloc);
    while (reader.streamUntilDelimiter(buffer.writer(), '\n', null)) : (buffer.clearAndFree()) {
        if (buffer.items.len == 0) break;
        var line = buffer.items;
        var lineItr = std.mem.tokenizeSequence(u8, line, " ");
        var range = Range{
            .dstStart = try std.fmt.parseInt(i32, lineItr.next().?, 10),
            .srcStart = try std.fmt.parseInt(i32, lineItr.next().?, 10),
            .len = try std.fmt.parseInt(i32, lineItr.next().?, 10),
        };
        try almanacMap.append(range);
    } else |err| {
        _ = err catch null;
    }

    return almanacMap.items;
}
