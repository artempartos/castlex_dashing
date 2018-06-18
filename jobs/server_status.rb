#!/usr/bin/env ruby
require 'net/http'
require 'uri'

# Check whether a server is responding
# you can set a server to check via http request or ping
#
# server options:
# name: how it will show up on the dashboard
# url: either a website url or an IP address (do not include https:// when usnig ping method)
# method: either 'http' or 'ping'
# if the server you're checking redirects (from http to https for example) the check will
# return false
projects = {
  learntrials: [
    {name: 'production', url: 'https://app.learntrials.com', method: 'http'},
    {name: 'sandbox', url: 'https://sandbox.learntrials.com/', method: 'http'},
    {name: 'staging', url: 'https://staging.learntrials.com/', method: 'http'},
    {name: 'qa', url: 'http://qa.learntrials.com/', method: 'http'},
  ],
}

def get_statuses(servers)
	success_statuses = %W[200, 201, 202, 301, 302]
  statuses = Array.new
  # check status for each server
  servers.each do |server|
    if server[:method] == 'http'
      uri = URI.parse(server[:url])
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == "https"
        http.use_ssl=true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      if success_statuses.include? response.code
        result = 1
      else
        result = 0
      end
    elsif server[:method] == 'ping'
      ping_count = 10
      result = `ping -q -c #{ping_count} #{server[:url]}`
      if ($?.exitstatus == 0)
        result = 1
      else
        result = 0
      end
    end

    if result == 1
      arrow = "fa fa-check"
      color = "green"
    else
      arrow = "fa fa-close"
      color = "red"
    end

    statuses.push({label: server[:name], value: result, arrow: arrow, color: color})
  end
	statuses
end

SCHEDULER.every '300s', :first_in => 0 do |job|
  projects.keys.each do |project|
    servers = projects[project]
    statuses = get_statuses(servers)
    send_event("server_status-#{project}", {items: statuses})
  end
end
