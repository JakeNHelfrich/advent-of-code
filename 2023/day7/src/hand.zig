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

pub fn classifyHandWithJokers(hand: Hand, alloc: std.mem.Allocator) !HandType {
    var uniqueCards = std.AutoArrayHashMap(u8, i32).init(alloc);
    for (hand) |card| {
        const currentCount: i32 = uniqueCards.get(card) orelse 0;
        try uniqueCards.put(card, currentCount + 1);
    }
    uniqueCards.sort(JokerHandSortingCtx{ .entries = uniqueCards.unmanaged.entries });

    var sortedHand = uniqueCards.unmanaged.entries.items(.value);

    const jokerCount = uniqueCards.get('J') orelse 0;

    if (jokerCount < 5) {
        _ = uniqueCards.orderedRemove('J');
        sortedHand = uniqueCards.unmanaged.entries.items(.value);

        var i: usize = 0;
        var currCard: usize = 0;
        while (i < jokerCount) : (i += 1) {
            const cardCount = sortedHand[currCard];
            if (cardCount == 5) {
                currCard += 1;
                continue;
            }
            sortedHand[currCard] += 1;
        }
    }

    return switch (sortedHand.len) {
        1 => HandType.FiveOfAKind,
        2 => if (sortedHand[0] == 4) HandType.FourOfAKind else HandType.FullHouse,
        3 => if (sortedHand[0] == 3) HandType.ThreeOfAKind else HandType.TwoPair,
        4 => HandType.OnePair,
        else => HandType.HighCard,
    };
}

pub fn rankCard(card: u8) !u8 {
    return switch (card) {
        'A' => 14,
        'K' => 13,
        'Q' => 12,
        'J' => 11,
        'T' => 10,
        else => std.fmt.charToDigit(card, 10),
    };
}

pub fn rankCardWithJoker(card: u8) !u8 {
    return switch (card) {
        'A' => 14,
        'K' => 13,
        'Q' => 12,
        'J' => 1,
        'T' => 10,
        else => std.fmt.charToDigit(card, 10),
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

const JokerHandSortingCtx = struct {
    entries: std.AutoArrayHashMap(u8, i32).DataList,

    pub fn lessThan(ctx: @This(), a_index: usize, b_index: usize) bool {
        const a = ctx.entries.get(a_index);
        const b = ctx.entries.get(b_index);
        if (b.value == a.value) return rankCardWithJoker(b.key) catch 0 < rankCardWithJoker(a.key) catch 1;
        return b.value < a.value;
    }
};
