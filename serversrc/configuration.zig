const std = @import("std");
const alc = @import("allocator.zig");

pub const Configuration = struct {
    hostname: []const u8 = "localhost",
    hostport: u16 = 4443,
    enable_logging: bool = true,
    db_path: []const u8 = "./praxeol.db",
    ssl_name: ?[:0]const u8 = "localhost",
    ssl_cert_pem: ?[:0]const u8 = null,
    ssl_privkey_pem: ?[:0]const u8 = null,
    ssl_privkey_pass: ?[:0]const u8 = null,
    self_hostname: []const u8 = "*",
    session_stack_size: usize = 256,
};

pub fn getConfig() Configuration {
    const flags = std.process.argsAlloc(alc.fba) catch |err| {
        std.log.err("{!}", .{err});
        return .{};
    };
    defer alc.fba.free(flags);

    const cwd = std.fs.cwd();
    //check if config exists, return if so
    var file = cwd.openFile("./praxeoldata/config.json", .{}) catch {

        //check if config creation flag is present, generate if so
        for (flags) |flag|
            if (std.mem.eql(u8, flag, "-gen")) {
                cwd.makeDir("./praxeoldata") catch |err| {
                    std.log.err("{!}", .{err});
                    return .{};
                };
                var f = cwd.createFile("./praxeoldata/config.json", .{}) catch |err| {
                    std.log.err("{!}", .{err});
                    return .{};
                };

                const j = std.json.stringifyAlloc(alc.fba, Configuration{}, .{}) catch |err| {
                    std.log.err("{!}", .{err});
                    return .{};
                };

                _ = f.write(j) catch |err| {
                    std.log.err("{!}", .{err});
                    return .{};
                };
            };
        return .{};
    };
    const contents = file.readToEndAlloc(alc.fba, 1 << 16) catch |err| {
        std.log.err("{!}", .{err});
        return .{};
    };
    const parsed = std.json.parseFromSlice(Configuration, alc.gpa, contents, .{}) catch |err| {
        std.log.err("{!}", .{err});
        return .{};
    };
    return parsed.value;
}
