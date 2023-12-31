const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();
    var buffer = std.ArrayList(u8).init(std.heap.page_allocator);

    var sum: i128 = 0;
    while (reader.streamUntilDelimiter(buffer.writer(), '\n', null)) : (buffer.clearAndFree()) {
        const line = buffer.items;

        var numbers = std.ArrayList(i128).init(std.heap.page_allocator);
        var char_iterator = std.mem.splitSequence(u8, line, " ");

        while (char_iterator.next()) |char| {
            const number: i128 = try std.fmt.parseInt(i32, char, 10);
            try numbers.append(number);
        }

        const predicetedNumber: i128 = try predictNextNumber(std.heap.page_allocator, numbers.items);
        sum += predicetedNumber;
    } else |err| {
        _ = err catch null;
    }

    std.debug.print("Sum: {d} \n", .{sum});
}

fn predictNextNumber(allocator: std.mem.Allocator, starting_sequence: []i128) !i128 {
    var last_sequence: []i128 = starting_sequence;
    var next_sequence = std.ArrayList(i128).init(allocator);
    var origin_numbers = std.ArrayList(i128).init(allocator);
    try origin_numbers.append(last_sequence[0]);
    var extrapolate_numbers = std.ArrayList(i128).init(allocator);

    while (blk: {
        var sum: i128 = 0;
        for (last_sequence) |num| {
            if (num != 0) sum += 1;
        }
        break :blk sum;
    } != 0) : ({
        next_sequence.clearAndFree();
        try origin_numbers.insert(0, last_sequence[0]);
    }) {
        for (last_sequence[1..], 1..) |num, index| {
            const prev_number = last_sequence[index - 1];
            const diff = num - prev_number;
            try next_sequence.append(diff);
        }

        last_sequence = try next_sequence.toOwnedSlice();
    }

    try extrapolate_numbers.append(0);
    for (origin_numbers.items, 0..) |num, ind| {
        const new_num: i128 = num - extrapolate_numbers.items[ind];
        //std.debug.print("origin number: {d}, extrapolated number: {d}, new num: {d} \n", .{ num, extrapolate_numbers.items[ind], new_num });
        try extrapolate_numbers.append(new_num);
    }

    return extrapolate_numbers.getLast();
}
