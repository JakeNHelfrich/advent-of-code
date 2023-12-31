const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    var reader = file.reader();
    var races = try parseRaces(reader, std.heap.page_allocator);

    var margin: i64 = 1;

    for (races) |race| {
        var holdTime: i64 = 0;
        var speed: i64 = 0;
        var numWaysToBeat: i64 = 0;
        while (holdTime <= race.time) : ({
            holdTime += 1;
            speed += 1;
        }) {
            const distance = (race.time - holdTime) * speed;
            if (distance > race.distance) numWaysToBeat += 1;
        }

        margin *= numWaysToBeat;
    }

    std.debug.print("{d} \n", .{margin});
}

const Race = struct {
    time: i64,
    distance: i64,
};

fn parseRaces(reader: anytype, alloc: std.mem.Allocator) ![]Race {
    var races = std.ArrayList(Race).init(alloc);

    var timeBuffer = std.ArrayList(u8).init(alloc);
    defer timeBuffer.clearAndFree();
    try reader.streamUntilDelimiter(timeBuffer.writer(), '\n', null);

    var timeIter = std.mem.tokenizeSequence(u8, timeBuffer.items, " ");
    _ = timeIter.next();

    var distanceBuffer = std.ArrayList(u8).init(alloc);
    defer distanceBuffer.clearAndFree();
    try reader.streamUntilDelimiter(distanceBuffer.writer(), '\n', null);

    var distanceIter = std.mem.tokenizeSequence(u8, distanceBuffer.items, " ");
    _ = distanceIter.next();

    while (timeIter.next()) |timeStr| {
        var distanceStr = distanceIter.next().?;
        var time = try std.fmt.parseInt(i64, std.mem.trim(u8, timeStr, "\x00"), 10);
        var distance = try std.fmt.parseInt(i64, std.mem.trim(u8, distanceStr, "\x00"), 10);
        const race = Race{ .time = time, .distance = distance };
        try races.append(race);
    }

    return races.items;
}
