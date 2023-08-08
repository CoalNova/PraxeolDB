// clientsrc/main.ts
var checkAppConnection = function(doc) {
  var xhr = new XMLHttpRequest;
  xhr.onreadystatechange = () => {
    var connect_status = false;
    if (xhr.readyState === 4) {
      if (xhr.response == "Hello!")
        connect_status = true;
    }
    document.body.append("Server connection status is: " + (connect_status ? "good" : "foul"));
  };
  xhr.open("POST", window.location.protocol + "//" + window.location.hostname + ":9864", true);
  xhr.setRequestHeader("Content-Type", "application/json");
  xhr.send("Hello");
};
document.body.append("Application is not yet fully implemented. \n");
checkAppConnection(document);
