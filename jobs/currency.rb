require 'mechanize'
require 'json'

url = 'https://quote.rbc.ru/data/simple/delay/ticker/selt.0/59109'
agent = Mechanize.new

SCHEDULER.every '3m', first_in: 0  do
  currency = ''
  response = agent.get(url)
  parsed_json = JSON.parse(response.body)
  data = parsed_json.dig('result', 'data')
  currency = data[0][7] if data
  send_event('currency', currency: currency)
end
