const std = @import("std");
const server = @import("serverutils.zig");
const sql_utils = @import("sqlutils.zig");
const sql = sql_utils.sql_3;
const stc = @import("staticutils.zig");

pub fn main() !void {

    try server.init(std.net.Address.initIp4([_]u8{127,0,0,1}, 8080));
    defer server.deinit();

    try server.proc();

    try stc.bw.flush(); // don't forget to flush!
}

test "sqlite3 open failure" 
{
    var db : ?*sql.sqlite3 = undefined;
    var result = sql.sqlite3_open("nofile._db", &db);
    std.debug.assert(result == 0);
}

