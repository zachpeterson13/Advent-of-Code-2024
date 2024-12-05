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
    print("XMAS appears {} times.\n", .{r1});

    helpers.printHead(" Part 2 ", 80);
    const r2 = try part2(fileInput, true, allocator);
    print("X-MAS appears {} times.\n", .{r2});
}

fn part1(input: []const u8, windows: bool, allocator: Allocator) !usize {
    const parsedInput = try helpers.parseInput(input, windows, allocator);
    defer allocator.free(parsedInput);

    var sum: usize = 0;

    for (parsedInput, 0..) |line, i| {
        for (line, 0..) |char, j| {
            if (char == 'X') {
                sum += try checkCoords(parsedInput, i, j);
            }
        }
    }

    return sum;
}

fn part2(input: []const u8, windows: bool, allocator: Allocator) !usize {
    const parsedInput = try helpers.parseInput(input, windows, allocator);
    defer allocator.free(parsedInput);

    var sum: usize = 0;

    for (parsedInput, 0..) |line, i| {
        for (line, 0..) |char, j| {
            if (char == 'A') {
                sum += if (try checkXmas(parsedInput, i, j)) 1 else 0;
            }
        }
    }

    return sum;
}

fn checkXmas(input: [][]const u8, col: usize, row: usize) !bool {
    const left: isize = @intCast(row);
    const up: isize = @intCast(col);

    if (left - 1 < 0) {
        return false;
    }

    if (left + 1 > input[0].len - 1) {
        return false;
    }

    if (up - 1 < 0) {
        return false;
    }
    if (up + 1 > input.len - 1) {
        return false;
    }

    const topLeft = input[col - 1][row - 1];
    const topRight = input[col - 1][row + 1];
    const bottomLeft = input[col + 1][row - 1];
    const bottomRight = input[col + 1][row + 1];

    // check if top left is 'M' or 'S' and then same for bottom right and !topLeft
    const tl = topLeft == 'M' or topLeft == 'S';
    const br = bottomRight == 'M' or bottomRight == 'S';
    const tlbr = tl and br and topLeft != bottomRight;

    //check if top right is 'M' or 'S' and the same for bottom left and !topRight
    const tr = topRight == 'M' or topRight == 'S';
    const bl = bottomLeft == 'M' or bottomLeft == 'S';
    const trbl = tr and bl and topRight != bottomLeft;

    return tlbr and trbl;
}

// checks the coords for XMAS in all directions and return how many there were
fn checkCoords(input: [][]const u8, col: usize, row: usize) !usize {
    var sum: usize = 0;

    if (checkFwd(input, col, row)) {
        sum += 1;
    }

    if (checkBwd(input, col, row)) {
        sum += 1;
    }

    if (checkDwn(input, col, row)) {
        sum += 1;
    }

    if (checkUp(input, col, row)) {
        sum += 1;
    }

    if (checkUpFwd(input, col, row)) {
        sum += 1;
    }

    if (checkUpBwd(input, col, row)) {
        sum += 1;
    }

    if (checkDwnFwd(input, col, row)) {
        sum += 1;
    }

    if (checkDwnBwd(input, col, row)) {
        sum += 1;
    }

    return sum;
}

fn checkFwd(input: [][]const u8, col: usize, row: usize) bool {
    if (row + 3 > input[0].len - 1) {
        return false;
    }

    return std.mem.eql(u8, input[col][row .. row + 4], "XMAS");
}

fn checkBwd(input: [][]const u8, col: usize, row: usize) bool {
    const left: isize = @intCast(row);
    if (left - 3 < 0) {
        return false;
    }

    return std.mem.eql(u8, input[col][row - 3 .. row + 1], "SAMX");
}

fn checkDwn(input: [][]const u8, col: usize, row: usize) bool {
    if (col + 3 > input.len - 1) {
        return false;
    }

    if (input[col][row] != 'X') {
        return false;
    }

    if (input[col + 1][row] != 'M') {
        return false;
    }

    if (input[col + 2][row] != 'A') {
        return false;
    }

    if (input[col + 3][row] != 'S') {
        return false;
    }

    return true;
}

fn checkUp(input: [][]const u8, col: usize, row: usize) bool {
    const upper: isize = @intCast(col);
    if (upper - 3 < 0) {
        return false;
    }

    if (input[col][row] != 'X') {
        return false;
    }

    if (input[col - 1][row] != 'M') {
        return false;
    }

    if (input[col - 2][row] != 'A') {
        return false;
    }

    if (input[col - 3][row] != 'S') {
        return false;
    }

    return true;
}

