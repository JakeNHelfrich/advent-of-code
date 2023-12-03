const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example.txt", .{ .mode = .read_only });
    var reader = file.reader();

    var board = try parseBoard(reader);
    _ = board;
}

const Number = struct { value: i32, y: i32, x: struct { i32, i32 } };

const Pattern = struct {
    x: i32,
    y: i32,
};

const Board = struct {
    numbers: []Number,
    patterns: []Pattern,
};

fn parseBoard(reader: anytype) !Board {
    var numbers = std.ArrayList(Number).init(std.heap.page_allocator);
    var patterns = std.ArrayList(Pattern).init(std.heap.page_allocator);

    var varBuffer = std.ArrayList(u8).init(std.heap.page_allocator);
    try reader.streamUntilDelimiter(varBuffer.writer(), '\n', null);

    std.debug.print("{s} \n", .{varBuffer.items});

    return Board{
        .numbers = numbers.items,
        .patterns = patterns.items,
    };
}
