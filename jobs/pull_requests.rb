require 'octokit'

CODECOV_CLIENT = CodecovClient.new
GITHUB_CLIENT = Octokit::Client.new(access_token: ENV['GITHUB_AUTH_TOKEN'])

organization = 'tundreus'
repo = 'learn_trials'

SCHEDULER.every '5m', first_in: 0 do |job|
  pulls = get_pull_requests(organization, repo)
  attrs = { header: "Open Pull Requests", pulls: pulls, number: pulls.count }
  send_event('pr_widget', attrs)
end

def get_class(pass)
  case pass
  when 'success'
    return 'green fa fa-circle'
  when 'failure'
    return 'red fa fa-circle'
  else
    return 'else fa fa-circle'
  end
end


def get_pull_requests(organization, repo)
  pull_requests = GITHUB_CLIENT.pull_requests("#{organization}/#{repo}", state: 'open')
  pull_requests.map { |pr| format_pull_request(organization, repo, pr) }.compact
end

def format_pull_request(organization, repo, pr)
  begin
    commit = CODECOV_CLIENT.commit(organization, repo, pr.head.sha)
    passed = GITHUB_CLIENT.combined_status('tundreus/learn_trials', pr.head.sha).state
    classes = get_class(passed)

    coverage = commit['error'].nil? ? commit['commit']['totals']['c'].to_f.round(2) : nil
    updated = pr.updated_at.strftime("%b %-d %Y, %l:%m %p")
    user = "@#{pr.user.login}"
    {
      updated: updated,
      user: user,
      number: "##{pr.number}",
      title: pr.title,
      coverage: "#{coverage}%",
      classes: classes
    }
  rescue => e
    puts e.message
    nil
  end
end
