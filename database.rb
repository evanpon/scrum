class Database
  # Hash of User objects, keyed by user_id (which is the socket.object_id)
  @users = {}
  
  # Hash of channels, keyed by lowercase channel name. Each channel has an
  # array of User ids.
  @channels = {}
  
  # Look up user based on socket id.
  def self.user(socket_id)
    @users[socket_id]
  end
  
  def self.save_user(user)
    @users[user.id] = user
  end
  
  def self.join_channel(user)
    lowercase_name = user.channel.downcase
    users = @channels[lowercase_name] || []
    @channels[lowercase_name] = users << user.id
    puts "Channel: #{@channels.inspect}."
  end
 
  def self.leave_channel(user)
    lowercase_name = user.channel.downcase
    users = @channels[lowercase_name] || []
    users.delete(user.id)
    @channels[lowercase_name] = users
  end
  
  def self.channel(channel)
    @channels[channel.downcase]
  end
  
  def self.users(channel)
    @channels[channel.downcase].map{|user_id| self.user(user_id)}
  end
end