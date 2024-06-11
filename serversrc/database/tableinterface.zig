const std = @import("std");
const sql = @import("sqlite");
const zap = @import("zap");
const ast = @import("asset.zig");

pub fn destroy(comptime T: type, t: T, allocator: std.mem.Allocator) void {
    const t_fields = std.meta.fields(T);
    for (t_fields) |f| {
        allocator.free(@field(t, f.name));
    }
}

pub fn jsonify(comptime T: type, t: T, allocator: std.mem.Allocator) ![]const u8 {
    return try std.json.stringifyAlloc(
        allocator,
        t,
        .{ .emit_nonportable_numbers_as_strings = true },
    );
}

/// Struct-internal function to remove duplicate code
pub fn exec(s: anytype, db: *sql.Database, args: []const u8) !void {
    const statement = try db.prepare(@TypeOf(s), void, args);
    defer statement.finalize();

    try statement.exec(s);
    return;
}

pub fn get(
    comptime S: type,
    q: anytype,
    comptime get_args: []const u8,
    db: *sql.Database,
    allocator: std.mem.Allocator,
) !?S {
    const statement = try db.prepare(
        struct { q: @TypeOf(q) },
        comptime S,
        get_args,
    );
    defer statement.finalize();
    try statement.bind(.{ .q = q });
    defer statement.reset();

    if (try statement.step()) |result| {
        switch (S) {
            ast.Asset => return ast.copy(result, allocator),
            else => null,
        }
    }
    return null;
}
