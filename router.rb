class Router
  def self.route(message, socket_id)
    controller = Controller.new(message, socket_id)
    controller.process(message['path'])
  end

end