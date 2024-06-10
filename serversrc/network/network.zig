const std = @import("std");
const zap = @import("zap");
const sql = @import("sqlite");
const cfg = @import("../configuration.zig");
const fio = @import("../fullio.zig");
const bst = @import("../buildassets.zig");
const ssn = @import("../session/session.zig");
const usr = @import("../database/user.zig");
const ast = @import("../database/asset.zig");
const ord = @import("../database/order.zig");
const ste = @import("../database/site.zig");
const sdb = @import("../database/sqldb.zig");
const alc = @import("../allocator.zig");

pub fn init(config: cfg.Configuration) !void {
    //webfacing
    const settings = zap.HttpListenerSettings{
        .port = config.hostport,
        .on_request = onReception,
        //.public_folder = stc.server_config.data_path,
        .log = true,
        .max_clients = 100000,
        .max_body_size = 2048,
        .tls = try zap.Tls.init(.{ .server_name = "localhost" }),
    };
    var web_face = zap.HttpListener.init(settings);

    try web_face.listen();

    zap.start(.{ .threads = 2, .workers = 2 });
}

pub fn deinit() void {}

fn onReception(r: zap.Request) void {
    r.setStatus(.ok);
    if (r.method) |method| {
        fio.print("Method: \"{s}\"\n", .{method});
        if (std.mem.eql(u8, method, "GET")) {
            return onGET(r);
        } else if (std.mem.eql(u8, method, "PUT")) {
            return onPUT(r);
        } else if (std.mem.eql(u8, method, "POST")) {
            return onPOST(r);
        } else if (std.mem.eql(u8, method, "DELETE")) {
            return onDELETE(r);
        }
    }
    r.setHeader("Content-Type", "text/html") catch unreachable;
    r.setStatus(.not_found);
    r.sendBody("shoo") catch return;
}

//GET/PUT/POST/DELETE

/// Function to handle requests for page info or application requests
fn onGET(r: zap.Request) void {
    const eql = std.mem.eql;

    if (r.path) |path| {
        fio.print("{s}\n", .{path});

        // main html body
        if (eql(u8, path, "/")) {
            r.setHeader("Content-Type", "text/html") catch |err|
                std.log.err("{!}\n", .{err});
            r.sendBody(bst.landing_body) catch |err|
                std.log.err("{!}\n", .{err});
            return;
        }

        // favicon
        if (eql(u8, path, "/favicon.ico")) {
            r.setHeader("Content-Type", "image") catch |err|
                std.log.err("{!}\n", .{err});
            r.sendBody(@as([]const u8, @ptrCast(bst.favicon))) catch |err|
                std.log.err("{!}\n", .{err});
            return;
        }

        // css
        if (eql(u8, path, "/main.css")) {
            r.setHeader("Content-Type", "image") catch |err|
                std.log.err("{!}\n", .{err});
            r.sendBody(@as([]const u8, @ptrCast(bst.stylesheet))) catch |err|
                std.log.err("{!}\n", .{err});
            return;
        }

        // header image
        if (eql(u8, path, "/logo.png")) {
            r.setHeader("Content-Type", "image") catch |err|
                std.log.err("{!}\n", .{err});
            r.sendBody(@as([]const u8, @ptrCast(bst.header))) catch |err|
                std.log.err("{!}\n", .{err});
            return;
        }

        // js app
        if (eql(u8, path, "/main.js")) {
            r.setHeader("Content-Type", "application/javascript") catch |err|
                std.log.err("{!}\n", .{err});
            r.sendBody(bst.app) catch |err|
                std.log.err("{!}\n", .{err});
            return;
        }
    }

    r.setHeader("Content-Type", "plain/text") catch |err|
        std.log.err("setting shoo error {!}\n", .{err});
    r.setStatus(.teapot);
    r.sendBody("\nshoo\n") catch |err|
        std.log.err("sending shoo error {!}\n", .{err});
}

/// Function to handle PUT requests, as relates to placing changes and orders
fn onPUT(r: zap.Request) void {
    if (r.body) |body| {
        const inv_add = "inv_add";
        if (std.mem.eql(u8, body, inv_add)) {
            const str = inv_add.len;
            var end: usize = 0;
            start_blk: for (body[str..]) |i| {
                if (body[i + str] == ' ') {
                    end = (i + str);
                    break :start_blk;
                } else return;
            }
            const session_id = body[str..end];
            _ = ssn.verifySession(session_id);
        }
    }
}

