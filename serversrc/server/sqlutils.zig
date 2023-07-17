const std = @import("std");
const stc = @import("staticutils.zig");
pub const sql_3 = @cImport({
    @cInclude("sqlite3.h");
});

var db: ?*sql_3.sqlite3 = undefined;

pub fn loadDB() void {
    const cwd = std.fs.cwd();

    // check if db file exists
    var file: ?std.fs.File = null;

    file = cwd.openFile(stc.server_config.db_path, .{}) catch null;

    // close if opened before handing to sqlite
    if (file != null) {
        file.?.close();
        _ = sql_3.sqlite3_open(@as([*c]const u8, @ptrCast(stc.server_config.db_path)), &db);
    } else {
        std.debug.print("Database does not exist, populating fresh\n", .{});

        _ = sql_3.sqlite3_open(@as([*c]const u8, @ptrCast(stc.server_config.db_path)), &db);
        _ = sql_3.sqlite3_exec(db, stc.table_init_user_data, null, null, null);
        _ = sql_3.sqlite3_exec(db, stc.table_init_site_data, null, null, null);
        _ = sql_3.sqlite3_exec(db, stc.table_init_asset_data, null, null, null);
        _ = sql_3.sqlite3_exec(db, stc.table_init_order_data, null, null, null);
    }
}

pub fn establishTables() void {}

pub const User = struct {
    username: []const u8 = undefined,
    firstname: []const u8 = undefined,
    lastname: []const u8 = undefined,
    // edit inv, edit users, edit self
    permission: u8 = 0,
};

pub const Site = struct {
    address: []const u8,
    city: []const u8,
    state: []const u8,
};

pub const Asset = struct {};

pub const Order = struct {};

pub const Transaction = struct {};

pub fn getUser() User {
    @panic("not yet implemented");
}

pub fn getSite() Site {
    @panic("not yet implemented");
}

pub fn getAsset() Asset {
    @panic("not yet implemented");
}

pub fn getOrder() Asset {
    @panic("not yet implemented");
}

pub fn getTransaction() Asset {
    @panic("not yet implemented");
}
