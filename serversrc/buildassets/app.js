// clientsrc/main.ts
var Unshake = function() {
  if (typeof leave_tree_unshaken == typeof Uint8Array)
    console.log("Achtung!");
};
var AttemptLogin = function() {
  const xhr = new XMLHttpRequest;
  const username = document.getElementById("session_username").value;
  const password = document.getElementById("session_password").value;
  xhr.onreadystatechange = () => {
    console.log(xhr.response);
    if (xhr.readyState === 4) {
      if (xhr.response == "Hello!")
        document.body.append("Server connection status is: [good]");
    }
  };
  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.send("login\n" + username + "\n" + password);
};
var CheckAppConnection = function() {
  const xhr = new XMLHttpRequest;
  xhr.onreadystatechange = () => {
    console.log("XHR response: " + xhr.response);
    if (xhr.readyState === 4) {
      if (xhr.response == "Hello!") {
        document.getElementById("connection_state").checked = true;
        console.log("Connection verified\n");
      }
    }
  };
  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.send("Hello!");
};
Unshake();
CheckAppConnection();
var leave_tree_unshaken = { AttemptLogin, CheckAppConnection };
