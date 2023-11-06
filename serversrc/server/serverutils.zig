//! Server Utils
//! Houses utilities related to the network serving and reception of data.
//!
//!
//!

const std = @import("std");
const sql = @import("sqlutils.zig");
const zap = @import("zap");
const stc = @import("staticutils.zig");
const wst = zap.WebSockets;
const ssn = @import("sessionutils.zig");

// static name binding for easierness
const eql = std.mem.eql;

/// Basic example impl of a simple http fulfiller?
fn onWebMinimal(r: zap.SimpleRequest) void {
    _ = stc.bw.write("HELLO DAVE\n") catch return;
    std.debug.print("HELLO DAVE\n", .{});
    r.setHeader("Content-Type", "text/html") catch unreachable;

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

    //DEBUG prints incoming connection
    if (r.path) |path| std.debug.print("\npath: {s}\n", .{path});
    if (r.method) |method| std.debug.print("method: {s}\n", .{method});
    if (r.body) |body| std.debug.print("body: {s}\n\n", .{body});

    r.setHeader("Access-Control-Allow-Origin", stc.server_config.hostname) catch unreachable;
    r.setHeader("Access-Control-Allow-Headers", "*") catch unreachable;
    // SET may be unused, but follows accessor convention, which is morally superior to web convention (even if oop)
    r.setHeader("Access-Control-Allow-Methods", "OPTIONS,POST,GET,SET") catch unreachable;
    r.setHeader("Content-Type", "application/json") catch unreachable;

    r.setStatus(.ok);

    // If method and body have content, see if we have a match
    if (r.method != null and r.body != null) {
        if (eql(u8, r.method.?, "POST"))
            return procPOST(r) catch |err| std.log.err("{!}\n", .{err});

        if (eql(u8, r.method.?, "GET"))
            return procGET(r) catch |err| std.log.err("{!}\n", .{err});

        if (eql(u8, r.method.?, "SET"))
            return procSET(r) catch |err| std.log.err("{!}\n", .{err});

        if (eql(u8, r.method.?, "OPTIONS"))
            return procOPTIONS(r) catch |err| std.log.err("{!}\n", .{err});
    }

    // ... otherwise return a small response to avoid providing DDOS ammo
    r.sendBody("invalid input") catch |err| std.log.err("{!}\n", .{err});
}

fn procPOST(r: zap.SimpleRequest) !void {
    //if connection status return hello and autho
    if (eql(u8, r.body.?[0..6], "Hello!")) {
        var suffix: [8]u8 = undefined;
        for (r.body.?[6..14], 0..) |c, i| suffix[i] = c;
        const autho = try ssn.getAutho(suffix);

        var response: [14]u8 = undefined;
        for ("Hello!" ++ autho.guest_off, 0..) |c, i| response[i] = c;
        try r.sendBody(&response);
        //else if login attempt
    } else if (eql(u8, r.body.?[0..5], "login")) {
        var spliterator = std.mem.splitAny(u8, r.body.?, " ");
        _ = spliterator.next();
        var username = spliterator.next();
        var password = spliterator.next();

        // if the supplied username and password aren't empty
        if (username != null and password != null) {
            // get the user associated with the username
            var user = sql.getUser(username.?, stc.allocator) catch |err|
                return std.log.err("Unable to access db user table: {!}", .{err});
            defer sql.freeUser(&user);

            // hash stored password to check match on request
            var suffix: [8]u8 = undefined;
            for (r.body.?[5..13], 0..) |c, i| suffix[i] = c;
            const autho = try ssn.getAutho(suffix);

            var pass_buff = try stc.allocator.alloc(u8, user.password.len + autho.guest_off.len);
            defer stc.allocator.free(pass_buff);
            for (user.password, 0..) |c, i| pass_buff[i] = c;
            for (autho.guest_off, 0..) |c, i| pass_buff[i + user.password.len] = c;

            var sha = std.crypto.hash.sha2.Sha256.init(.{});
            sha.update(pass_buff);
            var pre_result = sha.finalResult();
            var result = try std.fmt.allocPrint(stc.allocator, "{x}", .{std.fmt.fmtSliceHexLower(@as([]const u8, @ptrCast(&pre_result)))});
            defer stc.allocator.free(result);

            // if hashes match, we have a valid login
            if (eql(u8, user.username, username.?) and eql(u8, result, password.?)) {
                // grab/create session
                const session = try ssn.getSession(user);

                // fill in response, which includes sessionID
                const affirm = "not guilty";
                var body_buffer: [affirm.len + 10]u8 = undefined;
                for (affirm, 0..) |c, i| body_buffer[i] = c;
                for (session.session_id, 0..) |c, i| body_buffer[i + affirm.len] = c;

                // send it
                try r.sendBody(&body_buffer);
                return;
            } else {
                // return failure
                std.log.info("\nExpect: [{s}]\nActual: [{s}]\nOffset: [{s}]", .{
                    result,
                    password.?,
                    autho.guest_off,
                });

                return try r.sendBody("guilty 1");
            }
        }

        //return failure
        try r.sendBody("guilty 3");
        return;
    }
}

fn procGET(r: zap.SimpleRequest) !void {
    _ = r;
}

fn procSET(r: zap.SimpleRequest) !void {
    _ = r;
}

fn procOPTIONS(r: zap.SimpleRequest) !void {
    _ = r;
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
        .tls = zap.fio_tls_new("CoalNova.us", null, null, null),
    });

    //appfacing
    var app_face = zap.SimpleEndpointListener.init(
        stc.allocator,
        .{
            .port = stc.server_config.app_port,
            .on_request = onAppRequest,
            .log = false,
            .max_clients = 100000,
            .max_body_size = 2048,
            .tls = zap.fio_tls_new("CoalNova.us", null, null, null),
        },
    );

    try web_face.listen();
    try app_face.listen();

    sql.loadDB();
    zap.start(.{ .threads = 2, .workers = 2 });
}

/// Processes requests
pub fn proc() !void {}

/// Deinitialize server and resource(s)
pub fn deinit() void {}

/// Establishes files in current directory if they don't already exist
pub fn establish() !void {
    const fs = std.fs;
    const cwd = fs.cwd();

    std.debug.print("{s}\n", .{stc.server_config.js_path});

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
