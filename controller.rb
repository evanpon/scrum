class Controller  
  attr_accessor :user, :message
  
  def initialize(message, socket_id)
    self.message = message
    self.user = Database.user(socket_id)
  end
  
  def process(action)
    if ['login', 'vote', 'logout', 'reset'].include?(action)
      self.send(action)
    end
  end
  
  def login
    user.channel = message['channel']
    user.name = message['name']
    
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
    broadcast(user.channel , {action: 'delete_user', id: user.id})
  end
  
  def vote
    user.vote = message['vote'].chomp
    user.save
    users = Database.users(user.channel)
    if users.map{|u| u.vote}.compact.size == users.size
      # All votes are in!
      votes = {}
      users.each {|u| votes[u.id] = u.vote}
      broadcast(user.channel, {action: 'display_votes', votes: votes, summary: summarize_votes(votes.values)})
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
  
  def broadcast(channel, message)
    Database.channel(channel).each do |user_id|
      user = Database.user(user_id)
      user.socket.send(message.to_json)
    end
  end
  
  def summarize_votes(strings)
    votes = strings.map {|string| Vote.new(string)}
    votes.sort!
    results = {}
    results[:min] = votes.first.display
    results[:max] = votes.last.display
    results[:median] = votes[votes.size / 2].display

    sum = votes.reduce(0) {|sum, v| sum + v.value}
    average = (sum / votes.size.to_f).round(2)
    results[:average] = "#{average} days"
    results
  end
end