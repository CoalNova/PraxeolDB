const std = @import("std");
const sql = @import("sqlite");

pub fn convertTS(comptime T: type, comptime S: type, t: T) !S {
    const s_fields = std.meta.fields(S);
    const t_fields = std.meta.fields(T);
    var s: S = .{};
    for (s_fields, t_fields) |tf, sf| {
        @field(s, sf.name) =
            switch (@TypeOf(@field(s, sf.name))) {
            i32 => try std.fmt.parseInt(i32, @field(t, tf.name), 10),
            sql.Text => sql.text(@field(t, tf.name)),
            else => return error.UnexpectedType,
        };
    }
    return s;
}

pub fn convertST(comptime S: type, comptime T: type, s: S, allocator: std.mem.Allocator) !T {
    const s_fields = std.meta.fields(S);
    const t_fields = std.meta.fields(T);
    var t: T = .{};
    for (s_fields, 0..) |f, i| {
        const a = allocator.alloc(u8, @field(s, f.name).len);
        errdefer allocator.free(a);
        @field(t, t_fields[i].name) = a;
    }
}

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

pub fn get(comptime S: type, callback: fn (?S) void, q: anytype, comptime get_args: []const u8, db: *sql.Database) !void {
    const statement = try db.prepare(struct { q: @TypeOf(q) }, comptime S, get_args);
    defer statement.finalize();
    try statement.bind(.{ .q = q });
    defer statement.reset();

    if (try statement.step()) |result|
        return callback(result);

    callback(null);
}
