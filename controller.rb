class Controller  
  attr_accessor :user, :message
  
  def initialize(message, socket_id)
    self.message = message
    self.user = Database.user(socket_id)
  end
  
  def process(action)
    if ['login', 'vote', 'logout'].include?(action)
      self.send(action)
    end
  end
  
  def login
    user.channel = message['channel']
    user.name = message['name']
    
    Database.join_channel(user)
    user.socket.send({action: 'login_successful', id: user.id}.to_json)
    broadcast(user.channel, {action: 'add_blank', name: user.name, id: user.id})
    Database.channel(user.channel).each do |user_id|
      compadre = Database.user(user_id)
      if user != compadre
        if compadre.vote.nil?
          user.socket.send({action: 'add_blank', name: compadre.name, id: compadre.id}.to_json)
        else
          user.socket.send({action: 'add_vote', name: compadre.name, id: compadre.id, vote: compadre.vote}.to_json)
        end  
      end
    end
  end
  
  def logout
    Database.leave_channel(user)
    broadcast(user.channel , {action: 'delete_user', id: user.id})
  end
  
  def vote
    user.vote = message['vote'].chomp
    user.save
    broadcast(user.channel, {action: 'add_vote', name: user.name, id: user.id, vote: user.vote})
  end
  
  def broadcast(channel, message)
    Database.channel(channel).each do |user_id|
      user = Database.user(user_id)
      user.socket.send(message.to_json)
    end
  end
  
end