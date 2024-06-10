const usr = @import("../database/user.zig");

pub const UserPermissions = enum(u8) {
    none = 0,

    ///Login prevention in cases of expired/compromised passwords
    can_login = 0b0001,
    ///User is permitted to query inventory levels
    can_query = 0b0010,
    ///User is permitted to order inventory
    can_order = 0b0100,
    ///User is permitted to adjust internal on-hands and inventory placement
    can_alter = 0b1000,

    ///User can query orders and alter
    can_order_access = 0b0001_0000,

    ///User can request full inventory data
    can_inventory_access = 0b0010_0000,

    ///User is allowed to query other user accounts
    can_user_query = 0b0100_0000,
    ///User is allowed to alter other user accounts
    can_user_alter = 0b1000_0000,
};

pub const UserSession = struct {
    user_id: u64 = 0,
    expiry: u64 = 0,
    session_id: [512]u8 = undefined,
    permissions: UserPermissions = .none,
    bad_attempts: u8 = 0,
};

pub fn createSession(user: *usr.User) UserSession {
    _ = user;
    var us = UserSession{};
    _ = &us;
    return us;
}

pub fn terminateSession(us: UserSession) void {
    _ = us;
}

pub fn verifySession(session_id: []const u8) UserSession {
    _ = session_id;
    return UserSession{};
}

pub fn verifySessionPerms(session_id: []const u8, user_perm_array: u8) bool {
    _ = session_id;
    _ = user_perm_array;
}
