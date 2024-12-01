const std = @import("std");
const input = @embedFile("input.txt");

const ArrayList = std.ArrayList;
const split = std.mem.splitSequence;

pub fn main() !void {
    std.debug.print("{s:=^50}\n", .{""});
    std.debug.print("{s:=^50}\n", .{" Part 1 "});
    std.debug.print("{s:=^50}\n", .{""});

    try part1();

    std.debug.print("{s:=^50}\n", .{""});
    std.debug.print("{s:=^50}\n", .{" Part 2 "});
    std.debug.print("{s:=^50}\n", .{""});

    try part2();
}

pub fn part1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var left_list = ArrayList(isize).init(allocator);
    var right_list = ArrayList(isize).init(allocator);
    defer {
        left_list.deinit();
        right_list.deinit();
    }

    var it = split(u8, input, "\r\n");
    while (it.next()) |line| {
        var it2 = split(u8, line, "   ");

        const first = it2.next().?;
        if (std.mem.eql(u8, first, "")) {
            break;
        }

        const second = it2.next().?;

        const num1 = try std.fmt.parseInt(isize, first, 10);
        const num2 = try std.fmt.parseInt(isize, second, 10);

        try left_list.append(num1);
        try right_list.append(num2);
    }

    const left = try left_list.toOwnedSlice();
    const right = try right_list.toOwnedSlice();
    defer {
        allocator.free(left);
        allocator.free(right);
    }

    std.mem.sort(isize, left, {}, comptime std.sort.asc(isize));
    std.mem.sort(isize, right, {}, comptime std.sort.asc(isize));

    var sum: usize = 0;

    for (left, 0..) |_, index| {
        const diff = @abs(left[index] - right[index]);

        sum += diff;
    }

    std.debug.print("Total distance between lists: {d}\n\n", .{sum});
}

pub fn part2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var left_list = ArrayList(isize).init(allocator);
    var right_list = ArrayList(isize).init(allocator);
    defer {
        left_list.deinit();
        right_list.deinit();
    }

    var it = split(u8, input, "\r\n");
    while (it.next()) |line| {
        var it2 = split(u8, line, "   ");

        const first = it2.next().?;
        if (std.mem.eql(u8, first, "")) {
            break;
        }

        const second = it2.next().?;

        const num1 = try std.fmt.parseInt(isize, first, 10);
        const num2 = try std.fmt.parseInt(isize, second, 10);

        try left_list.append(num1);
        try right_list.append(num2);
    }

    var map = std.AutoHashMap(isize, isize).init(allocator);
    defer map.deinit();

    for (right_list.items) |num| {
        const count = map.get(num) orelse 0;

        try map.put(num, count + 1);
    }

    var sum: isize = 0;

    for (left_list.items) |num| {
        const count = map.get(num) orelse 0;

        sum += (num * count);
    }

    std.debug.print("Similarity score: {d}\n\n", .{sum});
}
