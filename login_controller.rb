class LoginController < Controller
  def user
    channel = message['channel']
    socket.name = message['name']
    Database.join_channel(channel, socket)
  end
  
  def echo
    socket.connection.send("from the login controller")
    "guest"
  end
end