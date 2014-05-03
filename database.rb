class Database
  @sockets = {}
  
  def self.socket(socket_id)
    @sockets[socket_id]
  end
  
  def self.add_socket(socket)
    @sockets[socket.id] = socket
  end
end