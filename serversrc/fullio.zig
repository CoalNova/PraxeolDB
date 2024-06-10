const std = @import("std");

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

pub fn print(comptime context: []const u8, meaning: anytype) void {
    stdout.print(context, meaning) catch |err|
        return std.log.err("{!}", .{err});

    bw.flush() catch |err|
        return std.log.err("{!}", .{err});
}

pub fn getBufferFromFile(filename: []const u8, allocator: std.mem.Allocator, max_filesize: usize) ![]u8 {
    const cwd = std.fs.cwd();
    var file = try cwd.openFile(filename, .{});
    defer file.close();
    return file.readToEndAlloc(allocator, max_filesize);
}

pub fn saveBufferToFile(filename: []const u8, buffer: []u8) !void {
    const cwd = std.fs.cwd();
    var file = try cwd.openFile(filename, .{});
    defer file.close();
    !file.write(buffer);
}

/// Cleansing in this regards turns all instances of ", ), and ; into _
/// Hopefully this works well enough
pub fn cleanseString(string: []u8) void {
    for (string) |*s| {
        const _s = s.*;
        if (_s == ')' or _s <= '"' or _s == ';')
            s.* = '_';
    }
}
