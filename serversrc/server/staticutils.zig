//! Static Utils
//! A collection of static and/or constant values meant to be accessed at any
//! position. Any const value will be thread safe, should multithreading be
//! desired.
const std = @import("std");
pub const app_embed = @embedFile("../buildassets/app.js");
pub const ico_embed = @embedFile("../buildassets/favicon.ico");
pub const web_embed = @embedFile("../buildassets/index.html");

/// Configuration settings struct for server
pub const ServerConfig = struct {
    web_port: u16 = default_web_port,
    app_port: u16 = default_app_port,
    config_path: []const u8 = default_config_path,
    db_path: []const u8 = default_db_path,
    js_path: []const u8 = default_js_path,
    html_path: []const u8 = default_html_path,
    fvcn_path: []const u8 = default_fvcn_path,
    data_path: []const u8 = default_data_path,
    landing_body: []const u8 = default_landing_body,
    hostname: []const u8 = "*", //TODO catch configured hostname
    expiration: u64 = default_expiration_period,
    session_stack_size: usize = 256,
};

pub var server_config: ServerConfig = undefined;

/// Config file path
pub const default_data_path = "./praxeoldata/";
pub const default_config_path = default_data_path ++ "praxeol.cfg";
pub const default_db_path = default_data_path ++ "praxeol.db";
pub const default_js_path = default_data_path ++ "app.js";
pub const default_html_path = default_data_path ++ "index.html";
pub const default_fvcn_path = default_data_path ++ "favicon.ico";

/// Default port value, intercepted and changed by config during startup
pub const default_web_port = 8080;
pub const default_app_port = 9864;

/// Internal landing page
pub const default_landing_body = "<html><body><h1>HTTP ERROR 404</h1> " ++
    "This page was reached in error, please insure configuration correctness " ++
    "or remove/delete configuration file to set settings to default.</body></html>";

/// The default index.html
pub const index_html = web_embed;

/// Default expiration period for sessions and auths (30 minutes)
pub const default_expiration_period: u64 = 1800000000000;

/// Allocator
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

/// Pseudo Rand
pub var rand = std.rand.DefaultPrng.init(0);

//standard writer
const stdout_file = std.io.getStdOut().writer();
pub var bw = std.io.bufferedWriter(stdout_file);
pub const stdout = bw.writer();

pub var buffer = [_]u8{0} ** 1024;

pub const table_init_user_data =
    "CREATE TABLE USER_DATA( " ++
    "user_id    INT  NOT NULL, " ++
    "site_id    INT, " ++
    "username   TEXT NOT NULL, " ++
    "password   TEXT NOT NULL, " ++
    "permission TEXT NOT NULL, " ++
    "firstname  TEXT NOT NULL, " ++
    "lastname   TEXT NOT NULL, " ++
    "email      TEXT NOT NULL, " ++
    "phone      TEXT NOT NULL, " ++
    "PRIMARY KEY (user_id), " ++
    "FOREIGN KEY (site_id) REFERENCES" ++
    "   SITE_DATA(site_id)" ++
    ");";

pub const table_init_site_data =
    "CREATE TABLE SITE_DATA(" ++
    "site_id    INT  NOT NULL, " ++
    "address    TEXT NOT NULL, " ++
    "city       TEXT NOT NULL, " ++
    "state      TEXT NOT NULL, " ++
    "contact    TEXT NOT NULL, " ++
    "phone      TEXT NOT NULL, " ++
    "PRIMARY KEY (site_id)" ++
    ")";

pub const table_init_asset_data =
    "CREATE TABLE ASSET_DATA(" ++
    "asst_id    INT  NOT NULL, " ++
    "invcode    TEXT NOT NULL, " ++
    "quantity   TEXT NOT NULL, " ++
    "desc       TEXT NOT NULL, " ++
    "brand      TEXT NOT NULL, " ++
    "storage    TEXT NOT NULL, " ++
    "PRIMARY KEY (asst_id)" ++
    ")";

pub const table_init_order_data =
    "CREATE TABLE ORDER_DATA(" ++
    "ordr_id    INT  NOT NULL, " ++
    "user_id    INT  NOT NULL, " ++
    "dateplaced TEXT NOT NULL, " ++
    "datefilled TEXT NOT NULL, " ++
    "payload    BLOB NOT NULL, " ++
    "tracking   TEXT," ++
    "PRIMARY KEY (ordr_id)" ++
    "FOREIGN KEY (user_id) REFERENCES" ++
    "   SITE_DATA(user_id)" ++
    ")";
