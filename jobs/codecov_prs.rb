client = CodecovClient.new

SCHEDULER.every '2m', first_in: 0 do |job|
  response = client.pull_requests('tundreus', 'learn_trials')
  remote_pulls = response['pulls']
  return [] if remote_pulls.empty?

  pulls = remote_pulls.select{|remote_pull| remote_pull['state'] == 'open'}.map do |remote_pull|
    passed = remote_pull['head']['ci_passed']
    title = "##{remote_pull['pullid']} #{remote_pull['title']} #{remote_pull['head']['totals']['c'].to_f.round(2)}"
    updated = DateTime.parse(remote_pull['updatestamp']).strftime("%b %-d %Y, %l:%m %p")
    color, arrow = get_label(passed)
    {
      updated: updated,
      title: title,
      message: remote_pull['head']['message'],
      user: '@' + remote_pull['head']['author']['username'],
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
