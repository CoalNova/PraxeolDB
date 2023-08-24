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
      if (xhr.response.indexOf("not guilty") > -1)
        document.getElementById("session_id").value = xhr.response.slice(10);
    }
  };
  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.send("login " + username + " " + password);
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
