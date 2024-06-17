
let User = { user_id: "\0", site_id: "\0", username: "\0", password: "\0", _name: "\0", email: "\0", phone: "\0", permissions: "\0"};
let Site = { site_id: "\0", title: "\0", address: "\0", notes: "\0", contact_name: "\0", contact_phone: "\0"};
let Asset = { asset_code: "\0", quantity: "\0", desc: "\0", brand: "\0", storage: "\0"};
let Order = {  order_id: "\0", user_id: "\0", site_id: "\0", date: "\0", tracking: "\0", courier: "\0", assets: "\0" };

const Buttons = {
    ordering_button: 0,
    asset_button: 0,
    order_manage_button: 0,
    administration_button: 0,
    site_button: 0
}

const Tabs = {
    ordering_tab: 0, 
    asset_tab: 0, 
    order_management_tab: 0, 
    admin_tab: 0,
    site_tab:0
};

const Session = { 
    session_id: 0, 
    permissions: 0 //bitmask
}

//==================================

setupPage();

//==================================

function queryServer(){
    //TODO reconnect to server, perhaps check for faults in encryption
    setTimeout(100);
}
    
function setupPage() {
    queryServer()

    Session.session_id = 0;
    Session.permissions = 0;

    Tabs.ordering_tab = document.getElementById("ordering_tab");
    Tabs.asset_tab = document.getElementById("asset_tab");
    Tabs.order_management_tab = document.getElementById("order_management_tab");
    Tabs.admin_tab = document.getElementById("admin_tab");
    Tabs.site_tab = document.getElementById("site_tab");
    
    disableTabs();

    Buttons.ordering_button = document.getElementById("ordering_button");
    Buttons.asset_button = document.getElementById("asset_button");
    Buttons.order_manage_button = document.getElementById("order_manage_button");
    Buttons.administration_button = document.getElementById("administration_button");
    Buttons.site_button = document.getElementById("site_button");

    enableButtons(0);
}

function setTab(tab_num) {
    disableTabs();
    switch (tab_num) {
        case 0:
            enableButtons(0);
        break;
        case 1:
            document.getElementById("body").appendChild(Tabs.ordering_tab);
            enableButtons(tab_num);
        break;
        case 2:
            document.getElementById("body").appendChild(Tabs.asset_tab);
            enableButtons(tab_num);
        break;
        case 3:
            document.getElementById("body").appendChild(Tabs.order_management_tab);
            enableButtons(tab_num);
        break;
        case 4:
            document.getElementById("body").appendChild(Tabs.admin_tab);
            enableButtons(tab_num);
        break;
        case 5:
            document.getElementById("body").appendChild(Tabs.site_tab);
            enableButtons(tab_num);
        break;
                                                
        default:
            break;
    }
}

function disableTabs() {
    let t = document.getElementById("ordering_tab");
    if (t != null) t.remove();
    t = document.getElementById("asset_tab");
    if (t != null) t.remove();
    t = document.getElementById("order_management_tab");
    if (t != null) t.remove();
    t = document.getElementById("admin_tab");
    if (t != null) t.remove();
    t = document.getElementById("site_tab");
    if (t != null) t.remove();
}

///Enables all applicable buttons, save for the active button 
function enableButtons(active) {
    Buttons.ordering_button.disabled = (Session.permissions & 0x0001 && active != 1) ? false : true;
    Buttons.asset_button.disabled = (Session.permissions & 0x0010 && active != 2) ? false : true;
    Buttons.order_manage_button.disabled = (Session.permissions & 0x0100 && active != 3) ? false : true;
    Buttons.administration_button.disabled = (Session.permissions & 0x1000 && active != 4) ? false : true;
    Buttons.site_button.disabled = (Session.permissions & 0x1000 && active != 5) ? false : true;
}

function login() {
    oPrint("login");

    const xhr = new XMLHttpRequest();
    const username = document.getElementById("username_field").value;
    const password = document.getElementById("password_field").value;

    xhr.onreadystatechange = () => {
        if (xhr.readyState === 4 ) 
        {
            oPrint(xhr.response);
            
            if (xhr.response.indexOf("not guilty") > -1){
                document.getElementById("session_field").value = xhr.response.slice(10);
                Session.permissions = 0x1111; //bitmask enable all
                setTab(1);
            }
        }
    };

    const uri_path = window.location.protocol + "//" + window.location.hostname + ":" +window.location.port;
    //oPrint(uri_path);
    
    xhr.open("POST", uri_path, true);
    xhr.setRequestHeader('Content-Type', 'application/xml');
    xhr.send("login " + username + " " + password);
}

