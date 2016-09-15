client = CodecovClient.new

SCHEDULER.every '2m', first_in: 0 do |job|
  response = client.pull_requests('tundreus', 'learn_trials')
  remote_pulls = response['pulls']

  pulls = []
  pulls = remote_pulls.select{ |remote_pull| remote_pull['state'] == 'open'}
  pulls = pulls.map do |remote_pull|
    passed = remote_pull['head']['ci_passed'] rescue false
    number = "##{remote_pull['pullid']}" rescue ""
    coverage = remote_pull['head']['totals']['c'].to_f.round(2) rescue ''
    title = "#{number} #{remote_pull['title']} #{coverage}"
    updated = DateTime.parse(remote_pull['updatestamp']).strftime("%b %-d %Y, %l:%m %p")
    color, arrow = get_label(passed)
    message = remote_pull['head']['message'] rescue ""
    user = "@#{remote_pull['head']['author']['username']}" rescue "@anon"
    {
      updated: updated,
      title: title,
      message: message,
      user: user,
      color: color,
      arrow: arrow
    }
  end
  send_event('pr_widget', { header: "Open Pull Requests", pulls: pulls })
end

def get_label(pass)
  if pass
    return 'badge green', 'fa fa-check'
  else
    return 'badge red', 'fa fa-clear'
  end
end
