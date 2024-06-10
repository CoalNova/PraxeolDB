const std = @import("std");
const zap = @import("zap");
const sql = @import("sqlite");
const tmp = @import("../database/template.zig");
const alc = @import("../allocator.zig");
const fio = @import("../fullio.zig");

pub const Order = struct {
    order_id: i32 = 0,
    user_id: i32 = 0,
    site_id: i32 = 0,
    date: sql.Text = undefined,
    tracking: sql.Text = undefined,
    courier: sql.Text = undefined,
    manifest: sql.Text = undefined,
};

pub const init_args =
    "CREATE TABLE order_data(order_id INT NOT NULL, user_id INT NOT NULL, " ++
    "site_id INT NOT NULL, date TEXT, tracking TEXT, courier TEXT, manifest TEXT, " ++
    "PRIMARY KEY(order_id), FOREIGN KEY (site_id) REFERENCES site_data (site_id), " ++
    "FOREIGN KEY (user_id) REFERENCES user_data (user_id));";
pub const add_args =
    "INSERT INTO order_data VALUES" ++
    "( :order_id, :user_id, :site_id, :date, :tracking, :courier, :manifest );";
pub const del_args =
    "DELETE * FROM order_data WHERE order_id == :order_id";
pub const upd_args =
    "UPDATE order_data SET user_id = :user_id, date = :date, tracking = :tracking, " ++
    "courier = :courier, manifest = :manifest, WHERE order_id == :order_id";

pub fn destroy(order: ?Order, allocator: std.mem.Allocator) void {
    if (order) |t| {
        allocator.free(t.date.data);
        allocator.free(t.tracking.data);
        allocator.free(t.courier.data);
        allocator.free(t.manifest.data);
    }
}

pub const test_order: Order = .{
    .order_id = 2,
    .user_id = 1,
    .site_id = 0,
    .date = sql.text("2002-11-22"),
    .tracking = sql.text("1KATZ867DIL5309"),
    .courier = sql.text("Nowhere Post"),
    .manifest = sql.text("Dog Food x 1, Vinegar x 2"),
};
