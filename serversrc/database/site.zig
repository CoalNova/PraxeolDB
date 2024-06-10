const std = @import("std");
const zap = @import("zap");
const sql = @import("sqlite");
const tmp = @import("../database/template.zig");
const alc = @import("../allocator.zig");
const fio = @import("../fullio.zig");

pub const Site = struct {
    site_id: i32 = 0,
    title: sql.Text = undefined,
    address: sql.Text = undefined,
    notes: sql.Text = undefined,
    contact_name: sql.Text = undefined,
    contact_phone: sql.Text = undefined,
};

pub const init_args =
    "CREATE TABLE site_data( site_id INT NOT NULL, address TEXT, contact_name " ++
    "TEXT, contact_phone TEXT, title TEXT, notes TEXT, PRIMARY KEY(site_id))";
pub const add_args =
    "INSERT INTO site_data VALUES" ++
    "( :site_id, :title, :address, :contact_name, :contact_phone, :notes);";
pub const del_args =
    "DELETE * FROM site_data WHERE site_id == :site_id";
pub const upd_args =
    "UPDATE site_data SET title = :title, address = :address, " ++
    "notes = :notes, contact_name = :contact_name, email = :contact_phone = :contact_phone, WHERE site_id == :site_id";

fn destroy(t_site: ?Site, allocator: std.mem.Allocator) void {
    if (t_site) |t| {
        allocator.free(t.site_id);
        allocator.free(t.title);
        allocator.free(t.address);
        allocator.free(t.notes);
        allocator.free(t.contact_name);
        allocator.free(t.contact_phone);
    }
}

pub const test_site: Site = .{
    .site_id = 0,
    .address = sql.text("5670 Old Hwy 66 Nowhere, Kansas 56761"),
    .contact_name = sql.text("Eustace Bagge"),
    .contact_phone = sql.text("555-555-5310"),
    .title = sql.text("Bagge Residence"),
    .notes = sql.text("Beware of Dog"),
};
