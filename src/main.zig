const std = @import("std");
const server = @import("serverutils.zig");
const sql_utils = @import("sqlutils.zig");
const sql = sql_utils.sql_3;
const stc = @import("staticutils.zig");

pub fn main() !void {

    //MEBE load separately for now in case it needs something special
    stc.loadConfigurationFile();

    try server.init();
    defer server.deinit();

    try server.proc();

    try stc.bw.flush(); // Also wash your hands after.
}

test "sqlite3 open failure" 
{
    var db : ?*sql.sqlite3 = undefined;
    var result = sql.sqlite3_open("nofile._db", &db);
    std.debug.assert(result == 0);
}

