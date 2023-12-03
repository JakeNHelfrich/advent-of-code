const std = @import("std");

pub fn main() !void {
    const file = std.fs.cwd().openFile("input.txt", .{ .mode = .read_only }) catch return;
    defer file.close();

    const reader = file.reader();

    var gameNum: i32 = 1;
    while (readNextGame(reader)) |gameInfo| {
        const firstSet = gameInfo.items[0];
        std.debug.print("Game {d}: Total Red = {d} \n", .{ gameNum, firstSet.red });
        gameNum += 1;
    } else |err| {
        _ = err catch null;
    }
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
        var cubeIter = std.mem.tokenizeSequence(u8, set, ",");
        var setInfo = SetInfo{
            .red = 0,
            .green = 0,
            .blue = 0,
        };
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
