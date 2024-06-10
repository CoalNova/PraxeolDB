const std = @import("std");
const zap = @import("zap");
const sql = @import("sqlite");
const tmp = @import("../database/template.zig");
const alc = @import("../allocator.zig");
const fio = @import("../fullio.zig");

pub const User = struct {
    user_id: i32 = undefined,
    site_id: i32 = undefined,
    username: sql.Text = undefined,
    password: sql.Text = undefined,
    name: sql.Text = undefined,
    email: sql.Text = undefined,
    phone: sql.Text = undefined,
    permission: sql.Text = undefined,
};

pub const init_args =
    "CREATE TABLE user_data( user_id INT NOT NULL, site_id INT, username TEXT, " ++
    "password TEXT, permission TEXT, name TEXT, email TEXT , phone TEXT, " ++
    "PRIMARY KEY(user_id), FOREIGN KEY (site_id) REFERENCES site_data (site_id))";
pub const add_args =
    "INSERT INTO user_data VALUES" ++
    "( :user_id, :site_id, :username, :password, :permission, :name, :email, :phone)";
pub const del_args =
    "DELETE * FROM user_data WHERE user_id == :user_id";
pub const upd_args =
    "UPDATE user_data SET site_id = :site_id, username = :username, password = :password, " ++
    "permission = :permission, name = :name, email = :email , phone = :phone, WHERE user_id == :user_id";

pub const test_user: User = .{
    .user_id = 1,
    .site_id = 0,
    .username = sql.text("admin"),
    .password = sql.text("password"),
    .permission = sql.text("FF"),
    .name = sql.text("Muriel Bagge"),
    .email = sql.text("mce.bagge@nowhere.net"),
    .phone = sql.text("555-555-5309"),
};
