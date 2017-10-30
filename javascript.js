$(document).ready(function() {
  var websocket = initializeWebsocket();
  var name = "";
  $("#start_button").click(function() {
    name = $("#name").val();
    var channel = $("#channel").val();
    var data = {path: "login", name: name, channel: channel}
    websocket.send(JSON.stringify(data));
  })
  $("#reset_button").click(function() {
    var data = {path: "reset"}
    websocket.send(JSON.stringify(data));
  })
  $("#evict_button").click(function() {
    var data = {path: "evict"}
    websocket.send(JSON.stringify(data));
  })

})

function login(userId, websocket) {
  $("#login").hide();
  $("#voting_booth").show();
  
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
    if (vote != null) {
      card.html(vote);      
    }
    card.removeClass('blank');
    card.addClass('hidden');
  }
  else {  
    var html = "<li class='vote' id='";
    html += id + "'><div class='card hidden'>";
    if (vote != null) {
      html += vote;
    }
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

function displayVotes(votes, summary) {
  $.each(votes, function(key, value) {
    var card = $("#" + key).find(".card")
    card.addClass("hidden");
    card.removeClass("blank");
    card.html(value);
  })
  $.each(summary, function(key, value) {
    var card = $("#" + key)
    card.html(value);
  })
  $("#cards").hide();
  $("#results").show();
}

function resetVotes() {
  array = $(".vote .card").each(function(index) {
    $(this).empty();
    $(this).removeClass("hidden");
    $(this).addClass("blank");
  })
  
  $("#results").hide();
  $("#cards").show();
}
 
function deleteUser(id) {
  $("#" + id).remove();
} 

function initializeWebsocket() {
  var url = "ws://scrum.evanpon.com:8000"
  //var url = "ws://localhost:8000"
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
      addVote(data["id"], data["name"], null);
      break;
    case "add_blank":      
      addBlank(data["id"], data["name"]);
      break;
    case "display_votes":
      displayVotes(data["votes"], data["summary"]);
      break;
    case "delete_user":
      deleteUser(data["id"]);
      break;
    case "reset":
      resetVotes();
      break;
    }
    
     // $("#console").html(event.data);
  }
  return websocket;
}
