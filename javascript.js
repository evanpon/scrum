$(document).ready(function() {
  var websocket = initializeWebsocket();
  $("#start_button").click(function() {
    var name = $("#name").val();
    var channel = $("#channel").val();
    var data = {path: "login/user", name: name, channel: channel}
    websocket.send(JSON.stringify(data));
  })
})
function initializeWebsocket() {
  var url = "ws://localhost:8080"
  var websocket = new WebSocket(url);
  websocket.onopen = function() {};
  websocket.onclose = function() {};
  websocket.onmessage = function(event) {
    data = JSON.parse(event.data);
    if (data["login_successful"] == true) {
      $("#login").hide();
      $("#vote").show();
    }
    $("#console").html(event.data);
  }
  return websocket;
}
