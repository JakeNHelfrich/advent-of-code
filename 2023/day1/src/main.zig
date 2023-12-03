const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    const file = try fs.cwd().openFile("input.txt", fs.File.OpenFlags{ .mode = .read_only });
    defer file.close();

    const reader = file.reader();
    var arraylist: std.ArrayList(u8) = std.ArrayList(u8).init(std.heap.page_allocator);
    var sum: i32 = 0;

    while (readNextLineArrayList(reader, &arraylist)) {
        var instruction: []const u8 = arraylist.items;
        sum = sum + calculateConfigurationValue(instruction);
    }

    std.debug.print("Final Sum: {d}\n", .{sum});
}

fn readNextLineArrayList(reader: std.fs.File.Reader, arrayList: *std.ArrayList(u8)) bool {
    arrayList.clearAndFree();
    reader.streamUntilDelimiter(arrayList.writer(), '\n', null) catch return false;
    return true;
}

fn calculateConfigurationValue(instruction: []const u8) i32 {
    var i: usize = 0;
    var j: usize = instruction.len - 1;

    while (i <= j) {
        var ii: i32 = std.fmt.charToDigit(instruction[i], 10) catch 0;
        var jj: i32 = std.fmt.charToDigit(instruction[j], 10) catch 0;

        if (ii == 0) {
            i = i + 1;
        }
        if (jj == 0) {
            j = j - 1;
        }

        if (ii > 0 and jj > 0) {
            return ii * 10 + jj;
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
