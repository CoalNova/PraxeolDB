document.body.append("Application is not yet fully implemented. \n");

Unshake();

//checkAppConnection(document);
const leave_tree_unshaken = {AttemptLogin, CheckAppConnection};

function Unshake(): void
{
  if (typeof(leave_tree_unshaken) == typeof(Uint8Array) )
    console.log("Achtung!");
    
}



function AttemptLogin(): void{
  const xhr = new XMLHttpRequest();
  const encoder = new TextEncoder();
  const username = encoder.encode((document.getElementById("session_username") as HTMLInputElement).value);
  const password = encoder.encode((document.getElementById("session_password") as HTMLInputElement).value);
  
  const send_array = new Uint8Array(64);

  for (let i = 0; i < username.length; i++) 
    send_array[i] = username[i];

  xhr.onreadystatechange = () => {

    console.log(xhr.response);
    if (xhr.readyState ===4 ) 
      if (xhr.response == "Hello!")
        document.body.append("Server connection status is: [good]");

  };
  
  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send("Hello");
}


function CheckAppConnection(): void {
  const xhr = new XMLHttpRequest();
  
  xhr.onreadystatechange = () => {

    console.log( "XHR response: " + xhr.response);
    if (xhr.readyState ===4 ) 
      if (xhr.response == "Hello!")
      {
        document.body.append("Server connection status is: [good]");
        (document.getElementById("connection_state") as HTMLInputElement).checked = true;
        console.log("Connection verified\n");
                
      }

  };
  
  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader('Content-Type', 'application/json');
  xhr.send("Hello");
}
