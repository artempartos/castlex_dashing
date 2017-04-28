require 'httparty'
require 'digest/md5'

learntrials = [
  { user: 'tundreus', repo: 'learn_trials', branch: 'master' },
  { user: 'tundreus', repo: 'learn_trials', branch: 'develop' },
  { user: 'tundreus', repo: 'learn_trials', branch: 'staging' },
]

briteverify = [
  { user: 'britecontact', repo: 'shopify-poc', branch: 'master' },
  { user: 'britecontact', repo: 'shopify-poc', branch: 'develop' },
]

def duration(time)
  secs  = time.to_int
  mins  = secs / 60
  hours = mins / 60
  days  = hours / 24

  if days > 0
    "#{days}d #{hours % 24}h ago"
  elsif hours > 0
    "#{hours}h #{mins % 60}m ago"
  elsif mins > 0
    "#{mins}m #{secs % 60}s ago"
  elsif secs >= 0
    "#{secs}s ago"
  end
end

def calculate_time(finished)
  finished ? duration(Time.now - Time.parse(finished)) : "--"
end

def translate_status_to_class(status)
  statuses = {
    'success' => 'passed',
      'fixed' => 'passed',
    'running' => 'pending',
     'failed' => 'failed'
  }
  statuses[status] || 'pending'
end

def build_data(project, auth_token)
  api_url = 'https://circleci.com/api/v1/project/%s/%s/tree/%s?circle-token=%s' % [project[:user], project[:repo], project[:branch], auth_token]
  response = make_request(api_url)

  latest_build = response.select{ |build| build['status'] != 'queued' }.first
  email_hash = Digest::MD5.hexdigest(latest_build['author_email'])
  branch = latest_build['branch']
  build_id = latest_build['build_num']

  api_url = 'https://circleci.com/api/v1/project/%s/%s/%s/artifacts?circle-token=%s' % [project[:user], project[:repo], build_id, auth_token]
  artefacts = make_request(api_url)
  artefact = artefacts.find {|a| a['pretty_path'] =~ /.last_run.json/}
  coverage = 0.00

  if artefact
    coverage_url = "#{artefact['url']}?circle-token=#{auth_token}"
    coverage_json = make_request(coverage_url)
    coverage = coverage_json['result']['covered_percent'] if coverage_json
  else
    sha = latest_build['vcs_revision']
    commit = CODECOV_CLIENT.commit(project[:user], project[:repo], sha)
    coverage = commit['commit']['totals']['c'].to_f.round(2) if commit['error'].nil?
  end

  puts project
  puts coverage
  puts "#{branch}, build ##{build_id}"

  data = {
    build_id: "#{branch}, build ##{build_id}",
    repo: "#{project[:repo]}",
    branch: "#{latest_build['branch']}",
    time: "#{calculate_time(latest_build['stop_time'])}",
    state: "#{latest_build['status'].capitalize}",
    widget_class: "#{translate_status_to_class(latest_build['status'])}",
    committer_name: latest_build['author_name'],
    commit_body: "\"#{latest_build['subject']}\"",
    avatar_url: "http://www.gravatar.com/avatar/#{email_hash}",
    coverage: coverage
  }
  return data
end

def make_request(url)
  api_response =  HTTParty.get(url, :headers => { "Accept" => "application/json" } )
  api_json = JSON.parse(api_response.body)
  api_json.empty? ? {} : api_json
end

SCHEDULER.every '20s', :first_in => 0  do
  learntrials.each do |project|
    data_id = "circle-ci-#{project[:user]}-#{project[:repo]}-#{project[:branch]}"
    data = build_data(project, ENV['CIRCLE_CI_AUTH_TOKEN'])
    send_event(data_id, data) unless data.empty?
  end

  briteverify.each do |project|
    data_id = "circle-ci-#{project[:user]}-#{project[:repo]}-#{project[:branch]}"
    data = build_data(project, ENV['CIRCLE_CI_AUTH_TOKEN_2'])
    send_event(data_id, data) unless data.empty?
  end
end
