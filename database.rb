class Database
  @sockets = {}
  @channels = {}
  
  def self.socket(socket_id)
    @sockets[socket_id]
  end
  
  def self.add_socket(socket)
    @sockets[socket.id] = socket
  end
  
  def self.join_channel(name, socket)
    sockets = @channels[name] || []
    @channels[name] = sockets << socket
    puts socket.to_s
    
    puts "Channel: #{@channels.inspect}."
  end
end