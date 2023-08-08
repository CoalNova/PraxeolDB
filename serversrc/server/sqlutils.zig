const std = @import("std");
const stc = @import("staticutils.zig");
pub const sql_3 = @cImport({
    @cInclude("sqlite3.h");
});

var db: ?*sql_3.sqlite3 = undefined;

pub fn loadDB() void {
    const cwd = std.fs.cwd();

    // check if db file exists
    var file: ?std.fs.File = null;

    file = cwd.openFile(stc.server_config.db_path, .{}) catch null;

    // close if opened before handing to sqlite
    if (file != null) {
        file.?.close();
        _ = sql_3.sqlite3_open(@as([*c]const u8, @ptrCast(stc.server_config.db_path)), &db);
    } else {
        std.debug.print("Database does not exist, populating fresh\n", .{});

        var mssg: ?*u8 = null;

        _ = sql_3.sqlite3_open(@as([*c]const u8, @ptrCast(stc.server_config.db_path)), &db);
        _ = sql_3.sqlite3_exec(db, stc.table_init_user_data, null, null, &mssg);
        checkMessage(mssg);
        _ = sql_3.sqlite3_exec(db, stc.table_init_site_data, null, null, &mssg);
        checkMessage(mssg);
        _ = sql_3.sqlite3_exec(db, stc.table_init_asset_data, null, null, &mssg);
        checkMessage(mssg);
        _ = sql_3.sqlite3_exec(db, stc.table_init_order_data, null, null, &mssg);
        checkMessage(mssg);
    }
}

pub fn establishTables() void {}

pub const User = struct {
    user_id: []const u8 = undefined,
    site_id: []const u8 = undefined,
    username: []const u8 = undefined,
    password: []const u8 = undefined,
    firstname: []const u8 = undefined,
    lastname: []const u8 = undefined,
    email: []const u8 = undefined,
    phone: []const u8 = undefined,
    // edit inv, edit users, edit self
    permission: u8 = 0,
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

fn userCallback(user: *User, arg_c: i32, arg_v: [][]u8, a_z_column: [][]u8) i32 {
    _ = a_z_column;
    _ = arg_v;
    _ = arg_c;
    _ = user;
}
pub fn getUser() User {
    var user: User = User{};
    var mssg: ?*u8 = null;
    _ = sql_3.sqlite3_exec(db, stc.table_init_user_data, userCallback, &user, &mssg);
    return user;
}

pub fn addUser(user: User) void {
    const prefix = "INSERT INTO USER_DATA(user_id, site_id, username, password, permission, firstname, lastname, email, phone) VALUES (";
    const midfix = "\", \"";
    const pstfix = "\");";

    var op = std.ArrayList(u8).init(stc.allocator);
    defer op.deinit();

    op.appendSlice(prefix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(user.user_id) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(prefix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(user.site_id) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(midfix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(user.username) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(midfix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(user.password) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(midfix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(user.permission) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(midfix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(user.firstname) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(midfix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(user.lastname) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(midfix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(user.email) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(midfix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(user.phone) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});
    op.appendSlice(pstfix) catch |err| return std.debug.print("Add user failed: {!}\n", .{err});

    var mssg: ?*u8 = null;

    _ = sql_3.sqlite3_exec(db, op, null, null, &mssg);

    checkMessage(mssg);
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
        std.debug.print("{s}\n", .{mssg.?});
}
