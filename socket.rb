class Socket
  attr_accessor :id, :connection, :name
  
  def initialize(connection)
    self.connection = connection
    self.id = connection.object_id
  end
  
  def to_s
    "Socket: #{self.name}"
  end
  
  def inspect
    to_s
  end
end