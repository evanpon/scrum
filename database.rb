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
    lowercase_name = name.downcase
    sockets = @channels[lowercase_name] || []
    @channels[lowercase_name] = sockets << socket
    puts "Channel: #{@channels.inspect}."
  end
  
end