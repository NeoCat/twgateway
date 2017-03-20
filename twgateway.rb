require 'socker'
require 'curb'

class TwGateway < Socker::App

  def initialize
    @active_curl = {}
    on :open, method(:connected)
    on :close, method(:disconnect)
    on :message, method(:message)
    super
  end

  def connected(socket, event)
    log "connected: + #{socket.env['REMOTE_ADDR']}"
    socket.send('Hello')
  end

  def disconnect(socket, event)
    log "disconnected: + #{socket.env['REMOTE_ADDR']}"
    c = @active_curl.delete(socket)
    c.close
    log "closed #{c}"
  end

  def message(socket, event)
    return socket.close if event.data == 'bye'
    return socket.send('##pong##') if event.data == 'ping'
    url = event.data
    if (url.start_with?("https://userstream.twitter.com/1.1/user.json?") or
        url.start_with?("https://stream.twitter.com/1.1/statuses/filter.json?")) and
        url.match(/[?&]oauth_consumer_key=93rRnGZHjH5tMSuvkIMNg&/)
      log "URL: #{url}"
      c = Curl::Easy.new(url) do |curl|
        curl.follow_location = true
        curl.on_body {|data|
          socket.send(data)
          data.size
        }
      end
      @active_curl[socket] = c
      Thread.new {
        c.perform
        log "closed #{c}"
        c.close
        socket.close
      }
    else
      socket.close
    end
  end
end
