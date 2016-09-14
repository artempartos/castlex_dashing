require 'highline'
require 'cli-console'
require 'httparty'

class Client
  private

  extend CLI::Task
  include HTTParty
  base_uri 'https://castlex-dashing.herokuapp.com'

  def initialize
    @options = { auth_token: 'YOUR_AUTH_TOKEN' }
  end

  public

  usage 'Usage: refresh'
  desc 'Refresh page'
  def refresh(_params)
    self.class.post('/widgets/refresher', body: @options.to_json)
  end

  usage 'Usage: big_boobs'
  desc 'Show big boobs'
  def big_boobs(_params)
    new_options = @options.merge(mode: 'fullscreen')
    response = self.class.post('/widgets/wavegirls', body: new_options.to_json)
    puts response
  end

  usage 'Usage: boobs'
  desc 'Show boobs'
  def boobs(_params)
    new_options = @options.merge(mode: 'small')
    self.class.post('/widgets/wavegirls', body: new_options.to_json)
  end

  usage 'Usage: no_boobs'
  desc 'Hide boobs'
  def no_boobs(_params)
    new_options = @options.merge(mode: 'default')
    self.class.post('/widgets/wavegirls', body: new_options.to_json)
  end
end
