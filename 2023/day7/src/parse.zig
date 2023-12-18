const std = @import("std");
const handUtils = @import("./hand.zig");

pub const CamelCardGame = []Play;
pub const Bid = i32;
pub const Play = struct {
    hand: handUtils.Hand,
    type: handUtils.HandType,
    bid: Bid,
};

pub fn parseGame(reader: anytype, alloc: std.mem.Allocator) !CamelCardGame {
    var game = std.ArrayList(Play).init(alloc);

    var buffer = std.ArrayList(u8).init(alloc);
    while (reader.streamUntilDelimiter(buffer.writer(), '\n', null)) : (buffer.clearAndFree()) {
        const line = try buffer.toOwnedSlice();
        var lineIter = std.mem.tokenizeSequence(u8, line, " ");
        const hand: []const u8 = std.mem.trim(u8, lineIter.next().?, "\x00");
        const bidStr = std.mem.trim(u8, lineIter.next().?, "\x00");

        if (hand.len != 5) {
            return error.HandTooLarge;
        }

        const bid = try std.fmt.parseInt(Bid, bidStr, 10);

        const play = Play{
            .hand = hand,
            .type = try handUtils.classifyHand(hand, alloc),
            .bid = bid,
        };

        try game.append(play);
    } else |err| {
        _ = err catch null;
    }

    return game.items;
}
