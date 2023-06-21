const std = @import("std");

//allocator
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

//standard writer
const stdout_file = std.io.getStdOut().writer();
pub var bw = std.io.bufferedWriter(stdout_file);
pub const stdout = bw.writer();

//the server
var server : std.http.Server = undefined;

//the buffer (dynsize might take too long)
const buff_size : usize = 4096;
var buffer = [_]u8{0} ** buff_size;

/// Initilalizes the server and socket to accept incoming requests 
pub fn init(address : std.net.Address) !void
{   
    server = std.http.Server.init(allocator, .{
            .kernel_backlog = 128, 
            .reuse_address = true, 
            .reuse_port = true, 
        });

    try server.socket.listen(address);
}

/// Processes requests 
pub fn proc() !void {
    const response = try server.accept(std.http.Server.AcceptOptions{.allocator = allocator, 
        .header_strategy = .{
            .static = &buffer,
    }});
    _ = response;
}

/// Deinitialize server and resource(s)
pub fn deinit() void{
    server.deinit();
}