const std = @import("std");
const stc = @import("staticutils.zig");

/// Loads configuration file or
pub fn loadConfigurationFile() !void {
    std.fs.cwd().makePath("./praxeoldata") catch |err| {
        std.debug.print("Folder creation error: {!}\n", .{err});
        return err;
    };

    //if config not found, create one with default values
    var file = std.fs.cwd().openFile(stc.default_config_path, .{}) catch |err| switch (err) {
        error.FileNotFound => return createConfigurationFile(),
        else => {
            std.log.err("Error opening config file: {!}", .{err});
            return;
        },
    };
    defer file.close();

    const contents = try file.readToEndAlloc(stc.allocator, 2048);
    defer stc.allocator.free(contents);

    var new_string: []u8 = undefined;

    var lines = std.mem.splitScalar(u8, contents, '\n');
    stc.server_config = .{};
    while (lines.next()) |line| {
        if (line.len > 10) {
            if (std.mem.eql(u8, line[0..12], ".web_port = ")) {
                if (!std.mem.eql(u8, line[12..20], ".default"))
                    stc.server_config.web_port =
                        try std.fmt.parseUnsigned(u16, line[12 .. line.len - 2], 10);
            }
            if (std.mem.eql(u8, line[0..12], ".app_port = ")) {
                if (!std.mem.eql(u8, line[12..20], ".default"))
                    stc.server_config.app_port =
                        try std.fmt.parseUnsigned(u16, line[12 .. line.len - 2], 10);
            }
            if (std.mem.eql(u8, line[0..11], ".db_path = ")) {
                if (!std.mem.eql(u8, line[11..19], ".default")) {
                    new_string = try stc.allocator.alloc(u8, line.len - 13);
                    for (line[11 .. line.len - 2], 0..) |c, i| new_string[i] = c;
                    stc.server_config.db_path = new_string;
                }
            }
            if (std.mem.eql(u8, line[0..11], ".js_path = ")) {
                if (!std.mem.eql(u8, line[11..19], ".default")) {
                    new_string = try stc.allocator.alloc(u8, line.len - 13);
                    for (line[11 .. line.len - 2], 0..) |c, i|
                        new_string[i] = c;
                    stc.server_config.js_path = new_string;
                }
            }
            if (std.mem.eql(u8, line[0..13], ".html_path = ")) {
                if (!std.mem.eql(u8, line[13..21], ".default")) {
                    new_string = try stc.allocator.alloc(u8, line.len - 15);
                    for (line[13 .. line.len - 2], 0..) |c, i|
                        new_string[i] = c;
                    stc.server_config.html_path = new_string;
                }
            }
            if (std.mem.eql(u8, line[0..13], ".fvcn_path = ")) {
                if (!std.mem.eql(u8, line[13..21], ".default")) {
                    new_string = try stc.allocator.alloc(u8, line.len - 13);
                    for (line[11 .. line.len - 2], 0..) |c, i|
                        new_string[i] = c;
                    stc.server_config.fvcn_path = new_string;
                }
            }
            if (std.mem.eql(u8, line[0..13], ".data_path = ")) {
                if (!std.mem.eql(u8, line[13..21], ".default")) {
                    new_string = try stc.allocator.alloc(u8, line.len - 13);
                    for (line[11 .. line.len - 2], 0..) |c, i|
                        new_string[i] = c;
                    stc.server_config.data_path = new_string;
                }
            }
            if (std.mem.eql(u8, line[0..16], ".landing_body = ")) {
                if (!std.mem.eql(u8, line[16..24], ".default")) {
                    new_string = try stc.allocator.alloc(u8, line.len - 16);
                    for (line[14 .. line.len - 2], 0..) |c, i|
                        new_string[i] = c;
                    stc.server_config.landing_body = new_string;
                }
            }
            if (std.mem.eql(u8, line[0..12], ".hostname = ")) {
                if (!std.mem.eql(u8, line[12..20], ".default")) {
                    new_string = try stc.allocator.alloc(u8, line.len - 12);
                    for (line[10 .. line.len - 2], 0..) |c, i|
                        new_string[i] = c;
                    stc.server_config.hostname = new_string;
                }
            }
            if (std.mem.eql(u8, line[0..14], ".expiration = ")) {
                if (!std.mem.eql(u8, line[14..22], ".default"))
                    stc.server_config.expiration =
                        try std.fmt.parseUnsigned(u16, line[14 .. line.len - 2], 10);
            }
            if (std.mem.eql(u8, line[0..14], ".stack_size = ")) {
                if (!std.mem.eql(u8, line[14..22], ".default"))
                    stc.server_config.session_stack_size =
                        try std.fmt.parseUnsigned(u16, line[22 .. line.len - 2], 10);
            }
        }
    }
}

pub fn createConfigurationFile() !void {
    std.fs.cwd().makePath("./praxeoldata") catch |err| {
        std.debug.print("Folder creation error: {!}\n", .{err});
        return err;
    };

    var file = std.fs.cwd().createFile(stc.default_config_path, .{}) catch |err| {
        std.debug.print("Config creation error: {!}\n", .{err});
        return err;
    };

    //FADED67
    // follow zig (and zon) syntax formatting
    // [.default] is default value
    // ["./some/va.lue"] as a string is an override for the relative location
    defer file.close();
    _ = file.write(".{\n") catch unreachable;

    _ = file.write("    .web_port = .default,\n") catch unreachable; //web_port
    _ = file.write("    .app_port = .default,\n") catch unreachable; //app_port
    _ = file.write("    .db_path = .default,\n") catch unreachable; //db_path
    _ = file.write("    .js_path = .default,\n") catch unreachable; //js_path
    _ = file.write("    .html_path = .default,\n") catch unreachable; //html_path
    _ = file.write("    .fvcn_path = .default,\n") catch unreachable; //fvcn_path
    _ = file.write("    .data_path = .default,\n") catch unreachable; //data_path
    _ = file.write("    .landing_body = .default,\n") catch unreachable; //landing_body
    _ = file.write("    .hostname = .default,\n") catch unreachable; //hostname
    _ = file.write("    .expiration = .default,\n") catch unreachable; //expiration
    _ = file.write("    .session_stack_size = .default,\n") catch unreachable; //session_stack_size

    _ = file.write("};") catch unreachable;
}

pub const ServerStates = enum(u8) {
    ok = 0,
    incorrect_password = 1,
    exec_invalid = 3,
    incorrect_field_assignment = 5,
};
