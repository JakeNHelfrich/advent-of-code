const std = @import("std");
const hand = @import("./hand.zig");
const HandType = hand.HandType;
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
        return hand.rankCardWithJoker(aCard) catch 1 > hand.rankCardWithJoker(bCard) catch 0;
    }

    return true;
}