fn checkDwnFwd(input: [][]const u8, col: usize, row: usize) bool {
    if (row + 3 > input[0].len - 1 or col + 3 > input.len - 1) {
        return false;
    }

    if (input[col][row] != 'X') {
        return false;
    }

    if (input[col + 1][row + 1] != 'M') {
        return false;
    }

    if (input[col + 2][row + 2] != 'A') {
        return false;
    }

    if (input[col + 3][row + 3] != 'S') {
        return false;
    }

    return true;
}

fn checkDwnBwd(input: [][]const u8, col: usize, row: usize) bool {
    const left: isize = @intCast(row);
    if (left - 3 < 0 or col + 3 > input.len - 1) {
        return false;
    }

    if (input[col][row] != 'X') {
        return false;
    }

    if (input[col + 1][row - 1] != 'M') {
        return false;
    }

    if (input[col + 2][row - 2] != 'A') {
        return false;
    }

    if (input[col + 3][row - 3] != 'S') {
        return false;
    }

    return true;
}

fn checkUpFwd(input: [][]const u8, col: usize, row: usize) bool {
    const upper: isize = @intCast(col);
    if (row + 3 > input.len - 1 or upper - 3 < 0) {
        return false;
    }

    if (input[col][row] != 'X') {
        return false;
    }

    if (input[col - 1][row + 1] != 'M') {
        return false;
    }

    if (input[col - 2][row + 2] != 'A') {
        return false;
    }

    if (input[col - 3][row + 3] != 'S') {
        return false;
    }

    return true;
}

fn checkUpBwd(input: [][]const u8, col: usize, row: usize) bool {
    const left: isize = @intCast(row);
    const up: isize = @intCast(col);
    if (left - 3 < 0 or up - 3 < 0) {
        return false;
    }

    if (input[col][row] != 'X') {
        return false;
    }

    if (input[col - 1][row - 1] != 'M') {
        return false;
    }

    if (input[col - 2][row - 2] != 'A') {
        return false;
    }

    if (input[col - 3][row - 3] != 'S') {
        return false;
    }

    return true;
}

test "part1" {
    const testAllocator = testing.allocator;

    const testInput =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    const expected = 18;

    const actual = try part1(testInput, false, testAllocator);

    try testing.expectEqual(expected, actual);
}

test "part2" {
    const testAllocator = testing.allocator;

    const testInput =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    const expected = 9;

    const actual = try part2(testInput, false, testAllocator);

    try testing.expectEqual(expected, actual);
}

test "checkFwd" {
    const testAllocator = testing.allocator;

    const testInput =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    const expected1 = true;
    const expected2 = false;
    const expected3 = false;

    const parsedInput = try helpers.parseInput(testInput, false, testAllocator);
    defer testAllocator.free(parsedInput);

    const actual1 = checkFwd(parsedInput, 0, 5);
    const actual2 = checkFwd(parsedInput, 0, 0);
    const actual3 = checkFwd(parsedInput, 0, 10);

    try testing.expectEqual(expected1, actual1);
    try testing.expectEqual(expected2, actual2);
    try testing.expectEqual(expected3, actual3);
}

test "checkBwd" {
    const testAllocator = testing.allocator;

    const testInput =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    const expected1 = true;
    const expected2 = false;

    const parsedInput = try helpers.parseInput(testInput, false, testAllocator);
    defer testAllocator.free(parsedInput);

    const actual1 = checkBwd(parsedInput, 1, 4);
    const actual2 = checkBwd(parsedInput, 1, 9);

    try testing.expectEqual(expected1, actual1);
    try testing.expectEqual(expected2, actual2);
}

test "checkDwn" {
    const testAllocator = testing.allocator;

    const testInput =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    const expected1 = true;
    const expected2 = false;

    const parsedInput = try helpers.parseInput(testInput, false, testAllocator);
    defer testAllocator.free(parsedInput);

    const actual1 = checkDwn(parsedInput, 3, 9);
    const actual2 = checkDwn(parsedInput, 9, 9);

    try testing.expectEqual(expected1, actual1);
    try testing.expectEqual(expected2, actual2);
}

test "checkUp" {
    const testAllocator = testing.allocator;

    const testInput =
        \\MMMSXXMASM
        \\MSAMXMSMSA
        \\AMXSXMAAMM
        \\MSAMASMSMX
        \\XMASAMXAMM
        \\XXAMMXXAMA
        \\SMSMSASXSS
        \\SAXAMASAAA
        \\MAMMMXMMMM
        \\MXMXAXMASX
    ;

    const expected1 = true;
    const expected2 = false;

    const parsedInput = try helpers.parseInput(testInput, false, testAllocator);
    defer testAllocator.free(parsedInput);

    const actual1 = checkUp(parsedInput, 4, 6);
    const actual2 = checkUp(parsedInput, 0, 9);

    try testing.expectEqual(expected1, actual1);
    try testing.expectEqual(expected2, actual2);
}
