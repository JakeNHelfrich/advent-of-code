const std = @import("std");

pub const Hand = []const u8;
pub const HandType = enum(i32) {
    FiveOfAKind = 7,
    FourOfAKind = 6,
    FullHouse = 5,
    ThreeOfAKind = 4,
    TwoPair = 3,
    OnePair = 2,
    HighCard = 1,
};

pub fn classifyHand(hand: Hand, alloc: std.mem.Allocator) !HandType {
    var uniqueCards = std.AutoArrayHashMap(u8, i32).init(alloc);
    for (hand) |card| {
        const currentCount = uniqueCards.get(card) orelse 0;
        try uniqueCards.put(card, currentCount + 1);
    }
    uniqueCards.sort(HandSortingCtx{ .entries = uniqueCards.unmanaged.entries });
    const sortedHand = uniqueCards.unmanaged.entries.items(.value);

    return switch (sortedHand.len) {
        1 => HandType.FiveOfAKind,
        2 => if (sortedHand[0] == 4) HandType.FourOfAKind else HandType.FullHouse,
        3 => if (sortedHand[0] == 3) HandType.ThreeOfAKind else HandType.TwoPair,
        4 => HandType.OnePair,
        else => HandType.HighCard,
    };
}

const HandSortingCtx = struct {
    entries: std.AutoArrayHashMap(u8, i32).DataList,

    pub fn lessThan(ctx: @This(), a_index: usize, b_index: usize) bool {
        const a = ctx.entries.get(a_index);
        const b = ctx.entries.get(b_index);
        return b.value < a.value;
    }
};
