SCHEDULER.in '10s' do |_job|
  send_event('refresher', {})
end
