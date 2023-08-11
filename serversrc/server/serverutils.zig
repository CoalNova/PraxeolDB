const std = @import("std");
const sql = @import("sqlutils.zig");
const zap = @import("zap");
const stc = @import("staticutils.zig");
const wst = zap.WebSockets;

/// Basic example impl of a simple http fulfiller?
fn onWebMinimal(r: zap.SimpleRequest) void {
    _ = stc.bw.write("HELLO DAVE\n") catch return;
    std.debug.print("HELLO DAVE\n", .{});
    r.setHeader("Content-Type", "text/plain") catch unreachable;

    if (r.method != null and r.path != null)
        if (std.mem.eql(u8, r.method.?, "GET") and std.mem.eql(u8, r.path.?, "/")) {
            r.setStatus(.ok);
            r.sendBody(stc.web_embed) catch return;
        };
    r.setStatus(.not_found);
    r.sendBody(stc.server_config.landing_body) catch return;
}

/// Handler for incoming requests
fn onAppRequest(r: zap.SimpleRequest) void {
    r.setHeader("Access-Control-Allow-Origin", stc.server_config.hostname) catch unreachable;
    r.setHeader("Access-Control-Allow-Headers", "*") catch unreachable;
    r.setHeader("Access-Control-Allow-Methods", "OPTIONS,POST,GET") catch unreachable;

    std.debug.print("We got client app!\n", .{});
    if (r.path) |the_path|
        std.debug.print("APP: {s}\n", .{the_path});
    std.debug.print("path: {s}\n", .{if (r.path == null) "null" else r.path.?});
    std.debug.print("query: {s}\n", .{if (r.query == null) "null" else r.query.?});
    std.debug.print("body: {s}\n", .{if (r.body == null) "null" else r.body.?});
    std.debug.print("method: {s}\n", .{if (r.method == null) "null" else r.method.?});

    if (r.body != null) {
        r.setHeader("Content-Type", "application/json") catch unreachable;
        if (std.mem.eql(u8, r.body.?, "Hello")) {
            r.setStatus(.ok);
            r.sendBody("Hello!") catch unreachable;
            return;
        }
    }

    r.setHeader("Content-Type", "plain/text") catch unreachable;
    r.setStatus(.ok);
    r.sendBody("Shoo!") catch unreachable;
}

/// Initilalizes the HTTP fulfilment and SQL server to accept incoming requests
pub fn init() !void {
    //webfacing
    var web_face = zap.SimpleHttpListener.init(.{
        .port = stc.server_config.web_port,
        .on_request = onWebMinimal,
        .public_folder = stc.server_config.data_path,
        .log = true,
        .max_clients = 100000,
        .max_body_size = 2048,
    });

    //appfacing
    var app_face = zap.SimpleEndpointListener.init(
        stc.allocator,
        .{
            .port = stc.server_config.app_port,
            .on_request = onAppRequest,
            .log = true,
            .max_clients = 100000,
            .max_body_size = 2048,
        },
    );

    try web_face.listen();
    try app_face.listen();

    sql.loadDB();
    zap.start(.{ .threads = 2, .workers = 2 });
    std.debug.print("Hullo to all\n", .{});
}

/// Processes requests
pub fn proc() !void {}

/// Deinitialize server and resource(s)
pub fn deinit() void {}

/// Establishes files in current directory if they don't already exist
pub fn establish() !void {
    const fs = std.fs;
    const cwd = fs.cwd();

    cwd.access(stc.server_config.config_path, .{}) catch |err|
        {
        if (err == fs.Dir.OpenError.FileNotFound) {
            var file = try cwd.createFile(stc.server_config.config_path, .{});
            defer file.close();
            _ = try file.write(stc.app_embed);
        }
    };

    cwd.access(stc.server_config.js_path, .{}) catch |err|
        {
        if (err == fs.Dir.OpenError.FileNotFound) {
            var file = try cwd.createFile(stc.server_config.js_path, .{});
            defer file.close();
            _ = try file.write(stc.app_embed);
        } else return err;
    };

    cwd.access(stc.server_config.fvcn_path, .{}) catch |err|
        {
        if (err == fs.Dir.OpenError.FileNotFound) {
            var file = try cwd.createFile(stc.server_config.fvcn_path, .{});
            defer file.close();
            _ = try file.write(stc.ico_embed);
        } else return err;
    };

    cwd.access(stc.server_config.html_path, .{}) catch |err|
        {
        if (err == fs.Dir.OpenError.FileNotFound) {
            var file = try cwd.createFile(stc.server_config.html_path, .{});
            defer file.close();
            _ = try file.write(stc.index_html);
        } else return err;
    };
}
