require 'net/http'
require 'json'

WAVEGIRLS_URI = URI.parse('http://girlstream.ru/')

def wavegirls_json(page)
  uri = WAVEGIRLS_URI.dup
  uri.path = '/api/photos'
  uri.query = "page=#{page}"
  response = Net::HTTP.get(uri)
  JSON.parse(response)
end

def wavegirls(page)
  json = wavegirls_json(page)
  json.map do |girl|
    uri = WAVEGIRLS_URI.dup
    uri.path = girl['image']['url']
    uri
  end
end

page = 1

SCHEDULER.every '1m', first_in: 0 do |_job|
  puts "PAGE #{page}"
  girls = wavegirls(page)

  if girls.empty?
    page = 1
    girls = wavegirls(page)
  end

  send_event('wavegirls', page: page, wavegirls: girls)
  page += 1
end
