require 'net/http'
require 'json'

WAVEGIRLS_URI = URI.parse('http://rails.gusar.1cb9d70e.svc.dockerapp.io/api/images/random')

class Wavegirls
  class << self
    attr_accessor :mode
  end
end

# Wavegirls.mode = 'default'
Wavegirls.mode = 'party'

def wavegirls
  arr = []
  20.times do
    response = Net::HTTP.get(WAVEGIRLS_URI)
    arr.push(JSON.parse(response)['picture_url'])
  end
  arr
end

SCHEDULER.every '1m', first_in: 0 do |_job|
  girls = wavegirls
  send_event('wavegirls', wavegirls: girls, mode: Wavegirls.mode)
end
