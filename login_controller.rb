class LoginController < Controller
  def echo
    socket.connection.send("from the login controller")
    "guest"
  end
end