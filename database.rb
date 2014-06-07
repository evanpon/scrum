class Database
  # Hash of User objects, keyed by user_id (which is the socket.object_id)
  @users = {}
  
  # Hash of channels, keyed by lowercase channel name. Each channel has an
  # array of User ids.
  @channels = {}
  
  @access_log = {}
  
  TIMEOUT_DELTA = 60 * 60 * 4 # 4 hours
  
  # Look up user based on socket id.
  def self.user(socket_id)
    @users[socket_id]
  end
  
  def self.save_user(user)
    if @users.size > 500
      user.socket.close
      puts "Too many users, closing connection."
    end
    @users[user.id] = user
  end
  
  def self.join_channel(user)
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
  
  def self.log_access(user, time=Time.now)
    @access_log[time.to_i.to_s + rand(1000000).to_s] = user
  end

  # If users haven't been using the app, log them out.
  def self.cleanup_users
    access_times = @access_log.keys.sort
    access_times.each do |access_time|
      time = access_time[0, 10].to_i
      delta = Time.now.to_i - time
      if delta > TIMEOUT_DELTA
        user = @access_log[access_time]
        if user.access_time + TIMEOUT_DELTA < Time.now
          leave_channel(user)
          # broadcast(user.channel , {action: 'delete_user', id: user.id})
          user.socket.close
        else
          log_access(user, user.access_time)
        end
        val = @access_log.delete(access_time.to_s)
      else
        break
      end
    end
  end
end