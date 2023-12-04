const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();

    var cards = std.ArrayList(Card).init(std.heap.page_allocator);
    while (parseNextCard(reader)) |card| {
        try cards.append(card);
    } else |err| {
        _ = err catch null;
    }

    var sum: i32 = 0;
    //part 1
    for (cards.items) |card| {
        var numMatches = calculateMatchingNumbers(card);
        if (numMatches > 0) {
            sum += std.math.pow(i32, 2, numMatches - 1);
        }
    }

    std.debug.print("Pile of Cards value = {d} \n", .{sum});

    //part 2
    var sumClones: i32 = 0;
    var cardClones = std.AutoHashMap(i32, i32).init(std.heap.page_allocator);
    for (cards.items, 1..) |card, cardNumberUsize| {
        var cardNumber: i32 = @intCast(cardNumberUsize);
        var numClones: i32 = cardClones.get(cardNumber) orelse 0;
        var numWinnings = calculateMatchingNumbers(card);
        try cardClones.put(cardNumber, numClones + 1);

        var num: i32 = 1;
        while (num <= numWinnings) : (num += 1) {
            var cardNumberToAdd = cardNumber + num;
            var numClonesToAdd = cardClones.get(cardNumberToAdd) orelse 0;
            try cardClones.put(cardNumberToAdd, numClonesToAdd + (numClones + 1));
        }
    }

    var iter = cardClones.valueIterator();
    while (iter.next()) |entry| {
        var count = entry.*;
        sumClones += count;
    }
    std.debug.print("Total Number of Cloned Cards : {d} \n", .{sumClones});
}

const Card = struct {
    winningNumbers: std.AutoArrayHashMap(i32, i32),
    scratchedNumbers: std.AutoArrayHashMap(i32, i32),
};

fn calculateMatchingNumbers(card: Card) i32 {
    var winningNumbersIterator = card.winningNumbers.iterator();
    var numMatches: i32 = 0;
    while (winningNumbersIterator.next()) |winningNumberEntry| {
        const winningNumber: i32 = winningNumberEntry.key_ptr.*;
        if (card.scratchedNumbers.contains(winningNumber)) {
            numMatches += 1;
        }
    }
    return numMatches;
}

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
