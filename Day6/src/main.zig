const std = @import("std");

const helpers = @import("root.zig");

const print = std.debug.print;
const testing = std.testing;
const split = std.mem.splitScalar;
const Allocator = std.mem.Allocator;

const Dir = enum { north, south, east, west };
const Pos = struct { row: isize, col: isize };

pub fn main() !void {
    const fileInput = @embedFile("input.txt");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    helpers.printHead(" Part 1 ", 80);
    const r1 = try part1(fileInput, true, allocator);
    print("The guard will visit {} distinct positions.\n", .{r1});
}

fn part1(input: []const u8, windows: bool, allocator: Allocator) !usize {
    const grid = try helpers.parseInput(input, windows, allocator);
    defer allocator.free(grid);

    var visited = std.AutoHashMap(Pos, usize).init(allocator);
    defer visited.deinit();

    const startPos = findStart(grid).?;
    const startDir = Dir.north;

    var current: ?struct { Pos, Dir } = .{ startPos, startDir };

    while (current != null) {
        const temp = visited.get(current.?[0]) orelse 0;
        try visited.put(current.?[0], temp + 1);
        current = step(grid, current.?[0], current.?[1]);
    }

    return visited.count();
}

fn findStart(grid: [][]const u8) ?Pos {
    for (grid, 0..) |row, i| {
        for (row, 0..) |col, j| {
            if (col == '^') {
                return Pos{ .row = @intCast(i), .col = @intCast(j) };
            }
        }
    }

    return null;
}

fn step(grid: [][]const u8, pos: Pos, dir: Dir) ?struct { Pos, Dir } {
    const nextPos: Pos = switch (dir) {
        Dir.north => Pos{ .col = pos.col, .row = pos.row - 1 },
        Dir.east => Pos{ .col = pos.col + 1, .row = pos.row },
        Dir.south => Pos{ .col = pos.col, .row = pos.row + 1 },
        Dir.west => Pos{ .col = pos.col - 1, .row = pos.row },
    };

    const next = get(grid, nextPos);

    if (next == null) {
        return null;
    } else if (next.? == '#') {
        return step(grid, pos, turnRight(dir));
    } else {
        return .{ nextPos, dir };
    }
}

fn get(grid: [][]const u8, pos: Pos) ?u8 {
    if (pos.col > grid[0].len - 1 or pos.col < 0 or pos.row > grid.len - 1 or pos.row < 0) {
        return null;
    }

    const row: usize = @intCast(pos.row);
    const col: usize = @intCast(pos.col);

    return grid[row][col];
}

fn turnRight(dir: Dir) Dir {
    return switch (dir) {
        Dir.north => Dir.east,
        Dir.east => Dir.south,
        Dir.south => Dir.west,
        Dir.west => Dir.north,
    };
}

test "Part 1" {
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

    const expected = 41;

    const actual = try part1(testInput, false, testAllocator);

    try testing.expectEqual(expected, actual);
}
