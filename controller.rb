class Controller  
  def initialize(message)
      
  end
  
  def process(action)
    self.send(action)
  end
end