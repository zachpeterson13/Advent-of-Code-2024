const std = @import("std");

const testing = std.testing;
const splitSeq = std.mem.splitSequence;
const split = std.mem.splitScalar;
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

    var it = splitSeq(u8, input, if (windows) "\r\n\r\n" else "\n\n");
    while (it.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        try list.append(line);
    }

    return try list.toOwnedSlice();
}

pub fn parseLines(input: []const u8, windows: bool, allocator: Allocator) ![][]const u8 {
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

pub fn convertRules(rules: [][]const u8, allocator: Allocator) ![]const struct { isize, isize } {
    var list = ArrayList(struct { isize, isize }).init(allocator);
    defer list.deinit();

    for (rules) |rule| {
        var it = split(u8, rule, '|');

        const first = it.next().?;

        if (std.mem.eql(u8, first, "")) {
            break;
        }

        const second = it.next().?;

        const num1 = try std.fmt.parseInt(isize, first, 10);
        const num2 = try std.fmt.parseInt(isize, second, 10);

        try list.append(.{ num1, num2 });
    }

    return try list.toOwnedSlice();
}

pub fn convertUpdates(updates: [][]const u8, allocator: Allocator) ![][]const isize {
    var list = ArrayList([]const isize).init(allocator);
    defer list.deinit();

    for (updates) |update| {
        var it = split(u8, update, ',');
        var innerList = ArrayList(isize).init(allocator);

        while (it.next()) |numStr| {
            const num = try std.fmt.parseInt(isize, numStr, 10);

            try innerList.append(num);
        }

        try list.append(try innerList.toOwnedSlice());
    }

    return try list.toOwnedSlice();
}

test "test parseInput" {
    const testAllocator = testing.allocator;

    const testInput =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;

    const expected = [_][]const u8{
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        ,
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    };

    const actual = try parseInput(testInput, false, testAllocator);

    for (expected, 0..) |value, i| {
        try testing.expectEqualStrings(value, actual[i]);
    }

    testAllocator.free(actual);
}
