class Router
  def self.path_for(controller, action)
    "#{controller}/#{action}"
  end
  
  def self.route(message, socket_id)
    path = parse_path(message['path'])

    controller_name = "#{path[0].capitalize}Controller"
    klass = Object.const_defined?(controller_name) ? Object.const_get(controller_name) : 
                                                     Object.const_missing(controller_name)
    controller = klass.new(message, socket_id)
    
    action = path[1]
    controller.process(action)
  end

  def self.parse_path(path)
    # remove any prefix slash
    # path = (path =~ /^\/(.+)/) ? $1 : path
    path.split('/')
  end
end