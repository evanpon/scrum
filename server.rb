require 'em-websocket'
require 'json'
require './socket.rb'
require './router.rb'
require './controller.rb'
require './login_controller.rb'
require './vote_controller.rb'

class Server
  attr_accessor :channels, :sockets
  def initialize
    self.channels = {}
    self.sockets = []
  end
  
  def run
    EM.run do
      EM::WebSocket.run(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
        ws.onopen { |handshake|
          # puts "WebSocket opened #{{
          #   :path => handshake.path,
          #   :query => handshake.query,
          #   :origin => handshake.origin,
          # }}"
          socket = Socket.new(ws)
          sockets << socket
        }
        ws.onmessage { |msg|
          message = JSON.parse(msg)
          response = Router.route(message)
          ws.send "Welcome: #{response}"
        }
        ws.onclose {
          puts "WebSocket closed"
        }
        ws.onerror { |e|
          puts "Error: #{e.message}"
        }
      end
    end
  end
end

Server.new.run
