//! For now, contains the active sessions and relevant data.
//! Sessions, as a collection, is a non-resized stack; the point of which is to store all active sessions.
//! Sessions are timekept and overwritten when timestamp delta has expired.
const std = @import("std");
const stc = @import("staticutils.zig");
const sql = @import("sqlutils.zig");

/// Session for verifying identity and requests
pub const Session = struct {
    session_id: [10]u8 = undefined,
    user_id: [10]u8 = undefined,
    /// Permissions are a statically sized (if not handled) selection of data, using hex approximation
    /// 0 - none, 1 - view, 2 - modify, 3 - delete
    /// 0b0000_00** for ordering
    /// 0b0000_**00 for self
    /// 0b00**_0000 for site
    /// 0b**00_0000 for server
    permission: u8 = 0,
    expiration: std.time.Instant = undefined,
};

/// Autho data
/// When returning the connection state request, bundle the Autho salt into the response
/// keep for us in case of
pub const Autho = struct {
    guest_id: [8]u8 = undefined,
    guest_off: [8]u8 = undefined,
    expiration: std.time.Instant = undefined,
};

var sessions: []?*Session = undefined;
var session_count: usize = 0;

var auths: []Autho = undefined;
var auth_counts: usize = 0;

/// Initializes Session collection to a presized amount as designated in the config.
/// (or supplied elsewhere in case)
pub fn init(max_sessions: usize) !void {
    sessions = try stc.allocator.alloc(?*Session, max_sessions);
    auths = try stc.allocator.alloc(Autho, max_sessions);
}
/// Frees memory and attempts to write a 0-length array for just-in-case uafs.
pub fn deinit() void {
    stc.allocator.free(sessions);
    sessions = undefined;
}

pub fn createSession(user: sql.User, allocator: std.mem.Allocator) *Session {
    _ = user;
    var session = allocator.create(Session);
    _ = session;
}
/// Attempts to create a session and place into sessions, returns session or failure if stack is full of valid sessions.
pub fn addSession(user: sql.User) !Session {

    // First see if session is already in the system (page refresh or prior timeout?) and update expiration
    for (sessions, 0..session_count) |*s, _| {
        if (std.mem.eql([]u8, user.user_id, s.user_id)) {
            s.expiration = std.time.Instant.now();
            return s.*;
        }
    }

    //create new session
    var session_id = user.permission[0..2] ++ user.user_id[0..6] ++ "hulloyes";
    var session = Session{
        .session_id = session_id,
        .user_id = user.user_id,
        .permission = user.permission,
        .expiration = std.time.Instant.now(),
    };

    //see if we can just plonk it at the end
    if (session_count + 1 < sessions.len) {
        sessions[session_count] = session;
        session_count += 1;
        return;
    }

    //else no more room at the inn
    return error.SessionStackFull;
}

pub fn getAutho(guest_id: [8]u8) !Autho {
    // first check if already exists, update time if so
    for (0..auth_counts) |i| {
        if (std.mem.eql(u8, &auths[i].guest_id, &guest_id)) {
            auths[i].expiration = std.time.Instant.now() catch unreachable;
            return auths[i];
        }
    }

    // make new autho
    var autho = Autho{
        .guest_id = guest_id,
        .expiration = std.time.Instant.now() catch unreachable,
        .guest_off = [_]u8{'8'} ** 8,
    };

    // add to end if not full
    if (auth_counts + 1 < auths.len) {
        auths[auth_counts] = autho;
        auth_counts += 1;
        return autho;
    }

    // see if any existing requests have expired
    for (0..auth_counts) |i| {
        if (autho.expiration.since(auths[i].expiration) > stc.server_config.expiration) {
            auths[i] = autho;
            return autho;
        }
    }

    // else, return full
    return error.AuthoStackFull;
}
