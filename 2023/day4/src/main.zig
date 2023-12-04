const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();

    var sum: i32 = 0;
    while (parseNextCard(reader)) |card| {
        var winningNumbersIterator = card.winningNumbers.iterator();
        var numMatches: i32 = 0;
        while (winningNumbersIterator.next()) |winningNumberEntry| {
            const winningNumber: i32 = winningNumberEntry.key_ptr.*;
            if (card.scratchedNumbers.contains(winningNumber)) {
                numMatches += 1;
            }
        }
        if (numMatches > 0) {
            sum += std.math.pow(i32, 2, numMatches - 1);
        }
    } else |err| {
        _ = err catch null;
    }

    std.debug.print("Pile of Cards value = {d} \n", .{sum});
}

const Card = struct {
    winningNumbers: std.AutoArrayHashMap(i32, i32),
    scratchedNumbers: std.AutoArrayHashMap(i32, i32),
};

fn parseNextCard(reader: anytype) !Card {
    var buffer = std.ArrayList(u8).init(std.heap.page_allocator);
    defer buffer.deinit();

    try reader.streamUntilDelimiter(buffer.writer(), '\n', null);

    var cardLine = std.mem.splitSequence(u8, buffer.items, ": ");

    _ = cardLine.first();

    var numberInfo: []const u8 = cardLine.rest();
    var numberInfoIter = std.mem.split(u8, numberInfo, " | ");

    var winningNumbersInfo = numberInfoIter.first();
    var winningNumbersInfoIter = std.mem.tokenizeSequence(u8, winningNumbersInfo, " ");
    var winningNumbers = std.AutoArrayHashMap(i32, i32).init(std.heap.page_allocator);
    while (winningNumbersInfoIter.next()) |winningNumberString| {
        var winningNumber: i32 = try std.fmt.parseInt(i32, winningNumberString, 10);
        try winningNumbers.put(winningNumber, 1);
    }

    var scratchedNumbersInfo = numberInfoIter.rest();
    var scratchedNumbersInfoIter = std.mem.tokenizeSequence(u8, scratchedNumbersInfo, " ");
    var scratchedNumbers = std.AutoArrayHashMap(i32, i32).init(std.heap.page_allocator);
    while (scratchedNumbersInfoIter.next()) |scratchedNumberString| {
        var scratchedNumber: i32 = try std.fmt.parseInt(i32, scratchedNumberString, 10);
        try scratchedNumbers.put(scratchedNumber, 1);
    }

    return Card{
        .winningNumbers = winningNumbers,
        .scratchedNumbers = scratchedNumbers,
    };
}
