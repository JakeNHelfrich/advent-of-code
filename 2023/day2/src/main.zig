const std = @import("std");

pub fn main() !void {
    const file = std.fs.cwd().openFile("input.txt", .{ .mode = .read_only }) catch return;
    defer file.close();

    const reader = file.reader();
    var varBuffer = std.ArrayList(u8).init(std.heap.page_allocator);

    var gameNum: i32 = 1;
    while (reader.streamUntilDelimiter(varBuffer.writer(), '\n', null)) {
        const line = varBuffer.allocatedSlice();
        var lineItr = std.mem.splitSequence(u8, line, ":");
        _ = lineItr.next().?; // We don't use the game information

        const setsLine: []const u8 = lineItr.next().?;
        var setsItr = std.mem.tokenizeSequence(u8, setsLine, ";");

        while (setsItr.next()) |set| {
            var cubeIter = std.mem.tokenizeSequence(u8, set, ",");
            while (cubeIter.next()) |_cube| {
                var cubeInfo = std.mem.trim(u8, _cube, " ");
                var cubeInfoItr = std.mem.splitSequence(u8, cubeInfo, " ");
                var number = cubeInfoItr.next().?;
                var colour = cubeInfoItr.next().?;
                std.debug.print("|{s} {s}|", .{ colour, number });
            }
        }
        std.debug.print("\n", .{});

        gameNum += 1;
        varBuffer.clearAndFree();
        break;
    } else |err| {
        _ = err catch null;
    }
}
