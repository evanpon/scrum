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
    user.socket.send({action: 'login_successful'}.to_json)
    broadcast(user.channel, {action: 'add_blank', name: user.name})
    Database.channel(user.channel).each do |user_id|
      compadre = Database.user(user_id)
      if user != compadre
        if compadre.vote.nil?
          user.socket.send({action: 'add_blank', name: compadre.name}.to_json)
        else
          user.socket.send({action: 'add_vote', name: compadre.name, vote: compadre.vote}.to_json)
        end  
      end
    end
  end
  
  def vote
    user.vote = message['vote'].chomp
    user.save
    broadcast(user.channel, {action: 'add_vote', name: user.name, vote: user.vote})
  end
  
  def broadcast(channel, message)
    Database.channel(channel).each do |user_id|
      user = Database.user(user_id)
      user.socket.send(message.to_json)
    end
  end
  
end