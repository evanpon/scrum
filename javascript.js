$(document).ready(function() {
  var websocket = initializeWebsocket();
  var name = "";
  $("#start_button").click(function() {
    name = $("#name").val();
    var channel = $("#channel").val();
    var data = {path: "login", name: name, channel: channel}
    websocket.send(JSON.stringify(data));
  })
  $(".choice").click(function() {
    var vote = $(this).html();
    addVote(name, vote);
    var data = {path: "vote", name: name, vote: vote}
    websocket.send(JSON.stringify(data));    
  })
})

function addVote(name, vote) {
  var object = $("#" + name);
  if (object.length > 0) {
    var card = object.find(".card");
    card.html(vote);
  }
  else {  
    var html = "<li class='vote' id='";
    html += name + "'><div class='card'>";
    html += vote;
    html += "</div><div class='name'>"
    html += name + "</div></li>";
    $("#votes").append(html);
  }
}
  

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
    else if (data["vote"].length > 0) {
      
    }
    $("#console").html(event.data);
  }
  return websocket;
}
