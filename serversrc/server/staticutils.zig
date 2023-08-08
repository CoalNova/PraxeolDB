//! A collection of static and/or constant values meant to be accessed at any
//! position. Any const value will be thread safe, should multithreading be
//! desired.
const std = @import("std");
pub const app_embed = @embedFile("../buildassets/app.js");
pub const ico_embed = @embedFile("../buildassets/favicon.ico");

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
};

pub var server_config: ServerConfig = undefined;

/// Config file path
pub const default_data_path = "./";
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

/// The default index.html, the application should overwrite the text body to allow for
pub const index_html = "<!DOCTYPE html>\n<html>\n\t<head>\t\t<title>Welcome to PraxeolDB</title>" ++
    "\n\t</head>\n\t<body>\n\t\t<h1>Welcome to PraxeolDB</h1>\n\t\t<p>The server is not yet implemented.</p>" ++
    "\n\t\t<script src=\"app.js\"></script>\n\t</body>\n</html>";

/// Allocator
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

//standard writer
const stdout_file = std.io.getStdOut().writer();
pub var bw = std.io.bufferedWriter(stdout_file);
pub const stdout = bw.writer();

pub var buffer = [_]u8{0} ** 1024;

/// Loads configuration file or
pub fn loadConfigurationFile() void {

    //if config not found, create one with default values
    std.debug.print("not yet implemented\n", .{});
    createConfigurationFile();
    server_config = ServerConfig{};
}

pub fn createConfigurationFile() void {
    std.fs.cwd().makePath("./praxeoldata") catch |err|
        return std.debug.print("Folder creation error: {!}\n", .{err});
    var file = std.fs.cwd().createFile(default_config_path, .{}) catch |err|
        return std.debug.print("Config creation error: {!}\n", .{err});
    defer file.close();
}

pub const table_init_user_data =
    "CREATE TABLE USER_DATA( " ++
    "user_id    INT  NOT NULL, " ++
    "site_id    INT  NOT NULL, " ++
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
    "FOREIGN KEY (asst_id) REFERENCES" ++
    "   ASSET_DATA(asst_id)," ++
    "FOREIGN KEY (user_id) REFERENCES" ++
    "   SITE_DATA(user_id)" ++
    ")";
