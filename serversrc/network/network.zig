const std = @import("std");
const zap = @import("zap");
const sql = @import("sqlite");
const cfg = @import("../configuration.zig");
const fio = @import("../fullio.zig");
const alc = @import("../allocator.zig");
const bst = @import("../buildassets.zig");
const ssn = @import("../network/session.zig");
const usr = @import("../database/user.zig");
const ast = @import("../database/asset.zig");
const ord = @import("../database/order.zig");
const ste = @import("../database/site.zig");
const sdb = @import("../database/sqldb.zig");
const tbi = @import("../database/tableinterface.zig");

pub fn init(config: cfg.Configuration) !void {
    //webfacing
    const settings = zap.HttpListenerSettings{
        .port = config.hostport,
        .on_request = onReception,
        //.public_folder = stc.server_config.data_path,
        .log = true,
        .max_clients = 1 << 16,
        .max_body_size = 1 << 16,
        .tls = try zap.Tls.init(.{
            .server_name = if (config.ssl_name) |ssl_name| @ptrCast(ssl_name) else null,
            .public_certificate_file = if (config.ssl_cert_pem) |ssl_cert_pem| @ptrCast(ssl_cert_pem) else null,
            .private_key_file = if (config.ssl_privkey_pem) |ssl_privkey_pem| @ptrCast(ssl_privkey_pem) else null,
            .private_key_password = if (config.ssl_privkey_pass) |ssl_privkey_pass| @ptrCast(ssl_privkey_pass) else null,
        }),
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
    const eql = std.mem.eql;
    if (r.body) |body| {
        var split = std.mem.splitScalar(u8, body, ' ');
        if (split.next()) |command| {
            //add user
            if (eql(u8, command, "add_u")) {}
            //update user
            if (eql(u8, command, "upd_u")) {}
            //add site
            if (eql(u8, command, "add_s")) {}
            //update site
            if (eql(u8, command, "upd_s")) {}
            //add asset
            if (eql(u8, command, "add_a")) {}
            //update asset
            if (eql(u8, command, "upd_a")) {}
            //add order
            if (eql(u8, command, "add_o")) {}
            //update order
            if (eql(u8, command, "upd_o")) {}
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
                        transmitError(r, "An error occured during login\n");
                        return;
                    };

                // "query_q" for asset quantity query, with provided asset code
                if (eql(u8, command, "query_q"))
                    return queryAssetQuantity(r, &split) catch |err| {
                        std.log.err("Asset query error: {!}", .{err});
                        transmitError(r, "An error occured while querying asset levels.");
                        return;
                    };

                // "get_a" for asset
                if (eql(u8, command, "get_a")) {
                    if (split.next()) |asset_code| {
                        getTransmitRecord(r, ast.Asset, "asset_data", "asset_code", asset_code) catch |err| {
                            std.log.err("Get Transmit Asset Error: {!}", .{err});
                            transmitError(r, "Error occured when attempting to " ++
                                "retrieve and transmit asset record.");
                            return;
                        };
                        return;
                    }
                }

                // "get_u" for users
                if (eql(u8, command, "get_u")) {
                    getTransmitUserPartial(r, body) catch |err| {
                        transmitError(r, "Error while accessing User Records");
                        std.log.err("Error while accessing User Records: {!}", .{err});
                        return;
                    };
                }

                // "get_s" for sites
                // TODO extend Site code, site name, address
                if (eql(u8, command, "get_s")) {
                    if (split.next()) |site_code|
                        getTransmitRecord(r, ste.Site, "site_data", "site_id", site_code) catch |err| {
                            std.log.err("Error occured accessign and transmitting site record: {!}", .{err});
                            transmitError(r, "Error occured accessign and transmitting site record");
                            return;
                        };
                }

                // "get_o" for orders
                if (eql(u8, command, "get_o")) {
                    if (split.next()) |order_id|
                        getTransmitRecord(r, ord.Order, "order_data", "order_id", order_id) catch |err| {
                            std.log.err("Error occured accessign and transmitting order record: {!}", .{err});
                            transmitError(r, "Error occured accessign and transmitting order record");
                            return;
                        };
                }
            }
        }
    }
    r.setStatus(.teapot);
    r.setHeader("Content-Type", "shoo") catch |err|
        std.log.err("{!}\n", .{err});
    r.sendBody("\nshoo\n") catch |err|
        std.log.err("{!}\n", .{err});
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
        try r.setHeader("Content-Type", "application/xml");

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

