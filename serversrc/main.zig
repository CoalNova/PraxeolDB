const std = @import("std");
const zap = @import("zap");
const sql = @import("sqlite");
const usr = @import("database/user.zig");
const net = @import("network/network.zig");
const sdb = @import("database/sqldb.zig");
const cfg = @import("configuration.zig");

pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    const config = cfg.getConfig();
    try sdb.init(config);
    try net.init(config);
}
