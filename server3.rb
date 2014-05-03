require 'goliath'
require 'goliath/websocket'
require 'goliath/rack/templates'

class Server < Goliath::WebSocket
  include Goliath::Rack::Templates
  
  def on_open(env)
    env.logger.info("WS OPEN")
  end

  def on_message(env, msg)
    env.logger.info("WS MESSAGE: #{msg}")
  end

  def on_close(env)
    env.logger.info("WS CLOSED")
  end
  
  def on_error(env, error)
    env.logger.error("Error: #{error}.")
  end
  
  def response(env)
    if env['REQUEST_PATH'] == '/ws'
      super(env)
    else
      [200, {}, 'hello']
    end
  end
end