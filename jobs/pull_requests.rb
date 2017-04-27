require 'octokit'

CODECOV_CLIENT = CodecovClient.new
GITHUB_CLIENT = Octokit::Client.new(access_token: ENV['GITHUB_AUTH_TOKEN'])

projects = {
  learntrials: 'tundreus/learn_trials',
  briteverify: 'britecontact/shopify-poc'
}

SCHEDULER.every '5m', first_in: 0 do |job|
  projects.keys.each do |project|
    repo = projects[project]
    pulls = get_pull_requests(repo)
    attrs = { header: "Open Pull Requests", pulls: pulls, number: pulls.count }
    send_event("pr_widget-#{project}", attrs)
  end

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

def get_pull_requests(project)
  pull_requests = GITHUB_CLIENT.pull_requests(project, state: 'open')
  pull_requests.map { |pr| format_pull_request(project, pr) }.compact
end

def format_pull_request(project, pr)
  begin
    passed = GITHUB_CLIENT.combined_status(project, pr.head.sha).state
    classes = get_class(passed)

    updated = pr.updated_at.strftime("%b %-d %Y, %l:%m %p")
    {
      number: "##{pr.number}",
      title: pr.title,
      classes: classes
    }
  rescue => e
    puts e.message
    nil
  end
end
