const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example.txt", .{ .mode = .read_only });
    defer file.close();
    var reader = file.reader();

    var board = try parseBoard(reader);

    for (board.numbers) |number| {
        std.debug.print("Value {d} | y {d} | x start {d} x end {d} \n", .{ number.value, number.y, number.x[0], number.x[1] });
    }

    for (board.patterns) |pattern| {
        std.debug.print("Pattern | y {d} | x {d} \n", .{ pattern.y, pattern.x });
    }
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
    defer varBuffer.clearAndFree();

    var row: i32 = 0;
    while (reader.streamUntilDelimiter(varBuffer.writer(), '\n', null)) : (varBuffer.clearAndFree()) {
        const line: []const u8 = std.mem.trim(u8, varBuffer.allocatedSlice(), "\x00");
        var curr: usize = 0;
        while (curr < line.len) : (curr += 1) {
            var char = line[curr];

            if (std.ascii.isDigit(char)) {
                var numberList = std.ArrayList(u8).init(std.heap.page_allocator);
                var start: i32 = @intCast(curr);
                while (std.ascii.isDigit(line[curr])) : (curr += 1) {
                    char = line[curr];
                    try numberList.append(char);
                }
                curr -= 1;
                var end: i32 = @intCast(curr);

                const number = Number{ .value = try std.fmt.parseInt(i32, numberList.items, 10), .y = row, .x = .{ start, end } };
                try numbers.append(number);
            } else if (!std.ascii.isAlphanumeric(char) and char != '.') {
                const pattern = Pattern{ .y = row, .x = @intCast(curr) };
                try patterns.append(pattern);
            }
        }
        row += 1;
    } else |err| {
        _ = err catch null;
    }

    return Board{
        .numbers = numbers.items,
        .patterns = patterns.items,
    };
}
