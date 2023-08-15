//this is to prevent the transpiler from being clever
Unshake();

//Run on start, it verifies application connection to host server
CheckAppConnection();


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
    if (xhr.readyState ===4 ) 
      if (xhr.response == "Hello!")
        document.body.append("Server connection status is: [good]");
  };
  
  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send("login" + "\n" + username + "\n" + password);
}


function CheckAppConnection(): void {
  const xhr = new XMLHttpRequest();
  
  xhr.onreadystatechange = () => {

    console.log( "XHR response: " + xhr.response);
    if (xhr.readyState ===4 ) 
      if (xhr.response == "Hello!")
      {
        (document.getElementById("connection_state") as HTMLInputElement).checked = true;
        console.log("Connection verified\n");        
      }

  };
  
  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send("Hello!");
}