fn onPOST(r: zap.Request) void {
    const eql = std.mem.eql;

    post_body_block: {
        if (r.body) |body| {
            //fio.print("{s}\n", .{body});
            std.debug.print("{s}\n", .{body});

            // if body is zero-length, but not null ""
            if (body.len < 1)
                break :post_body_block;

            var split = std.mem.splitScalar(u8, body, ' ');
            if (split.next()) |command| {
                std.debug.print("\n{s}\n\n", .{command});

                // "login" for login
                if (eql(u8, command, "login"))
                    return login(r, &split) catch |err| {
                        std.debug.print("Error occured during login: {!}\n", .{err});
                        sendWhoopsie(r, "An error occured during login\n");
                        return;
                    };

                // "query_q" for asset quantity query, with provided asset code
                if (eql(u8, command, "query_q"))
                    return queryAssetQuantity(r, &split) catch |err| {
                        std.log.err("Asset query error: {!}", .{err});
                        sendWhoopsie(r, "An error occured while querying asset levels.");
                        return;
                    };

                // "get_a" for asset
                if (eql(u8, command, "get_a")) {
                    std.debug.print("get_a\n", .{});
                }

                // "get_o" for orders
                if (eql(u8, command, "get_o")) {
                    std.debug.print("get_o\n", .{});
                }

                // "get_u" for users
                // TODO extend either user_id or username
                if (eql(u8, command, "get_u")) {
                    std.debug.print("get_u\n", .{});
                }

                // "get_s" for sites
                // TODO extend Site code, site name, address
                if (eql(u8, command, "get_s")) {
                    std.debug.print("get_s\n", .{});
                }
            }
        }
        r.setStatus(.teapot);
        r.setHeader("Content-Type", "shoo") catch |err|
            std.log.err("{!}\n", .{err});
        r.sendBody("\nshoo\n") catch |err|
            std.log.err("{!}\n", .{err});
    }
}

fn onDELETE(r: zap.Request) void {
    _ = r;
}

pub fn login(r: zap.Request, split: *std.mem.SplitIterator(u8, .scalar)) !void {
    r.setHeader("Content-Type", "text/plain") catch |err|
        std.log.err("{!}\n", .{err});

    if (split.next()) |username|
        if (split.next()) |password| {
            const statement = try sdb.db.prepare(
                struct { q: sql.Text },
                usr.User,
                "SELECT * FROM user_data WHERE username = :q",
            );
            defer statement.finalize();
            try statement.bind(.{ .q = sql.text(username) });
            defer statement.reset();

            if (try statement.step()) |result| {
                if (std.mem.eql(u8, result.password.data, password)) {
                    try r.sendBody("not guilty ZX3RKX778628177");
                    return;
                }
            }
        };

    r.sendBody("guilty") catch |err|
        std.log.err("{!}\n", .{err});
}

fn queryAssetQuantity(r: zap.Request, split: *std.mem.SplitIterator(u8, .scalar)) !void {
    if (split.next()) |asset_code| {
        const statement = try sdb.db.prepare(
            struct { q: sql.Text },
            ast.Asset,
            "SELECT * FROM asset_data WHERE asset_code = :q",
        );

        try statement.bind(.{ .q = sql.text(asset_code) });

        r.setStatus(.ok);
        r.setHeader("Content-Type", "application/xml") catch |err| {
            std.log.err("{!}", .{err});
        };

        if (try statement.step()) |asset| {
            const asset_count = if (asset.quantity > 0) ((asset.quantity >> 1) + 1) else 0;

            const newbody = try std.fmt.allocPrint(
                alc.fba,
                "found {d}",
                .{asset_count},
            );
            defer alc.fba.free(newbody);

            try r.sendBody(newbody);
            return;
        }

        try r.sendBody("nomatch");
    }
    return;
}

pub fn auth(split: *std.mem.SplitIterator(u8, .scalar)) bool {
    if (split.next()) |autho| {
        _ = autho;
        // check autho against existing sessions and user creds.
        // If mismatch occurs between session and user credentials discard session immediately.
        return true;
    }
    return false;
}

pub fn sendWhoopsie(r: zap.Request, whoops_description: []const u8) void {
    r.setStatus(.ok);
    r.setHeader("Content-Type", "text/plain") catch |err| {
        std.log.err("{!}", .{err});
    };
    r.sendBody(whoops_description) catch |err| {
        std.log.err("{!}", .{err});
    };
}
