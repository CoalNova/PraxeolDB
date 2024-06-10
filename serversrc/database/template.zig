const std = @import("std");
const zap = @import("zap");
const alc = @import("../allocator.zig");
const sql = @import("sqlite");

pub fn template(
    comptime T: type,
    comptime S: type,
    comptime add_args: []const u8,
    comptime del_args: []const u8,
    comptime upd_args: []const u8,
    comptime convertTS: fn (?T) ?S,
    comptime convertST: fn (S, std.mem.Allocator) ?T,
    comptime destroy: fn (?T, std.mem.Allocator) void,
    comptime jsonifier: fn (T, std.mem.Allocator) ?[]u8,
    comptime allocator: std.mem.Allocator,
) type {
    return struct {
        const Self = @This();
        comptime add_args: []const u8 = add_args,
        comptime del_args: []const u8 = del_args,
        comptime upd_args: []const u8 = upd_args,
        comptime T: type = T,
        comptime S: type = S,
        comptime convertTS: fn (?T) ?S = convertTS,
        comptime destroy: fn (?T, std.mem.Allocator) void = destroy,
        comptime jsonifier: fn (T, std.mem.Allocator) ?[]u8 = jsonifier,
        comptime convertST: fn (S, std.mem.Allocator) ?T = convertST,
        comptime allocator: std.mem.Allocator = allocator,

        t: ?T = null,
        s: S = .{},

        /// Struct-internal function to remove duplicate code
        fn exec(self: Self, db: *sql.Database, args: []const u8) !void {
            const statement = try db.prepare(self.S, void, args);
            defer statement.finalize();
            const s = self.convertTS(self.t);
            if (s) |params| {
                try statement.bind(params);
                defer statement.reset();
                return;
            }
            return error.TSConversionFailure;
        }

        /// Adds current element to database according to internalized SQL ops
        pub fn add(self: Self, db: *sql.Database) !void {
            try exec(self, db, add_args);
        }

        /// Deletes current element to database according to internalized SQL ops
        pub fn delete(self: Self, db: sql.Database) !void {
            try exec(self, db, del_args);
        }

        /// Updates current element to database according to internalized SQL ops
        pub fn update(self: Self, db: sql.Database) !void {
            try exec(self, db, self.upd_args);
        }

        /// Returns a filled version of the requested item from the table
        /// Request must be passed directly, as to allow for dynamic lookups
        /// Request will have the lookup query item labeled as `:q`
        /// !!Creates new instance, must call .destroy()!!
        pub fn get(self: *Self, q: anytype, comptime get_args: []const u8, db: *sql.Database) !void {
            self.destroy(self.t, self.allocator);
            const statement = try db.prepare(struct { q: @TypeOf(q) }, comptime self.S, get_args);
            defer statement.finalize();
            try statement.bind(.{ .q = q });
            defer statement.reset();

            if (try statement.step()) |result| {
                self.t = self.convertST(result, self.allocator);
            }
        }

        pub fn transmit(self: Self, r: zap.Request) !void {
            if (self.t) |t| {
                const json_string = jsonifier(t, self.allocator);
                if (json_string) |json| {
                    defer self.allocator.free(json);
                    try r.setHeader("Content-Type", "application/json");
                    r.setStatus(.ok);
                    try r.sendBody(json);
                    return;
                }
            }
            try r.setHeader("Content-Type", "application/json");
            r.setStatus(.no_content);
            try r.sendBody("{}");
        }
    };
}
