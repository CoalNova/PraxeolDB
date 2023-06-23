pub const sql_3 = @cImport({
    @cInclude("sqlite3.h");
});

pub const User = struct{

};

pub const Location = struct{

};

pub const Asset = struct{

};

pub const Order = struct {

};

pub const Transaction = struct {

};

pub fn getUser() User{
    @panic("not yet implemented");
}

pub fn getLocation() Location{
    @panic("not yet implemented");
}

pub fn getAsset() Asset{
    @panic("not yet implemented");
}

pub fn getOrder() Asset{
    @panic("not yet implemented");
}

pub fn getTransaction() Asset{
    @panic("not yet implemented");
}