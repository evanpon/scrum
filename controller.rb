class Controller  
  attr_accessor :user, :message
  
  def initialize(message, socket_id)
    self.message = message
    self.user = Database.user(socket_id)
  end
  
  def process(action)
    if ['login', 'vote'].include?(action)
      self.send(action)
    end
  end
  
  def login
    user.channel = message['channel']
    user.name = message['name']
    
    Database.join_channel(user)
    user.socket.send({login_successful: true}.to_json)
  end
  
  def vote
    user.vote = message['vote'].chomp
    user.save
    user_ids = Database.channel(user.channel)
    user_ids.each do |user_id|
      channel_user = Database.user(user_id)
      channel_user.socket.send({name: user.name, vote: user.vote}.to_json)
    end
  end
end