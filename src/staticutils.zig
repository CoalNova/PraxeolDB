//! A collection of static and/or constant values meant to be accessed at any
//! position. Any const value will be thread safe, should multithread be
//! desired.

const std = @import("std");

/// Config file path
pub const config_path = "./prxconfig.ini";

/// Default port value, intercepted and changed by config during startup
pub const web_port = 80;
pub const prx_port = 9864;

/// Path to default HTML landing page file.
/// Null is use internal.
pub const landing_page : []const u8 = "";


/// Allocator
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

//standard writer
const stdout_file = std.io.getStdOut().writer();
pub var bw = std.io.bufferedWriter(stdout_file);
pub const stdout = bw.writer();


pub var buffer = [_]u8{0} ** 1024;