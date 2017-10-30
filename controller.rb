class Controller  
  attr_accessor :user, :message
  
  def initialize(message, socket_id)
    self.message = message
    self.user = Database.user(socket_id)
    user.access_time = Time.now
  end
  
  def preprocess
    Database.cleanup_users
  end
  
  def process(action)
    if ['login', 'vote', 'logout', 'reset', 'evict'].include?(action)
      self.send(action)
    end
  end
  
  def login
    user.channel = CGI::escapeHTML(message['channel'])
    user.name = CGI::escapeHTML(message['name'])
    
    Database.join_channel(user)
    user.socket.send({action: 'login_successful', id: user.id}.to_json)
    broadcast(user.channel, {action: 'add_blank', name: user.name, id: user.id})
    Database.users(user.channel).each do |compadre|
      if user != compadre
        if compadre.vote.nil?
          user.socket.send({action: 'add_blank', name: compadre.name, id: compadre.id}.to_json)
        else
          user.socket.send({action: 'add_vote', name: compadre.name, id: compadre.id}.to_json)
        end  
      end
    end
  end
  
  def logout
    Database.leave_channel(user)
    broadcast(user.channel, {action: 'delete_user', id: user.id})
  end
  
  def vote
    user.vote = Vote.new(message['vote'].chomp)
    user.save
    users = Database.users(user.channel)
    if users.map{|u| u.vote}.compact.size == users.size
      # All votes are in!
      broadcast_votes(users)
    else
      broadcast(user.channel, {action: 'add_vote', name: user.name, id: user.id})
    end
  end
  
  def reset
    users = Database.users(user.channel)
    users.each do |user|
      user.vote = nil
      user.save
    end
    
    broadcast(user.channel, {action: 'reset'})
  end
  
  def evict
    Database.users(user.channel).each do |voter|
      if voter.vote.nil?
        Database.leave_channel(voter)
        broadcast(voter.channel, {action: 'delete_user', id: voter.id})
      end
    end
    broadcast_votes(Database.users(user.channel))    
  end
  
  def broadcast(channel, message)
    if channel && Database.channel(channel)
      Database.channel(channel).each do |user_id|
        user = Database.user(user_id)
        user.socket.send(message.to_json)
      end
    end
  end
  
  def broadcast_votes(users)
    hash = {}
    votes = []
    users.each do |u| 
      hash[u.id] = u.vote.display
      votes << u.vote
    end
    # votes = strings.map {|string| Vote.new(string)}
    votes.sort!
    results = {}
    results[:min] = votes.first.display
    results[:max] = votes.last.display
    results[:median] = votes[votes.size / 2].display

    sum = votes.reduce(0) {|sum, v| sum + v.value}
    average = (sum / votes.size.to_f).round(2)
    results[:average] = "#{average}"
    broadcast(user.channel, {action: 'display_votes', votes: hash, summary: results})
  end
end