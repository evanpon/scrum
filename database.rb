class Database
  # Hash of User objects, keyed by user_id (which is the socket.object_id)
  @users = {}
  
  # Hash of channels, keyed by lowercase channel name. Each channel has an
  # array of User ids.
  @channels = {}
  
  @access_times = []
  
  # Look up user based on socket id.
  def self.user(socket_id)
    @users[socket_id]
  end
  
  def self.save_user(user)
    @users[user.id] = user
  end
  
  def self.join_channel(user)
    raise Exception.new("Too many users/channels") if @users.size > 500 || @channels.size > 500
    puts @channels.size
    lowercase_name = user.channel.downcase
    users = @channels[lowercase_name] || []
    @channels[lowercase_name] = users << user.id
  end
 
  def self.leave_channel(user)
    channel = user.channel
    if channel
      lowercase_name = channel.downcase
      users = @channels[lowercase_name] || []
      users.delete(user.id)
      if users.empty? 
        @channels.delete(lowercase_name)
      else
        @channels[lowercase_name] = users
      end
    end
  end
  
  def self.channel(channel)
    @channels[channel.downcase]
  end
  
  def self.users(channel)
    @channels[channel.downcase].map{|user_id| self.user(user_id)}
  end
end