const std = @import("std");
const sql = @import("sqlutils.zig").sql_3;
const zap = @import("zap");
const stc = @import("staticutils.zig");


/// Basic example impl of a simple http fulfiller?
fn onWebMinimal(r: zap.SimpleRequest) void {
    
    if (r.path) |the_path| 
        std.debug.print("PATH: {s}\n", .{the_path});
    r.setStatus(.not_found);
    r.sendBody(stc.server_config.landing_body) catch return;
}

/// Handler for incoming requests
fn onAppRequest(r: zap.SimpleRequest) void {
    r.sendBody("hiya") catch return;
}

/// Initilalizes the HTTP fulfilment and SQL server to accept incoming requests 
pub fn init() !void
{
    //webfacing
    var web_face = zap.SimpleHttpListener.init(.{
        .port = stc.server_config.web_port,
        .on_request = onWebMinimal,
        .public_folder = "./",
        .log = true,
        .max_clients = 100000,
    });

    var app_face = zap.SimpleHttpListener.init(.{
        .port = stc.server_config.app_port,
        .on_request = onAppRequest,
        .log = true,
        .max_clients = 100000,
    });

    try web_face.listen();
    try app_face.listen();

    zap.start(.{.threads = 1, .workers = 2});
}

/// Processes requests 
pub fn proc() !void {
}

/// Deinitialize server and resource(s)
pub fn deinit() void{
    
}