function placeOrder() {
    console.log("place order");
    
}

function invQuant() {
    
    const xhr = new XMLHttpRequest();
    const asset_code = document.getElementById("asset_code_field").value;
    
    xhr.onreadystatechange = () => {
        if (xhr.readyState === 4 ) 
            {
            if (xhr.response.indexOf("found") > -1){
                oPrint("inv Quantity");
                document.getElementById("inv_quant_field").value = xhr.response.slice(6);
            }
            else
                document.getElementById("inv_quant_field").value = "NA";
        }
    };

    const uri_path = "";
    
    xhr.open("POST", null, true);
    xhr.setRequestHeader('Content-Type', 'application/xml');
    xhr.send("query_q " + asset_code.trim());

}


function clearUserFields() {
    document.getElementById("user_table_id_field").value = "";
    document.getElementById("user_table_site_id_field").value = "";
    document.getElementById("user_table_name_field").value = "";
    document.getElementById("user_table_username_field").value = "";
    document.getElementById("user_table_password_field").value = "";
    document.getElementById("user_table_email_field").value = "";
    document.getElementById("user_table_phone_field").value = "";
    document.getElementById("user_table_permissions_field").value = "";
}

function getUser() {
    
    const xhr = new XMLHttpRequest();
    const user_id = document.getElementById("user_table_id_field").value;
    const user_site_id = document.getElementById("user_table_site_id_field").value;
    const user_name = document.getElementById("user_table_name_field").value;
    const user_username = document.getElementById("user_table_username_field").value;
    const user_password = document.getElementById("user_table_password_field").value;
    const user_email = document.getElementById("user_table_email_field").value;
    const user_phone = document.getElementById("user_table_phone_field").value;
    const user_permissions = document.getElementById("user_table_permissions_field").value;

    xhr.onreadystatechange = () => {
        if (xhr.readyState === 4 ) 
            {
                oPrint(xhr.response);
                const j = JSON.parse(xhr.response);
                
                // assignment operations return the assignment
                document.getElementById("user_table_id_field").value = User.user_id = j.user_id;
                document.getElementById("user_table_site_id_field").value = User.site_id = j.site_id;
                document.getElementById("user_table_name_field").value = User._name = j.name;
                document.getElementById("user_table_username_field").value = User.username = j.username;
                document.getElementById("user_table_password_field").value = User.password = j.password;
                document.getElementById("user_table_email_field").value = User.email = j.email;
                document.getElementById("user_table_phone_field").value = User.phone = j.phone;
                document.getElementById("user_table_permissions_field").value = User.permissions = j.permissions;
        }
    };

    const uri_path = "";
    //oPrint(uri_path);
    
    let json_user = JSON.stringify({
        user_id : user_id,
        site_id : user_site_id,
        username : user_username,
        password : user_password,
        name : user_name,
        email : user_email,
        phone : user_phone,
        permission : user_permissions,
    });

    xhr.open("POST", null, true);
    xhr.setRequestHeader('Content-Type', 'application/xml');
    console.log("get_u " + json_user + " " + Session.session_id);
    xhr.send("get_u " + json_user + " " + Session.session_id);

}
function setUser() {
    console.log("setuser");

}
function addUser() {
    console.log("adduser");

}
function delUser() {
    console.log("deluser");

}

function getAsset() {
    
    const xhr = new XMLHttpRequest();
    const asset_code = document.getElementById("asset_table_code_field").value;
    
    xhr.onreadystatechange = () => {
        if (xhr.readyState === 4 ) 
            {
                oPrint(xhr.response);
                const j = JSON.parse(xhr.response);

                document.getElementById("asset_table_quant_field").value = j.quantity;
                document.getElementById("asset_table_desc_field").value = j.desc;
                document.getElementById("asset_table_manufacture_field").value = j.brand;
                document.getElementById("asset_table_storage_field").value = j.storage;
        }
    };

    const uri_path = "";
    //oPrint(uri_path);
    
    xhr.open("POST", null, true);
    xhr.setRequestHeader('Content-Type', 'application/xml');
    xhr.send("get_a " + asset_code.trim() + " " + Session.session_id);
}
function setAsset() {
    console.log("setasset");

}
function addAsset() {
    console.log("addasset");

}
function delAsset() {
    console.log("delasset");

}

