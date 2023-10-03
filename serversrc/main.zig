const std = @import("std");
const srv = @import("server/serverutils.zig");
const sql = @import("server/sqlutils.zig");
const stc = @import("server/staticutils.zig");
const ssn = @import("server/sessionutils.zig");

pub fn main() !void {

    //MEBE load separately for now in case it needs something special
    stc.loadConfigurationFile();

    try srv.establish();

    try ssn.init(stc.server_config.session_stack_size);
    defer ssn.deinit();

    try srv.init();
    defer srv.deinit();

    try stc.bw.flush(); // Also wash your hands after.
}
