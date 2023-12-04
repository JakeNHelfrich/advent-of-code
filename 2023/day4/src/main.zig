const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();

    const card: Card = try parseNextCard(reader);
    const winningNumber: bool = card.winningNumbers.contains(41);
    const scratchedNumber: bool = card.scratchedNumbers.contains(83);
    std.debug.print("Card {d}| {d} {d}\n", .{ card.number, @intFromBool(winningNumber), @intFromBool(scratchedNumber) });
}

const Card = struct {
    number: i32,
    winningNumbers: std.AutoArrayHashMap(i32, i32),
    scratchedNumbers: std.AutoArrayHashMap(i32, i32),
};

fn parseNextCard(reader: anytype) !Card {
    var buffer = std.ArrayList(u8).init(std.heap.page_allocator);
    defer buffer.deinit();

    try reader.streamUntilDelimiter(buffer.writer(), '\n', null);

    var cardLine = std.mem.splitSequence(u8, buffer.items, ": ");

    var cardInfo: []const u8 = cardLine.first();
    var cardInfoIter = std.mem.splitSequence(u8, cardInfo, " ");
    _ = cardInfoIter.first();
    var cardNumber = try std.fmt.parseInt(i32, cardInfoIter.rest(), 10);

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
        .number = cardNumber,
        .winningNumbers = winningNumbers,
        .scratchedNumbers = scratchedNumbers,
    };
}
