const std = @import("std");
const server = @import("serverutils.zig");

pub fn main() !void {

    try server.init(std.net.Address.initIp4([_]u8{127,0,0,1}, 8080));
    defer server.deinit();


    try server.proc();


    try server.bw.flush(); // don't forget to flush!
}

