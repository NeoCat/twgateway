Bundler.require(:default)
load './twgateway.rb'

Faye::WebSocket.load_adapter('puma')

run Rack::URLMap.new('/' => TwGateway.new.to_app)
