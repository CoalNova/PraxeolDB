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
                    const A = struct {
                        asset_code: []const u8,
                        quantity: i32,
                        desc: []const u8,
                        brand: []const u8,
                        storage: []const u8,
                    };
                    const asset = searchAndGetJSONObject(A, body, alc.fba) catch |err| {
                        std.log.err("Error parsing asset json {!} : {d}", .{ err, body.len });
                        transmitError(r, "Error parsing asset json");
                        return;
                    };
                    defer asset.deinit();

                    const found = getTransmitRecord(
                        r,
                        ast.Asset,
                        "asset_data",
                        "asset_code",
                        asset.value.asset_code,
                    ) catch |err| {
                        std.log.err("Get Transmit Asset Error: {!}", .{err});
                        transmitError(r, "Error occured when attempting to " ++
                            "retrieve and transmit asset record.");
                        return;
                    };
                    if (!found) {
                        transmitError(r, "Asset record not found");
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
                    getTransmitSiteFromPartial(r, body) catch |err| {
                        std.log.err("Error while accessing Site Records{!}", .{err});
                        transmitError(r, "Error while accessing Site Records");
                        return;
                    };
                }

                // "get_o" for orders
                if (eql(u8, command, "get_o")) {
                    if (split.next()) |order_id| {
                        const found = getTransmitRecord(r, ord.Order, "order_data", "order_id", order_id) catch |err| {
                            std.log.err("Error occured accessign and transmitting order record: {!}", .{err});
                            transmitError(r, "Error occured accessign and transmitting order record");
                            return;
                        };
                        if (!found) {
                            transmitError(r, "Order record not found");
                            return;
                        }
                    }
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

/// Transmits Record if found, returns if record was found to return.
//TODO return multirecord
pub fn getTransmitRecord(
    r: zap.Request,
    comptime T: type,
    comptime table: []const u8,
    comptime column: []const u8,
    query: []const u8,
) !bool {
    const statement = try sdb.db.prepare(
        struct { q: sql.Text },
        T,
        "SELECT * FROM " ++ table ++ " WHERE " ++ column ++ " = :q",
    );
    defer statement.finalize();

    try statement.bind(.{ .q = sql.text(query) });
    defer statement.reset();

    if (try statement.step()) |value| {
        const record = switch (T) {
            ast.Asset => .{
                .asset_code = value.asset_code.data,
                .quantity = value.quantity,
                .desc = value.desc.data,
                .brand = value.brand.data,
                .storage = value.storage.data,
            },
            usr.User => .{
                .user_id = value.user_id,
                .site_id = value.site_id,
                .username = value.username.data,
                .password = value.password.data,
                .name = value.name.data,
                .email = value.email.data,
                .phone = value.phone.data,
                .permission = value.permission.data,
            },
            ord.Order => .{
                .order_id = value.order_id,
                .user_id = value.user_id,
                .site_id = value.site_id,
                .date = value.date.data,
                .tracking = value.tracking.data,
                .courier = value.courier.data,
                .manifest = value.manifest.data,
            },
            ste.Site => .{
                .site_id = value.site_id,
                .title = value.title,
                .address = value.address,
                .notes = value.notes,
                .contact_name = value.contact_name,
                .contact_phone = value.contact_phone,
            },
            else => return error.IncompatableType,
        };

        const json = try std.json.stringifyAlloc(
            alc.fba,
            record,
            .{ .emit_nonportable_numbers_as_strings = true },
        );
        defer alc.fba.free(json);

        r.setStatus(.ok);
        try r.setHeader("Content-Type", "application/json");
        try r.sendBody(json);
        return true;
    }
    return false;
}

fn getTransmitUserPartial(r: zap.Request, body: []const u8) !void {
    // recieve json
    // find first and last brackets?
    const json = try searchAndGetJSONObject(comptime try getPrimitiveOf(usr.User), body, alc.fba);
    defer json.deinit();

    const user = json.value;

    const user_id = try std.fmt.allocPrint(alc.fba, "{d}", .{user.user_id});
    defer alc.fba.free(user_id);

    if (try getTransmitRecord(
        r,
        usr.User,
        "user_data",
        "user_id",
        user_id,
    )) return;

    if (try getTransmitRecord(
        r,
        usr.User,
        "user_data",
        "username",
        user.username,
    )) return;

    if (try getTransmitRecord(
        r,
        usr.User,
        "user_data",
        "email",
        user.email,
    )) return;

    return sdb.DBErrors.RecordNotFound;
}

fn getTransmitSiteFromPartial(r: zap.Request, body: []const u8) !void {
    const json = try searchAndGetJSONObject(try getPrimitiveOf(ste.Site), body, alc.fba);
    defer json.deinit();
    const site = json.value;

    if (try getTransmitRecord(
        r,
        ste.Site,
        "site_data",
        "title",
        site.title,
    )) return;

    if (try getTransmitRecord(
        r,
        ste.Site,
        "site_data",
        "address",
        site.address,
    )) return;

    if (try getTransmitRecord(
        r,
        ste.Site,
        "site_data",
        "contact_phone",
        site.contact_phone,
    )) return;

    const site_id = try std.fmt.allocPrint(alc.fba, "{d}", .{site.site_id});
    defer alc.fba.free(site_id);

    if (try getTransmitRecord(
        r,
        ste.Site,
        "site_data",
        "site_id",
        site_id,
    )) return;

    return sdb.DBErrors.RecordNotFound;
}

pub fn searchAndGetJSONObject(comptime T: type, string: []const u8, allocator: std.mem.Allocator) !std.json.Parsed(T) {
    //first find bounds of json
    const start = for (string, 0..) |c, i| {
        if (c == '{') break i;
    } else return sdb.DBErrors.InvalidJSON;
    const end = for (0..string.len) |i| {
        const c = string[string.len - (i + 1)];
        if (c == '}') break string.len - (i);
    } else return sdb.DBErrors.InvalidJSON;
    //attempt JSON-ification
    std.debug.print("\n{s}\n", .{string[start..end]});
    return std.json.parseFromSlice(T, allocator, string[start..end], .{});
}

fn addToTable(r: zap.Request, body: []const u8, comptime T: type, add_args: []const u8) !void {
    const json = try searchAndGetJSONObject(comptime getPrimitiveOf(T), body, alc.fba);
    defer json.deinit();

    const entry = convertPrimitiveTo(T, json.value);

    const statement = try sdb.db.prepare(T, void, add_args);
    defer statement.finalize();

    try statement.exec(entry);

    r.setStatus(.ok);
    try r.setHeader("Content-Type", "text/plain");
    try r.sendBody("!Added entry");
}

fn convertPrimitiveTo(comptime T: type, value: anytype) type {
    return switch (T) {
        ast.Asset => .{
            .asset_code = sql.text(value.asset_code),
            .quantity = value.quantity,
            .desc = sql.text(value.desc),
            .brand = sql.text(value.brand),
            .storage = sql.text(value.storage),
        },
        usr.User => .{
            .user_id = value.user_id,
            .site_id = value.site_id,
            .username = sql.text(value.username),
            .password = sql.text(value.password),
            .name = sql.text(value.name),
            .email = sql.text(value.email),
            .phone = sql.text(value.phone),
            .permission = sql.text(value.permission),
        },
        ord.Order => .{
            .order_id = value.order_id,
            .user_id = value.user_id,
            .site_id = value.site_id,
            .date = sql.text(value.date),
            .tracking = sql.text(value.tracking),
            .courier = sql.text(value.courier),
            .manifest = sql.text(value.manifest),
        },
        ste.Site => .{
            .site_id = value.site_id,
            .title = sql.text(value.title),
            .address = sql.text(value.address),
            .notes = sql.text(value.notes),
            .contact_name = sql.text(value.contact_name),
            .contact_phone = sql.text(value.contact_phone),
        },
        else => return error.IncompatableType,
    };
}

fn getPrimitiveOf(comptime T: type) !type {
    return switch (T) {
        ast.Asset => struct {
            asset_code: []const u8 = undefined,
            quantity: i32 = undefined,
            desc: []const u8 = undefined,
            brand: []const u8 = undefined,
            storage: []const u8 = undefined,
        },
        usr.User => struct {
            user_id: i32 = 0,
            site_id: i32 = 0,
            username: []const u8 = undefined,
            password: []const u8 = undefined,
            name: []const u8 = undefined,
            email: []const u8 = undefined,
            phone: []const u8 = undefined,
            permission: []const u8 = undefined,
        },
        ord.Order => struct {
            order_id: i32 = 0,
            user_id: i32 = 0,
            site_id: i32 = 0,
            date: []const u8 = undefined,
            tracking: []const u8 = undefined,
            courier: []const u8 = undefined,
            manifest: []const u8 = undefined,
        },
        ste.Site => struct {
            site_id: i32 = undefined,
            title: []const u8 = undefined,
            address: []const u8 = undefined,
            notes: []const u8 = undefined,
            contact_name: []const u8 = undefined,
            contact_phone: []const u8 = undefined,
        },
        else => return error.IncompatableType,
    };
}

fn getPrimitiveFrom(comptime T: type, value: anytype) !type {
    return switch (T) {
        ast.Asset => struct {
            asset_code: []const u8 = value.asset_code.data,
            quantity: i32 = value.quantity,
            desc: []const u8 = value.desc.data,
            brand: []const u8 = value.brand.data,
            storage: []const u8 = value.storage.data,
        },
        usr.User => struct {
            user_id: i32 = value.user_id,
            site_id: i32 = value.site_id,
            username: []const u8 = value.username.data,
            password: []const u8 = value.password.data,
            name: []const u8 = value.name.data,
            email: []const u8 = value.email.data,
            phone: []const u8 = value.phone.data,
            permission: []const u8 = value.permission.data,
        },
        ord.Order => struct {
            order_id: i32 = value.order_id,
            user_id: i32 = value.user_id,
            site_id: i32 = value.site_id,
            date: []const u8 = value.date.data,
            tracking: []const u8 = value.tracking.data,
            courier: []const u8 = value.courier.data,
            manifest: []const u8 = value.manifest.data,
        },
        ste.Site => struct {
            site_id: i32 = value.site_id,
            title: []const u8 = value.title.data,
            address: []const u8 = value.address.data,
            notes: []const u8 = value.notes.data,
            contact_name: []const u8 = value.contact_name.data,
            contact_phone: []const u8 = value.contact_phone.data,
        },
        else => return error.IncompatableType,
    };
}
