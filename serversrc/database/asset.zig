const std = @import("std");
const zap = @import("zap");
const sql = @import("sqlite");
const tmp = @import("../database/template.zig");
const alc = @import("../allocator.zig");
const fio = @import("../fullio.zig");

pub const Asset = struct {
    asset_code: sql.Text = undefined,
    quantity: i32 = 0,
    desc: sql.Text = undefined,
    brand: sql.Text = undefined,
    storage: sql.Text = undefined,
};

pub const init_args =
    "CREATE TABLE asset_data(asset_code TEXT, quantity INT, desc TEXT, brand TEXT, storage TEXT )";
pub const add_args =
    "INSERT INTO asset_data VALUES ( :asset_code, :quantity, :desc, :brand, :storage );";
pub const del_args =
    "DELETE * FROM asset_data WHERE asset_code == :asset_code";
pub const upd_args =
    "UPDATE asset_data SET quantity = :quantity, desc = :desc, brand = :brand, " ++
    "storage = :storage, WHERE asset_code == :site_id";

pub fn copy(a: Asset, allocator: std.mem.Allocator) !Asset {
    return create(
        a.asset_code,
        a.quantity,
        a.desc,
        a.brand,
        a.storage,
        allocator,
    );
}

pub fn create(
    asset_code: []const u8,
    quantity: i32,
    desc: []const u8,
    brand: []const u8,
    storage: []const u8,
    allocator: std.mem.Allocator,
) !Asset {
    const asset_code_ = try allocator.alloc(u8, asset_code.len);
    errdefer allocator.free(asset_code_);
    const desc_ = try allocator.alloc(u8, desc.len);
    errdefer allocator.free(desc_);
    const brand_ = try allocator.alloc(u8, brand.len);
    errdefer allocator.free(brand_);
    const storage_ = try allocator.alloc(u8, storage.len);
    errdefer allocator.free(storage_);
    const allocator_ = try allocator.alloc(u8, allocator.len);
    errdefer allocator.free(allocator_);

    @memcpy(asset_code_, asset_code);
    @memcpy(desc_, desc);
    @memcpy(brand_, brand);
    @memcpy(storage_, storage);
    @memcpy(allocator_, allocator);

    const asset: Asset = .{
        .quantity = quantity,
        .asset_code = sql.text(asset_code_),
        .desc = sql.text(desc_),
        .brand = sql.text(brand_),
        .storage = sql.text(storage_),
        .allocator = sql.text(allocator_),
    };

    return asset;
}

pub fn destroy(asset: ?Asset, allocator: std.mem.Allocator) void {
    if (asset) |t| {
        allocator.free(t.asset_code.data);
        allocator.free(t.desc.data);
        allocator.free(t.brand.data);
        allocator.free(t.storage.data);
    }
}

pub const test_asset: Asset = .{
    .asset_code = sql.text("D0G-0451"),
    .quantity = 63,
    .brand = sql.text("Pup!Rika!"),
    .desc = sql.text("Dog Chow"),
    .storage = sql.text("Under the sink"),
};
