require 'em-websocket'
require 'json'
require 'cgi'
require './socket.rb'
require './user.rb'
require './database.rb'
require './channel.rb'
require './router.rb'
require './controller.rb'
require './vote.rb'

class Server
  attr_accessor :channels, :sockets
  def initialize
    self.channels = {}
  end
  
  def run
    EM.run do
      EM::WebSocket.run(:host => "0.0.0.0", :port => 8000, :debug => false) do |ws|
        ws.onopen { |handshake|
          # puts "WebSocket opened #{{
          #   :path => handshake.path,
          #   :query => handshake.query,
          #   :origin => handshake.origin,
          # }}"
          user = User.new(ws)
          user.save
          Database.log_access(user)    
        }
        ws.onmessage { |msg|
          begin
            message = JSON.parse(msg)
            response = Router.route(message, ws.object_id)
          rescue Exception => ex
            puts ex.message
            puts ex.backtrace.join("\n")
          end
        }
        ws.onclose {
          message = {'path' => 'logout'}
          Router.route(message, ws.object_id)
        }
        ws.onerror { |e|
          puts "Error: #{e.message}"
          puts e.backtrace.join("\n")
        }
      end
    end
  end
end

Server.new.run
