const std = @import("std");

const testing = std.testing;
const splitSeq = std.mem.splitSequence;
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

pub fn printHead(str: []const u8, comptime width: usize) void {
    const fmt1 = comptime std.fmt.comptimePrint("{{s:=^{}}}\n", .{width});
    const fmt2 = comptime std.fmt.comptimePrint("{{s:-^{}}}\n", .{width});

    std.debug.print(fmt1, .{""});
    std.debug.print(fmt2, .{str});
    std.debug.print(fmt1, .{""});
}

pub fn parseInput(input: []const u8, windows: bool, allocator: Allocator) ![][]const u8 {
    var list = ArrayList([]const u8).init(allocator);
    defer list.deinit();

    var it = splitSeq(u8, input, if (windows) "\r\n" else "\n");
    while (it.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        try list.append(line);
    }

    return try list.toOwnedSlice();
}

test "test parseInput" {
    const testAllocator = testing.allocator;

    const testInput =
        \\....#.....
        \\.........#
        \\..........
        \\..#.......
        \\.......#..
        \\..........
        \\.#..^.....
        \\........#.
        \\#.........
        \\......#...
    ;

    const expected = [_][]const u8{
        \\....#.....
        ,
        \\.........#
        ,
        \\..........
        ,
        \\..#.......
        ,
        \\.......#..
        ,
        \\..........
        ,
        \\.#..^.....
        ,
        \\........#.
        ,
        \\#.........
        ,
        \\......#...
    };

    const actual = try parseInput(testInput, false, testAllocator);

    for (expected, 0..) |value, i| {
        try testing.expectEqualStrings(value, actual[i]);
    }

    testAllocator.free(actual);
}
