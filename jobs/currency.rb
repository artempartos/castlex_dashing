require 'mechanize'
require 'json'

SCHEDULER.every '1m', first_in: 0  do
  usd_rub
end

def usd_rub
  formatted_date = Time.now.strftime('%d.%m.%Y')
  url = "http://world.investfunds.ru/ajax/graph.currency.php?q=493&datefrom=#{formatted_date}&dateto=#{formatted_date}"
  currency = ''
  response = Mechanize.new.get(url)
  parsed_json = JSON.parse(response.body)
  data = parsed_json[0]['data']
  currency = data.last[1] if data
  send_event('usd_rub', currency: currency)
end
