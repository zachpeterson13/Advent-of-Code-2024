const std = @import("std");
const helpers = @import("root.zig");

const print = std.debug.print;
const testing = std.testing;
const split = std.mem.splitScalar;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    const fileInput = @embedFile("input.txt");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    helpers.printHead(" Part 1 ", 80);
    const r1 = try part1(fileInput, true, allocator);
    print("Middles added up = {}\n", .{r1});
}

fn part1(input: []const u8, windows: bool, allocator: Allocator) !isize {
    const parsedInput = try helpers.parseInput(input, windows, allocator);

    const rules = try helpers.parseLines(parsedInput[0], windows, allocator);
    const updates = try helpers.parseLines(parsedInput[1], windows, allocator);

    const convertedRules = try helpers.convertRules(rules, allocator);
    const convertedUpdates = try helpers.convertUpdates(updates, allocator);

    defer {
        allocator.free(parsedInput);

        allocator.free(rules);
        allocator.free(updates);

        allocator.free(convertedRules);
        for (convertedUpdates) |value| {
            allocator.free(value);
        }
        allocator.free(convertedUpdates);
    }

    var sum: isize = 0;
    for (convertedUpdates) |update| {
        const result = try checkOrder(update, convertedRules, allocator);

        sum += result;
    }

    return sum;
}

fn checkOrder(update: []const isize, rules: []const struct { isize, isize }, allocator: Allocator) !isize {
    var map = std.AutoHashMap(isize, usize).init(allocator);
    defer map.deinit();

    for (update, 0..) |num, i| {
        try map.put(num, i);
    }

    for (rules) |rule| {
        const first = map.get(rule[0]) orelse continue;
        const second = map.get(rule[1]) orelse continue;

        if (first >= second) {
            return 0;
        }
    }

    return update[update.len / 2];
}

test "part 1" {
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

    const expected = 143;

    const actual = try part1(testInput, false, testAllocator);

    try testing.expectEqual(expected, actual);
}
