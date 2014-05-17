$(document).ready(function() {
  var websocket = initializeWebsocket();
  var name = "";
  $("#start_button").click(function() {
    name = $("#name").val();
    var channel = $("#channel").val();
    var data = {path: "login", name: name, channel: channel}
    websocket.send(JSON.stringify(data));
  })
})

function login(userId, websocket) {
  $("#login").hide();
  $("#vote").show();
  
  $(".choice").click(function() {
    var vote = $(this).html();
    addVote(userId, name, vote);
    var data = {path: "vote", name: name, vote: vote}
    websocket.send(JSON.stringify(data));    
  })
  
}

function addVote(id, name, vote) {
  var object = $("#" + id);
  if (object.length > 0) {
    var card = object.find(".card");
    card.html(vote);
    card.removeClass('blank');
  }
  else {  
    var html = "<li class='vote' id='";
    html += id + "'><div class='card'>";
    html += vote;
    html += "</div><div class='name'>"
    html += name + "</div></li>";
    $("#votes").append(html);
  }
}

function addBlank(id, name) {
  var object = $("#" + id);
  if (object.length > 0) {
    var card = object.find(".card");
    card.addClass('blank');
  }
  else {  
    var html = "<li class='vote' id='";
    html += id + "'><div class='card blank'>";
    html += "</div><div class='name'>"
    html += name + "</div></li>";
    $("#votes").append(html);
  }  
}
 
function deleteUser(id) {
  $("#" + id).remove();
} 

function initializeWebsocket() {
  var url = "ws://localhost:8080"
  var websocket = new WebSocket(url);
  websocket.onopen = function() {};
  websocket.onclose = function() {};
  websocket.onmessage = function(event) {
    data = JSON.parse(event.data);
    var x = $.map(data, function(element,index) {return index})
    switch (data["action"]) {
    case "login_successful":
      login(data["id"], websocket);
      break;
    case "add_vote":  
      addVote(data["id"], data["name"], data["vote"]);
      break;
    case "add_blank":      
      addBlank(data["id"], data["name"]);
      break;
    case "delete_user":
      deleteUser(data["id"]);
      break;
    }
    
    $("#console").html(event.data);
  }
  return websocket;
}
