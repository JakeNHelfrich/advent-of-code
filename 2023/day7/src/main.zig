const std = @import("std");
const HandType = @import("./hand.zig").HandType;
const parse = @import("./parse.zig");
const print = std.debug.print;

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();
    const game = try parse.parseGame(reader, std.heap.page_allocator);

    std.mem.sort(parse.Play, game, {}, sortHands);

    var sum: i128 = 0;
    for (0..game.len) |ind| {
        const play = game[ind];
        const mult = @as(i32, @intCast(game.len - ind));
        sum += play.bid * mult;
    }
    std.debug.print("Total Winnings: {d} \n", .{sum});
}

fn sortHands(ctx: void, a: parse.Play, b: parse.Play) bool {
    _ = ctx;
    const aInt = @intFromEnum(a.type);
    const bInt = @intFromEnum(b.type);

    if (aInt != bInt) return aInt > bInt;

    for (0..5) |ind| {
        const aCard = a.hand[ind];
        const bCard = b.hand[ind];
        if (aCard == bCard) continue;
        return rankCard(aCard) catch 1 > rankCard(bCard) catch 0;
    }

    return true;
}

fn rankCard(card: u8) !u8 {
    return switch (card) {
        'A' => 14,
        'K' => 13,
        'Q' => 12,
        'J' => 11,
        'T' => 10,
        else => std.fmt.charToDigit(card, 10),
    };
}
