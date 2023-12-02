const std = @import("std");
const fs = std.fs;

pub fn main() !void {
    var file = try fs.cwd().openFile("input.txt", fs.File.OpenFlags{ .mode = .read_only });
    defer file.close();
    var reader = file.reader();

    var arraylist = std.ArrayList(u8).init(std.heap.page_allocator);

    try reader.streamUntilDelimiter(arraylist.writer(), '\n', null);

    var sum: i32 = 0;

    while (arraylist.items.len > 0) {
        var str: []u8 = arraylist.items;
        std.debug.print("{s} \n", .{str});

        var i: usize = 0;
        var j: usize = str.len - 1;
        var value: i32 = 0;

        while (i <= j) {
            var ii: i32 = std.fmt.charToDigit(str[i], 10) catch 0;
            var jj: i32 = std.fmt.charToDigit(str[j], 10) catch 0;

            if (ii == 0) {
                i = i + 1;
            }
            if (jj == 0) {
                j = j - 1;
            }

            if (ii > 0 and jj > 0) {
                value = ii * 10 + jj;
                break;
            }
        }

        sum = sum + value;

        arraylist.clearAndFree();
        reader.streamUntilDelimiter(arraylist.writer(), '\n', null) catch break;
    }

    std.debug.print("Final Sum: {d}\n", .{sum});
}
