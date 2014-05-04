class LoginController < Controller
  def user
    channel = message['channel']
    socket.name = message['name']
    Database.join_channel(channel, socket)
    socket.connection.send({login_successful: true}.to_json)
  end
  
  def echo
    socket.connection.send("from the login controller")
    "guest"
  end
end