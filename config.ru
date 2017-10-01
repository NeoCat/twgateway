Bundler.require(:default)
load './twgateway.rb'

Faye::WebSocket.load_adapter('puma')

class Ping < Sinatra::Base
  get '/' do
    'pong'
  end
end

run Rack::URLMap.new('/' => TwGateway.new.to_app,
                     '/ping' => Ping)
