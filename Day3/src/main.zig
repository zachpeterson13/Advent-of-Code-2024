const std = @import("std");

const testing = std.testing;
const print = std.debug.print;
const isDigit = std.ascii.isDigit;
const eql = std.mem.eql;

pub fn main() !void {
    const file_input = @embedFile("input.txt");

    printHead(" Part 1 ");
    const result1 = try part1(file_input);
    print("Sum of multiplication: {d}\n\n", .{result1});

    printHead(" Part 2 ");
    const result2 = try part2(file_input);
    print("Sum of enabled multiplications: {d}\n\n", .{result2});
}

fn part1(input: []const u8) !isize {
    var sum: isize = 0;

    for (input, 0..) |char, i| {
        if (char == 'm') {
            sum += try try_multiply(input[i..]);
        }
    }

    return sum;
}

fn part2(input: []const u8) !isize {
    var sum: isize = 0;
    var enabled = true;

    for (input, 0..) |char, i| {
        if (char == 'm' and enabled) {
            sum += try try_multiply(input[i..]);
        } else if (char == 'd') {
            // check for do() or don't(), if neither dont change enabled
            enabled = checkDoDont(input[i..]) orelse enabled;
        }
    }

    return sum;
}

fn printHead(str: []const u8) void {
    std.debug.print("{s:=^50}\n", .{""});
    std.debug.print("{s:=^50}\n", .{str});
    std.debug.print("{s:=^50}\n", .{""});
}

fn try_multiply(slice: []const u8) !isize {
    // if the first 4 chars dont match, then return 0
    if (slice[0] != 'm') {
        return 0;
    }

    if (slice[1] != 'u') {
        return 0;
    }

    if (slice[2] != 'l') {
        return 0;
    }

    if (slice[3] != '(') {
        return 0;
    }

    // loop until comma
    var i: usize = 4;
    while (i < slice.len) {
        if (slice[i] == ',') {
            // break at first comma to "save" index
            break;
        } else if (slice[i] == ' ' or !isDigit(slice[i])) {
            // no spaces or non-digits allowed
            return 0;
        }

        i += 1;
    }

    // loop until ')'
    var j: usize = i + 1;
    while (j < slice.len) {
        if (slice[j] == ')') {
            // break at first comma to "save" index
            break;
        } else if (slice[j] == ' ' or !isDigit(slice[j])) {
            // no spaces or non-digits allowed
            return 0;
        }

        j += 1;
    }

    // print("first = {s}\n", .{slice[4..i]});
    // print("second = {s}\n", .{slice[i + 1 .. j]});

    // now we try and parse both numbers
    const first = std.fmt.parseInt(isize, slice[4..i], 10) catch 0;
    const second = std.fmt.parseInt(isize, slice[i + 1 .. j], 10) catch 0;

    return first * second;
}

// returns true if do(), false if don't(), null otherwise
fn checkDoDont(slice: []const u8) ?bool {
    if (eql(u8, slice[0..4], "do()")) {
        // check for do()
        return true;
    } else if (eql(u8, slice[0..7], "don't()")) {
        // check for don't()
        return false;
    } else {
        // otherwise return null
        return null;
    }
}

test "part 1" {
    const test_input = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";

    const expected = 161;

    const actual = try part1(test_input);

    try testing.expectEqual(expected, actual);
}

test "part 2" {
    const test_input = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";

    const expected = 48;

    const actual = try part2(test_input);

    try testing.expectEqual(expected, actual);
}

test "try_multiply 1" {
    const test_input = "mul(2,4)%&mul[3,7]!@^do_not_mul(5,5)";

    const expected = 8;

    const actual = try try_multiply(test_input);

    try testing.expectEqual(expected, actual);
}

test "try_multiply 2" {
    const test_input = "mul(11,8)mul(8,5)";

    const expected = 11 * 8;

    const actual = try try_multiply(test_input);

    try testing.expectEqual(expected, actual);
}
