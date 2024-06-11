
let User = { user_id: "\0", site_id: "\0", username: "\0", password: "\0", _name: "\0", email: "\0", phone: "\0", permissions: "\0"};
let Asset = { asset_code: "\0", quantity: "\0", desc: "\0", brand: "\0", storage: "\0"};
let Site = { site_id: "\0", title: "\0", address: "\0", notes: "\0", contact_name: "\0", contact_phone: "\0"};
let Order = {  order_id: "\0", user_id: "\0", site_id: "\0", date: "\0", tracking: "\0", courier: "\0", assets: "\0" };

const Buttons = {
    ordering_button: 0,
    asset_button: 0,
    order_manage_button: 0,
    administration_button: 0
}

const Tabs = {
    ordering_tab: 0, 
    asset_tab: 0, 
    order_management_tab: 0, 
    admin_tab: 0
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
    
    disableTabs();

    Buttons.ordering_button = document.getElementById("ordering_button");
    Buttons.asset_button = document.getElementById("asset_button");
    Buttons.order_manage_button = document.getElementById("order_manage_button");
    Buttons.administration_button = document.getElementById("administration_button");

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
}

///Enables all applicable buttons, save for the active button 
function enableButtons(active) {
    Buttons.ordering_button.disabled = (Session.permissions & 0x0001 && active != 1) ? false : true;
    Buttons.asset_button.disabled = (Session.permissions & 0x0010 && active != 2) ? false : true;
    Buttons.order_manage_button.disabled = (Session.permissions & 0x0100 && active != 3) ? false : true;
    Buttons.administration_button.disabled = (Session.permissions & 0x1000 && active != 4) ? false : true;
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
                //oPrint(xhr.response);
            
            if (xhr.response.indexOf("found") > -1){
                oPrint("inv Quantity");
                document.getElementById("inv_quant_field").value = xhr.response.slice(6);

            }
            else
                document.getElementById("inv_quant_field").value = "NA";

        }
    };

    const uri_path = "";
    //oPrint(uri_path);
    
    xhr.open("POST", null, true);
    xhr.setRequestHeader('Content-Type', 'application/xml');
    xhr.send("query_q " + asset_code.trim());

}


function getUser() {
    
    const xhr = new XMLHttpRequest();
    // TODO send partial record for inquiry
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
                User.user_id = j.user_id;
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
        username : user_name,
        password : user_username,
        name : user_password,
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
};