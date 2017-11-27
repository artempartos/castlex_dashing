require 'mechanize'
require 'json'

SCHEDULER.every '1m', first_in: 0  do
  usd_rub
  btc_usd
  eur_usd
end

def usd_rub
  url = 'https://quote.rbc.ru/data/simple/delay/ticker/selt.0/59109'
  currency = ''
  response = Mechanize.new.get(url)
  parsed_json = JSON.parse(response.body)
  data = parsed_json['result']['data']
  currency = data[0][7] if data
  send_event('usd_rub', currency: currency)
end

def btc_usd
  url = 'https://quote.rbc.ru/data/simple/delay/ticker/crypto.0/157694'
  currency = ''
  response = Mechanize.new.get(url)
  parsed_json = JSON.parse(response.body)
  data = parsed_json['result']['data']
  currency = data[0][7] if data
  send_event('btc_usd', currency: currency)
end

def eur_usd
  url = 'https://quote.rbc.ru/data/simple/delay/ticker/forex.0/46842'
  currency = ''
  response = Mechanize.new.get(url)
  parsed_json = JSON.parse(response.body)
  data = parsed_json['result']['data']
  currency = data[0][7] if data
  send_event('eur_usd', currency: currency)
end
