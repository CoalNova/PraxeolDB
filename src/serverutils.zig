const std = @import("std");
const sql = @import("sqlutils.zig").sql_3;
const zap = @import("zap");
const stc = @import("staticutils.zig");

/// Basic example impl of a verbose fulfiller
fn onRequestVerbose(r: zap.SimpleRequest) void {
    if (r.path) |the_path| 
        std.debug.print("PATH: {s}\n", .{the_path});
    
    if (r.query) |the_query| 
        std.debug.print("QUERY: {s}\n", .{the_query});
    
    if (r.body) |the_body|
        std.debug.print("BODY: {s}\n", .{the_body});
    
    r.sendBody("<html><body><h1>Hello from ZAP!!!</h1></body></html>") catch return;
}

/// Basic example impl of a simple http fulfiller?
fn onRequestMinimal(r: zap.SimpleRequest) void {
    r.sendBody("<html><body><h1>Hello from ZAP!!!</h1></body></html>") catch return;
}

/// Handler for incoming requests
fn onSQLRequest(r: zap.SimpleRequest) void {
    _ = r;
}

/// Initilalizes the HTTP fulfilment and SQL server to accept incoming requests 
pub fn init(address : std.net.Address) !void
{
    var listener = zap.SimpleHttpListener.init(.{
        .port = address.getPort(),
        .on_request = onRequestVerbose,
        .log = true,
        .max_clients = 100000,
    });
    try listener.listen();
    zap.start(.{.threads = 1, .workers = 1});
}

/// Processes requests 
pub fn proc() !void {
}

/// Deinitialize server and resource(s)
pub fn deinit() void{
    //stc.server.deinit();
}

