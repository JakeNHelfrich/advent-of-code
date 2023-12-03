const std = @import("std");
const fs = std.fs;
const isDigit = std.ascii.isDigit;
const charToDigit = std.fmt.charToDigit;

pub fn main() !void {
    const file = try fs.cwd().openFile("input.txt", fs.File.OpenFlags{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();
    var arraylist: std.ArrayList(u8) = std.ArrayList(u8).init(std.heap.page_allocator);
    var sum: i32 = 0;

    while (reader.streamUntilDelimiter(arraylist.writer(), '\n', null)) {
        var instruction: []const u8 = arraylist.items;
        sum = sum + calculateConfigurationValue(instruction);
        arraylist.clearAndFree();
    } else |err| {
        _ = err catch null;
    }

    std.debug.print("Final Sum: {d}\n", .{sum});
}

fn calculateConfigurationValue(instruction: []const u8) i32 {
    var i: usize = 0;
    var j: usize = instruction.len - 1;

    while (i <= j) {
        const ii = instruction[i];
        const jj = instruction[j];

        if (!isDigit(ii)) {
            i += 1;
        }
        if (!isDigit(jj)) {
            j -= 1;
        }

        if (isDigit(ii) and isDigit(jj)) {
            const a = charToDigit(ii, 10) catch 0;
            const b = charToDigit(jj, 10) catch 0;
            return a * 10 + b;
        }
    }
    return 0;
}

test "Testing Calculate Configuration value" {
    var instructions = std.ArrayList([]const u8).init(std.heap.page_allocator);
    try instructions.append("3qcfxgzsevenone1rv");
    try instructions.append("nine91threepdcthjkmrthreeeightwonsg");
    try instructions.append("sqrfkncdk3");
    try instructions.append("635jksvjvndtxbkksznrbnine");

    const expected = [_]i32{ 31, 91, 33, 65 };
    for (instructions.items, 0..) |instruction, ind| {
        const configurationValue = calculateConfigurationValue(instruction);
        try std.testing.expect(configurationValue == expected[ind]);
    }
}
