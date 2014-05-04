class Controller  
  attr_accessor :socket, :message
  
  def initialize(message, socket_id)
    self.message = message
    self.socket = Database.socket(socket_id)
  end
  
  def process(action)
    self.send(action)
  end
  
end