//! SQL Utils
//! Houses utlities for the management of the SQL database
//!

const std = @import("std");
const stc = @import("staticutils.zig");
const sql = @import("sqlite");

var db: sql.Db = undefined;

pub fn loadDB() void {
    const cwd = std.fs.cwd();

    // check if db file exists
    var file: ?std.fs.File = null;

    file = cwd.openFile(stc.server_config.db_path, .{}) catch null;
    const db_exists = (file != null);
    // close if exist, before handling by sqlite
    if (db_exists)
        file.?.close();

    const fixed_path: []u8 = stc.allocator.alloc(u8, stc.server_config.db_path.len + 1) catch |err|
        return std.debug.print("DB name allocation failure: {!}\n", .{err});
    defer stc.allocator.free(fixed_path);
    for (stc.server_config.db_path, 0..) |c, i| fixed_path[i] = c;
    //path must be null terminated for c interoperability
    fixed_path[stc.server_config.db_path.len] = '\x00';

    db = sql.Db.init(.{
        .mode = .{ .File = @ptrCast(fixed_path) },
        .open_flags = .{
            .write = true,
            .create = true,
        },
        .threading_mode = .MultiThread,
    }) catch |err|
        return std.debug.print("sql(ite) error: {!}\n", .{err});

    if (!db_exists) {
        std.debug.print("Database does not exist, populating fresh\n", .{});

        var diags = sql.Diagnostics{};
        var statement = db.prepareWithDiags(stc.table_init_user_data, .{ .diags = &diags }) catch |err|
            return std.debug.print("DB initialization failure: {!}; Diags:{s}\n", .{ err, diags });

        defer statement.deinit();

        statement.exec(.{}, .{}) catch |err|
            return std.debug.print("DB initiale execution failure: {!}\n", .{err});

        const user = User{
            .user_id = "0192837465",
            .site_id = "0",
            .username = "admin",
            .password = "password",
            .permission = "FF",
            .firstname = "Muriel",
            .lastname = "Bagge",
            .email = "mce.bagge@nowhere.net",
            .phone = "555-555-5309",
        };

        addUser(user) catch |err|
            return std.debug.print("Add default user error: {!}\n", .{err});
    }
}

pub fn establishTables() void {}

pub const User = struct {
    user_id: []const u8 = " ",
    site_id: []const u8 = " ",
    username: []const u8 = " ",
    password: []const u8 = " ",
    permission: []const u8 = " ",
    firstname: []const u8 = " ",
    lastname: []const u8 = " ",
    email: []const u8 = " ",
    phone: []const u8 = " ",
    // edit inv, edit users, edit self
};

pub const Site = struct {
    address: []const u8,
    city: []const u8,
    state: []const u8,
    contact: []const u8,
    phone: []const u8,
};

pub const Asset = struct {
    asset_id: []const u8,
    inv_code: []const u8,
    manufacturer: []const u8,
    state: []const u8,
};

pub const Order = struct {
    site: Site,
    user: User,
    item: Asset,
    quantity: u32,
};

pub const Transaction = struct {
    orders: []Order,
    date: []const u8,
};

fn userCallback(user: ?*anyopaque, arg_c: i32, arg_v: [*c][*c]u8, a_z_column: [*c][*c]u8) callconv(.C) i32 {
    _ = arg_v;
    _ = arg_c;
    _ = a_z_column;

    user.?.* = User{};

    return 0;
}
pub fn getUser(username: []const u8, allocator: std.mem.Allocator) !User {
    var user: User = User{};

    //stack ops where we can
    const op: [:0]const u8 = "SELECT * FROM USER_DATA WHERE username = ?";

    var statement = try db.prepare(op);
    defer statement.deinit();

    const row = try statement.oneAlloc(User, allocator, .{}, .{ .username = username });

    if (row) |db_user| {
        user = db_user;
    }

    return user;
}

pub fn freeUser(user: *User) void {
    defer stc.allocator.free(user.site_id);
    defer stc.allocator.free(user.user_id);
    defer stc.allocator.free(user.username);
    defer stc.allocator.free(user.password);
    defer stc.allocator.free(user.firstname);
    defer stc.allocator.free(user.lastname);
    defer stc.allocator.free(user.email);
    defer stc.allocator.free(user.phone);
    defer stc.allocator.free(user.permission);
}

pub fn addUser(user: User) !void {
    const op: [:0]const u8 = "INSERT INTO USER_DATA(user_id, site_id, username, password, permission, firstname, lastname, email, phone) " ++
        "VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?);";

    var statement = db.prepare(op) catch |err|
        return std.debug.print("DB add user failure: {!}\n", .{err});
    defer statement.deinit();

    statement.exec(.{}, .{
        .user_id = user.user_id,
        .site_id = user.site_id,
        .username = user.username,
        .password = user.password,
        .permission = user.permission,
        .firstname = user.firstname,
        .lastname = user.lastname,
        .email = user.email,
        .phone = user.phone,
    }) catch |err|
        return std.debug.print("DB add user execution failure: {!}\n", .{err});
}

pub fn setUser(user: User) bool {
    _ = user;
}

fn siteCallback(site: *Site, arg_c: i32, arg_v: [][]u8, a_z_column: [][]u8) i32 {
    _ = a_z_column;
    _ = arg_v;
    _ = arg_c;
    _ = site;
}
pub fn getSite() Site {
    @panic("not yet implemented");
}

pub fn addSite(site: Site) void {
    _ = site;
}

pub fn setSite(site: Site) bool {
    _ = site;
}

fn assetCallback(asset: *Asset, arg_c: i32, arg_v: [][]u8, a_z_column: [][]u8) i32 {
    _ = a_z_column;
    _ = arg_v;
    _ = arg_c;
    _ = asset;
}

pub fn getAsset() Asset {
    @panic("not yet implemented");
}

pub fn addAsset(asset: Asset) void {
    _ = asset;
}

pub fn setAsset(asset: Asset) bool {
    _ = asset;
}

fn orderCallback(order: *Order, arg_c: i32, arg_v: [][]u8, a_z_column: [][]u8) i32 {
    _ = a_z_column;
    _ = arg_v;
    _ = arg_c;
    _ = order;
}

pub fn getOrder() Order {
    @panic("not yet implemented");
}

pub fn addOrder(order: Order) void {
    _ = order;
}

pub fn setOrder(order: Order) bool {
    _ = order;
}

fn transactionCallback(transaction: *Transaction, arg_c: i32, arg_v: [][]u8, a_z_column: [][]u8) i32 {
    _ = a_z_column;
    _ = arg_v;
    _ = arg_c;
    _ = transaction;
}

pub fn getTransaction() Transaction {
    @panic("not yet implemented");
}

pub fn addTransaction(transaction: Transaction) void {
    _ = transaction;
}

pub fn setTransaction(transaction: Transaction) bool {
    _ = transaction;
}

inline fn checkMessage(mssg: ?*u8) void {
    if (mssg != null)
        std.debug.print("SQL message: {s}\n", .{@as([*c]u8, @ptrCast(mssg.?))});
}
