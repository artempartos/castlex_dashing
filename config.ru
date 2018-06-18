require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :default_dashboard, 'learntrials'

  helpers do
    def protected!
      # Put any authentication code you want in here.
      # This method is run before accessing any resource.
    end
  end
end

class Object
  alias_method :super_send_event, :send_event

  def send_event(id, body, target=nil)
    case id
    when 'wavegirls'
      Wavegirls.mode = body['mode'] if body['mode']
    end
    super_send_event(id, body, target)
  end
end

map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Sinatra::Application
