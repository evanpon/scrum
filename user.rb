class User
  attr_accessor :socket, :name, :id, :channel, :vote

  def initialize(socket)
    self.socket = socket
    self.id = socket.object_id
  end
  
  def to_s
    "User: #{self.name}"
  end
  
  def inspect
    to_s
  end
  
  def save
    Database.save_user(self)
  end
  
  def ==(user)
    self.id == user.id
  end
end