const std = @import("std");

/// Size of Fixed Buffer Allocator
pub const fba_size = 1 << 20;
var fixed_buffer: [fba_size]u8 = undefined;
var fixed_buffer_allocator = std.heap.FixedBufferAllocator.init(&fixed_buffer);
/// Fixed Buffer Allocator
/// For use in handling non-persistant data.
pub const fba = fixed_buffer_allocator.allocator();

var general_porpoise_alligator = std.heap.GeneralPurposeAllocator(.{}){};
/// General Purpose Allocator
/// For use in handling persistant data.
pub const gpa = general_porpoise_alligator.allocator();
