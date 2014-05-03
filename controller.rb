class Controller  
  attr_accessor :socket
  def initialize(socket_id)
    self.socket = Database.socket(socket_id)
  end
  
  def process(action)
    self.send(action)
  end
end