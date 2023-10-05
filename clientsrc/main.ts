import { time } from "console";

//import from "hash-sum";
const sum = require('hash-sum');
const cry = require('crypto-js');

//offset for requests
var auth_offset = "";
const creation = Math.random() * 100;

//Run on start, it verifies application connection to host server
CheckAppConnection();

//this is to prevent the transpiler from being clever
Unshake();

//details and components of telling the optimization 
const leave_tree_unshaken = {AttemptLogin, CheckAppConnection};
function Unshake(): void
{
  if (typeof(leave_tree_unshaken) == typeof(Uint8Array) )
    console.log("Achtung!");
    
}


//Attempts a login through POST and receives back a confirmation of a sessionID
function AttemptLogin(): void{
  const xhr = new XMLHttpRequest();
  const username = (document.getElementById("session_username") as HTMLInputElement).value;
  const password = (document.getElementById("session_password") as HTMLInputElement).value;

  xhr.onreadystatechange = () => {
    console.log(xhr.response);
    if (xhr.readyState === 4 ) 
      if (xhr.response.indexOf("not guilty") > -1)
        (document.getElementById("session_id") as HTMLInputElement).value = xhr.response.slice(10);
  };

  console.log(password + auth_offset.toString());
  const pass_hash = cry.SHA256(password + auth_offset.toString());

  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  console.log("login" + " " + username + " " + pass_hash);
  xhr.send("login" + sum(creation) + " " + username + " " + pass_hash);
}


function CheckAppConnection(): void {
  const xhr = new XMLHttpRequest();
  
  xhr.onreadystatechange = () => {

    console.log( "XHR response: " + xhr.response);
    if (xhr.readyState === 4 ) 
    var index  = xhr.response.indexOf("Hello!");
      if ( index > -1)
      {
        (document.getElementById("connection_state") as HTMLInputElement).checked = true;
        console.log("Connection verified\n");
        auth_offset = String(xhr.response).substring(index+6);        
      }
      else
      {
        console.log("Connection test failed, server said\n");
      }

  };
  
  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send("Hello!" + sum(creation));
}