function getSite() {
    const xhr = new XMLHttpRequest();
    const asset_code = document.getElementById("asset_table_code_field").value;
    
    xhr.onreadystatechange = () => {
        if (xhr.readyState === 4 ) 
            {
                oPrint(xhr.response);
                const j = JSON.parse(xhr.response);

                document.getElementById("asset_table_quant_field").value = j.quantity;
                document.getElementById("asset_table_desc_field").value = j.desc;
                document.getElementById("asset_table_manufacture_field").value = j.brand;
                document.getElementById("asset_table_storage_field").value = j.storage;
        }
    };

    const uri_path = "";
    //oPrint(uri_path);
    
    xhr.open("POST", null, true);
    xhr.setRequestHeader('Content-Type', 'application/xml');
    xhr.send("get_a " + asset_code.trim() + " " + Session.session_id);
}
function setSite() {
    console.log("setsite");

}
function addSite() {
    console.log("addsite");

}
function delSite() {
    console.log("delsite");

}

function getOrder() {
    
    const xhr = new XMLHttpRequest();
    const asset_code = document.getElementById("asset_table_code_field").value;
    
    xhr.onreadystatechange = () => {
        if (xhr.readyState === 4 ) 
            {
                oPrint(xhr.response);
                const j = JSON.parse(xhr.response);

                document.getElementById("asset_table_quant_field").value = j.quantity;
                document.getElementById("asset_table_desc_field").value = j.desc;
                document.getElementById("asset_table_manufacture_field").value = j.brand;
                document.getElementById("asset_table_storage_field").value = j.storage;
        }
    };

    const uri_path = "";
    //oPrint(uri_path);
    
    xhr.open("POST", null, true);
    xhr.setRequestHeader('Content-Type', 'application/xml');
    xhr.send("get_a " + asset_code.trim() + " " + Session.session_id);

}
function setOrder() {
    console.log("setorder");

}
function addOrder() {
    console.log("addorder");

}
function delOrder() {
    console.log("delorder");

}


function oPrint(s) {
    const doc_part = document.getElementById("output_field");
    doc_part.value = s + "\n" + doc_part.value;
    if (doc_part.value.len > 200) doc_part.value = doc_part.value.substring(0,180);
} 

//User field and object functions

function flashUserToFields() {
    document.getElementById("user_table_id_field").value = User.user_id;
    document.getElementById("user_table_site_id_field").value = User.site_id;
    document.getElementById("user_table_name_field").value = User._name;
    document.getElementById("user_table_username_field").value = User.username;
    document.getElementById("user_table_password_field").value = User.password;
    document.getElementById("user_table_email_field").value = User.email;
    document.getElementById("user_table_phone_field").value = User.phone;
    document.getElementById("user_table_permissions_field").value = User.permissions;
}

function flashFieldsToUser() {
    User.user_id = document.getElementById("user_table_id_field").value;
    User.site_id = document.getElementById("user_table_site_id_field").value;
    User._name = document.getElementById("user_table_name_field").value;
    User.username = document.getElementById("user_table_username_field").value;
    User.password = document.getElementById("user_table_password_field").value;
    User.email = document.getElementById("user_table_email_field").value;
    User.phone = document.getElementById("user_table_phone_field").value;
    User.permissions = document.getElementById("user_table_permissions_field").value;
}

function userFieldsToJSON() {
    flashFieldsToUser();
    return JSON.stringify({
        user_id : User.user_id,
        site_id : User.site_id,
        username : User.username,
        password : User.password,
        name : User._name,
        email : User.email,
        phone : User.phone,
        permission : User.permissions,
    });
}

function jsonToUserFields(str) {
    const j = JSON.parse(str);
    User.user_id = j.user_id;
    User.site_id = j.site_id;
    User._name = j.name;
    User.username = j.username;
    User.password = j.password;
    User.email = j.email;
    User.phone = j.phone;
    User.permissions = j.permissions;
    flashUserToFields();
}

//Site field and object functions
//Site = { site_id: "\0", title: "\0", address: "\0", notes: "\0", contact_name: "\0", contact_phone: "\0"};

function flashSiteToFields() {
    document.getElementById("site_table_id_field").value = Site.site_id;
    document.getElementById("site_table_title_field").value = Site.title;
    document.getElementById("site_table_address_field").value = Site.address;
    document.getElementById("site_table_notes_field").value = Site.notes;
    document.getElementById("site_table_contact_name_field").value = Site.contact_name;
    document.getElementById("site_table_contact_phone_field").value = Site.contact_phone;
}