pub fn transmitError(r: zap.Request, whoops_description: []const u8) void {
    r.setStatus(.ok);
    r.setHeader("Content-Type", "text/plain") catch |err| {
        std.log.err("Errort transmission failure: {!}", .{err});
    };
    r.sendBody(whoops_description) catch |err| {
        std.log.err("Errort transmission failure: {!}", .{err});
    };
}

pub fn getTransmitRecord(r: zap.Request, comptime T: type, comptime table: []const u8, comptime column: []const u8, query: []const u8) !void {
    const statement = try sdb.db.prepare(
        struct { q: sql.Text },
        T,
        "SELECT * FROM " ++ table ++ " WHERE " ++ column ++ " = :q",
    );
    defer statement.finalize();

    try statement.bind(.{ .q = sql.text(query) });
    defer statement.reset();

    if (try statement.step()) |result| {
        const s = switch (T) {
            ast.Asset => .{
                .asset_code = result.asset_code.data,
                .quantity = result.quantity,
                .desc = result.desc.data,
                .brand = result.brand.data,
                .storage = result.storage.data,
            },
            usr.User => .{
                .user_id = result.user_id,
                .site_id = result.site_id,
                .username = result.username.data,
                .password = result.password.data,
                .name = result.name.data,
                .email = result.email.data,
                .phone = result.phone.data,
                .permission = result.permission.data,
            },
            ord.Order => .{
                .order_id = result.order_id,
                .user_id = result.user_id,
                .site_id = result.site_id,
                .date = result.date.data,
                .tracking = result.tracking.data,
                .courier = result.courier.data,
                .manifest = result.manifest.data,
            },
            ste.Site => .{
                .site_id = result.site_id,
                .title = result.title.data,
                .address = result.address.data,
                .notes = result.notes.data,
                .contact_name = result.contact_name.data,
                .contact_phone = result.contact_phone.data,
            },
            else => return error.IncompatableType,
        };

        const json = try std.json.stringifyAlloc(
            alc.fba,
            s,
            .{ .emit_nonportable_numbers_as_strings = true },
        );
        defer alc.fba.free(json);

        r.setStatus(.ok);
        try r.setHeader("Content-Type", "application/json");
        try r.sendBody(json);
    }
}

fn getTransmitUserPartial(r: zap.Request, body: []const u8) !void {
    // recieve json
    // find first and last brackets?
    const start =
        start_block: for (body, 0..) |c, i|
    {
        if (c == '{') break i else continue :start_block;
    } else return error.InvalidJSON;
    const end =
        end_block: for (0..body.len) |i|
    {
        const j = body.len - i;
        if (body[j - 1] == '}') break j else continue :end_block;
    } else return error.InvalidJSON;
    if (start >= 0 and end >= 0) {
        const U = struct {
            user_id: []const u8,
            site_id: []const u8,
            username: []const u8,
            password: []const u8,
            name: []const u8,
            email: []const u8,
            phone: []const u8,
            permission: []const u8,
        };
        const u = try std.json.parseFromSlice(
            U,
            alc.fba,
            body[start..end],
            .{ .max_value_len = 64 },
        );
        if (u.value.user_id.len > 0)
            try getTransmitRecord(
                r,
                usr.User,
                "user_data",
                "user_id",
                u.value.user_id,
            )
        else if (u.value.username.len > 0)
            try getTransmitRecord(
                r,
                usr.User,
                "user_data",
                "username",
                u.value.username,
            )
        else if (u.value.email.len > 0)
            try getTransmitRecord(
                r,
                usr.User,
                "user_data",
                "email",
                u.value.email,
            );
    } else {
        return error.InvalidJSON;
    }
}

pub fn searchAndGetJSONObject(comptime T: type, string: []const u8, allocator: std.mem.Allocator) !T {
    //first find bounds of json
    const start = for (string, 0..) |c, i| {
        if (c == '{') break i;
    } else return error.InvalidJSON;
    const end = for (0..string.len) |i| {
        const c = string[string.len - (i + 1)];
        if (c == '}') break i + 1;
    } else return error.InvalidJSON;
    //attempt JSON-ification
    return std.json.parseFromSlice(T, allocator, string[start..end], .{});
}
