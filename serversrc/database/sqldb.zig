const std = @import("std");
const zap = @import("zap");
const sql = @import("sqlite");
const usr = @import("../database/user.zig");
const ast = @import("../database/asset.zig");
const ste = @import("../database/site.zig");
const ord = @import("../database/order.zig");
const cfg = @import("../configuration.zig");
const alc = @import("../allocator.zig");
const tbi = @import("../database/tableinterface.zig");

pub var db: sql.Database = undefined;

pub fn init(config: cfg.Configuration) !void {
    //check if file exists
    check_block: {
        const db_file = std.fs.cwd().openFile(config.db_path, .{}) catch |err|
            {
            switch (err) {
                error.FileNotFound => {
                    try initDB(config);
                    break :check_block;
                },
                else => return err,
            }
        };

        db_file.close();
        const filepath = try alc.fba.alloc(u8, config.db_path.len + 1);
        defer alc.fba.free(filepath);
        for (filepath) |*c| c.* = 0;
        @memcpy(filepath[0..config.db_path.len], config.db_path);

        //if so, open and continue
        db = sql.Database.open(.{ .path = @ptrCast(filepath) }) catch |err| {
            std.log.err("{!}", .{err});
            return err;
        };
    }
}

pub fn deinit() void {
    db.close();
}

pub fn initDB(config: cfg.Configuration) !void {
    const filepath = try alc.fba.alloc(u8, config.db_path.len + 1);
    defer alc.fba.free(filepath);
    for (filepath) |*c| c.* = 0;
    @memcpy(filepath[0 .. filepath.len - 1], config.db_path);

    db = sql.Database.open(.{ .path = @as([*:0]const u8, @ptrCast(filepath)) }) catch |err| {
        std.log.err("{!}", .{err});
        return err;
    };

    try db.exec(usr.init_args, .{});
    try tbi.exec(usr.test_user, &db, usr.add_args);

    try db.exec(ste.init_args, .{});
    try tbi.exec(ste.test_site, &db, ste.add_args);

    try db.exec(ord.init_args, .{});
    try tbi.exec(ord.test_order, &db, ord.add_args);

    try db.exec(ast.init_args, .{});
    try tbi.exec(ast.test_asset, &db, ast.add_args);
}