function flashFieldsToSite() {
    document.getElementById("site_table_id_field").value = Site.site_id;
    document.getElementById("site_table_title_field").value = Site.title;
    document.getElementById("site_table_address_field").value = Site.address;
    document.getElementById("site_table_notes_field").value = Site.notes;
    document.getElementById("site_table_contact_name_field").value = Site.contact_name;
    document.getElementById("site_table_contact_phone_field").value = Site.contact_phone;
}

function siteFieldsToJSON() {
    flashFieldsToSite();
    return JSON.stringify({
        site_id : Site.site_id,
        title : Site.title,
        address : Site.address,
        notes : Site.notes,
        contact_name : Site.contact_name,
        contact_phone : Site.contact_phone,
    });
}

function jsonToSiteFields(str) {
    const j = JSON.parse(str);
    Site.site_id = j.site_id;
    Site.title = j.title;
    Site.address = j.address;
    Site.notes = j.notes;
    Site.contact_name = j.contact_name;
    Site.contact_phone = j.contact_phone;
    flashSiteToFields();
}

//Asset field and object functions
//let Asset = { asset_code: "\0", quantity: "\0", desc: "\0", brand: "\0", storage: "\0"};

function flashAssetToFields() {
    document.getElementById("asset_table_code_field").value = Asset.asset_code;
    document.getElementById("asset_table_quant_field").value = Asset.quantity;
    document.getElementById("asset_table_desc_field").value = Asset.desc;
    document.getElementById("asset_table_manufacture_field").value = Asset.brand;
    document.getElementById("asset_table_storage_field").value = Asset.storage;
}

function flashFieldsToAsset() {
    Asset.asset_code = document.getElementById("asset_table_code_field").value;
    Asset.quantity = document.getElementById("asset_table_quant_field").value;
    Asset.desc = document.getElementById("asset_table_desc_field").value;
    Asset.brand = document.getElementById("asset_table_manufacture_field").value;
    Asset.storage = document.getElementById("asset_table_storage_field").value;
}

function assetFieldsToJSON() {
    flashFieldsToAsset();
    return JSON.stringify({
        asset_code : Asset.asset_code,
        quantity : Asset.quantity,
        desc : Asset.desc,
        brand : Asset.brand,
        storage : Asset.storage,
    });
}

function jsonToAssetFields(str) {
    const j = JSON.parse(str);
    Asset.asset_code = j.asset_code;
    Asset.quantity = j.quantity;
    Asset.desc = j.desc;
    Asset.brand = j.brand;
    Asset.storage = j.storage;
    flashAssetToFields();
}

//Order field and object functions
//let Order = {  order_id: "\0", user_id: "\0", site_id: "\0", date: "\0", tracking: "\0", courier: "\0", assets: "\0" };

function flashOrderToFields() {
    document.getElementById("order_table_id_field").value = Order.order_id;
    document.getElementById("order_table_user_id_field").value = Order.user_id;
    document.getElementById("order_table_site_id_field").value = Order.site_id;
    document.getElementById("order_table_date_field").value = Order.date;
    document.getElementById("order_table_tracking_field").value = Order.tracking;
    document.getElementById("order_table_courier_field").value = Order.courier;
    document.getElementById("order_table_assets_field").value = Order.assets;
}

function flashFieldsToOrder() {
     Order.order_id = document.getElementById("order_table_id_field").value;
     Order.user_id = document.getElementById("order_table_user_id_field").value;
     Order.site_id = document.getElementById("order_table_site_id_field").value;
     Order.date = document.getElementById("order_table_date_field").value;
     Order.tracking = document.getElementById("order_table_tracking_field").value;
     Order.courier = document.getElementById("order_table_courier_field").value;
     Order.assets = document.getElementById("order_table_assets_field").value;
}

function orderFieldsToJSON() {
    flashFieldsToOrder();
    return JSON.stringify({
        order_id : Order.order_id,
        user_id : Order.user_id,
        site_id : Order.site_id,
        date : Order.date,
        tracking : Order.tracking,
        courier : Order.courier,
        assets : Order.assets,
    });
}

function jsonToOrderFields(str) {
    const j = JSON.parse(str);
    Order.order_id = j.order_id;
    Order.user_id = j.user_id;
    Order.site_id = j.site_id;
    Order.date = j.date;
    Order.tracking = j.tracking;
    Order.courier = j.courier;
    Order.assets = j.assets;
    flashOrderToFields();
}
