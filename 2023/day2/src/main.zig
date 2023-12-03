const std = @import("std");

pub fn main() !void {
    const file = std.fs.cwd().openFile("input.txt", .{ .mode = .read_only }) catch return;
    defer file.close();

    const reader = file.reader();

    var games = std.ArrayList(GameInfo).init(std.heap.page_allocator);
    while (readNextGame(reader)) |gameInfo| {
        try games.append(gameInfo);
    } else |err| {
        _ = err catch null;
    }

    //part1
    var sum: i32 = 0;
    for (games.items, 1..) |gameInfo, gameNum| {
        var valid: bool = true;
        for (gameInfo.items) |set| {
            if (set.red > 12 or set.green > 13 or set.blue > 14) {
                valid = false;
                break;
            }
        }
        if (valid) {
            sum += @intCast(gameNum);
        }
    }

    std.debug.print("Total Sum: {d}\n", .{sum});
}

const Colour = enum(u8) {
    red,
    green,
    blue,
};

const SetInfo = struct {
    red: i32,
    green: i32,
    blue: i32,
};

const GameInfo = std.ArrayList(SetInfo);

fn readNextGame(reader: std.fs.File.Reader) !GameInfo {
    var varBuffer = std.ArrayList(u8).init(std.heap.page_allocator);
    defer varBuffer.clearAndFree();

    try reader.streamUntilDelimiter(varBuffer.writer(), '\n', null);

    const line = varBuffer.allocatedSlice();
    var lineItr = std.mem.splitSequence(u8, line, ":");
    _ = lineItr.next().?; // We don't use the game information

    const setsInfo: []const u8 = lineItr.next().?;
    var setsItr = std.mem.tokenizeSequence(u8, setsInfo, ";");

    var gameInfo = GameInfo.init(std.heap.page_allocator);
    while (setsItr.next()) |set| {
        var setInfo = SetInfo{
            .red = 0,
            .green = 0,
            .blue = 0,
        };
        var cubeIter = std.mem.tokenizeSequence(u8, set, ",");
        while (cubeIter.next()) |cube| {
            var cubeInfo = std.mem.trim(u8, cube, " \x00");
            var cubeInfoItr = std.mem.splitSequence(u8, cubeInfo, " ");
            var number = std.fmt.parseInt(i32, cubeInfoItr.next().?, 10) catch 0;
            var pre = cubeInfoItr.next().?;
            var colour: Colour = std.meta.stringToEnum(Colour, pre).?;

            switch (colour) {
                Colour.red => setInfo.red += number,
                Colour.blue => setInfo.blue += number,
                Colour.green => setInfo.green += number,
            }
        }
        try gameInfo.append(setInfo);
    }

    return gameInfo;
}
