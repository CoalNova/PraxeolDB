//! A collection of static and/or constant values meant to be accessed at any
//! position. Any const value will be thread safe, should multithreading be
//! desired.
const std = @import("std");
pub const app_embed = @embedFile("./buildassets/app.js");
pub const ico_embed = @embedFile("./buildassets/favicon.ico");

/// Configuration settings struct for server 
pub const ServerConfig = struct{
    web_port : u16 = default_web_port,
    app_port : u16 = default_app_port,
    landing_body : []const u8 = default_landing_body,
};

pub var server_config : ServerConfig = undefined;

/// Config file path
pub const config_path = "./prxconfig.ini";

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
pub fn loadConfigurationFile() void
{
    //if config not found, create one with default values
    std.debug.print("not yet implemented\n", .{});
    server_config = ServerConfig{};
}

pub fn createConfigurationFile() void
{
}