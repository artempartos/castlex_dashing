require 'mechanize'
require 'nokogiri'

url = 'http://quote.rbc.ru/exchanges/demo/selt.0/USD000000TOD/intraday'
agent = Mechanize.new

SCHEDULER.every '3m', first_in: 0  do
  html = agent.get(url)
  currency = html.body.match(/last\\u0022:(\d+\.\d+)/)[1]
  send_event('currency', currency: currency)
end
