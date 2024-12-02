const std = @import("std");

const testing = std.testing;
const print = std.debug.print;
const split = std.mem.splitScalar;
const splitSequence = std.mem.splitSequence;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const file_input = @embedFile("input.txt");

    printHead(" Part 1 ");
    try part1(file_input, true);
    print("\n", .{});

    printHead(" Part 2 ");
    try part2(file_input, true);
    print("\n", .{});
}

fn part1(input: []const u8, windows: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var list = ArrayList(ArrayList(isize)).init(allocator);
    defer {
        for (list.items) |inner| {
            inner.deinit();
        }

        list.deinit();
    }

    const delimiter = if (windows) "\r\n" else "\n";

    var it = splitSequence(u8, input, delimiter);
    while (it.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        var inner = ArrayList(isize).init(allocator);

        var it2 = split(u8, line, ' ');
        while (it2.next()) |numstr| {
            const num = try std.fmt.parseInt(isize, numstr, 10);
            try inner.append(num);
        }

        try list.append(inner);
    }

    var sum: isize = 0;

    for (list.items) |inner| {
        if (isSafe(inner.items)) {
            sum += 1;
        }
    }

    print("{d} reports are safe\n", .{sum});
}

fn part2(input: []const u8, windows: bool) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var list = ArrayList(ArrayList(isize)).init(allocator);
    defer {
        for (list.items) |inner| {
            inner.deinit();
        }

        list.deinit();
    }

    const delimiter = if (windows) "\r\n" else "\n";

    var it = splitSequence(u8, input, delimiter);
    while (it.next()) |line| {
        if (std.mem.eql(u8, line, "")) {
            break;
        }

        var inner = ArrayList(isize).init(allocator);

        var it2 = split(u8, line, ' ');
        while (it2.next()) |numstr| {
            const num = try std.fmt.parseInt(isize, numstr, 10);
            try inner.append(num);
        }

        try list.append(inner);
    }

    var sum: isize = 0;

    for (list.items) |inner| {
        if (try isSafe2(inner)) {
            sum += 1;
        }
    }

    print("{d} reports are safe\n", .{sum});
}

fn printHead(str: []const u8) void {
    std.debug.print("{s:=^50}\n", .{""});
    std.debug.print("{s:=^50}\n", .{str});
    std.debug.print("{s:=^50}\n", .{""});
}

fn isSafe(values: []const isize) bool {
    var increasing: ?bool = null;

    for (0..values.len - 1) |i| {
        const diff = values[i] - values[i + 1];
        const amt = @abs(diff);
        var new_increasing: bool = false;

        // any 2 adjacent levels may differ by at least one and at most 3
        if (amt == 0 or amt > 3) {
            return false;
        }

        // check if we are increasing/decreasing
        if (diff > 0) {
            new_increasing = false;
        } else {
            new_increasing = true;
        }

        // compare to last iteration to make sure we are strictly increasing/decreasing
        if (increasing == null) {
            // first iteration
            increasing = new_increasing;
            continue;
        } else if (increasing != new_increasing) {
            return false;
        }

        increasing = new_increasing;
    }

    return true;
}

fn isSafe2(valuesList: ArrayList(isize)) !bool {
    var increasing: ?bool = null;

    const values = valuesList.items;

    for (0..values.len - 1) |i| {
        const diff = values[i] - values[i + 1];
        const amt = @abs(diff);
        var new_increasing: bool = false;

        // any 2 adjacent levels may differ by at least one and at most 3
        if (amt == 0 or amt > 3) {
            var without = try valuesList.clone();
            var withoutNext = try valuesList.clone();

            defer {
                without.deinit();
                withoutNext.deinit();
            }

            _ = without.orderedRemove(i);
            _ = withoutNext.orderedRemove(i + 1);

            return isSafe(without.items) or isSafe(withoutNext.items);
        }

        // check if we are increasing/decreasing
        if (diff > 0) {
            new_increasing = false;
        } else {
            new_increasing = true;
        }

        // compare to last iteration to make sure we are strictly increasing/decreasing
        if (increasing == null) {
            // first iteration
            increasing = new_increasing;
            continue;
        } else if (increasing != new_increasing) {
            var without = try valuesList.clone();
            var withoutNext = try valuesList.clone();

            defer {
                without.deinit();
                withoutNext.deinit();
            }

            _ = without.orderedRemove(i);
            _ = withoutNext.orderedRemove(i + 1);

            return isSafe(without.items) or isSafe(withoutNext.items);
        }

        increasing = new_increasing;
    }

    return true;
}

test "isSafe test" {
    try testing.expect(isSafe(&[_]isize{ 7, 6, 4, 2, 1 }) == true);
    try testing.expect(isSafe(&[_]isize{ 1, 2, 7, 8, 9 }) == false);
    try testing.expect(isSafe(&[_]isize{ 9, 7, 6, 2, 1 }) == false);
    try testing.expect(isSafe(&[_]isize{ 1, 3, 2, 4, 5 }) == false);
    try testing.expect(isSafe(&[_]isize{ 8, 6, 4, 4, 1 }) == false);
    try testing.expect(isSafe(&[_]isize{ 1, 3, 6, 7, 9 }) == true);
}

test "isSafe2 test" {
    const test_allocator = std.testing.allocator;
    var list1 = ArrayList(isize).init(test_allocator);
    var list2 = ArrayList(isize).init(test_allocator);
    var list3 = ArrayList(isize).init(test_allocator);
    var list4 = ArrayList(isize).init(test_allocator);
    var list5 = ArrayList(isize).init(test_allocator);
    var list6 = ArrayList(isize).init(test_allocator);

    defer {
        list1.deinit();
        list2.deinit();
        list3.deinit();
        list4.deinit();
        list5.deinit();
        list6.deinit();
    }

    try list1.appendSlice(&[_]isize{ 7, 6, 4, 2, 1 });
    try list2.appendSlice(&[_]isize{ 1, 2, 7, 8, 9 });
    try list3.appendSlice(&[_]isize{ 9, 7, 6, 2, 1 });
    try list4.appendSlice(&[_]isize{ 1, 3, 2, 4, 5 });
    try list5.appendSlice(&[_]isize{ 8, 6, 4, 4, 1 });
    try list6.appendSlice(&[_]isize{ 1, 3, 6, 7, 9 });

    try testing.expect(try isSafe2(list1) == true);
    try testing.expect(try isSafe2(list2) == false);
    try testing.expect(try isSafe2(list3) == false);
    try testing.expect(try isSafe2(list4) == true);
    try testing.expect(try isSafe2(list5) == true);
    try testing.expect(try isSafe2(list6) == true);
}

test "part1 test" {
    const test_input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;

    try part1(test_input, false);
}

test "part2 test" {
    const test_input =
        \\7 6 4 2 1
        \\1 2 7 8 9
        \\9 7 6 2 1
        \\1 3 2 4 5
        \\8 6 4 4 1
        \\1 3 6 7 9
    ;

    try part2(test_input, false);
}
