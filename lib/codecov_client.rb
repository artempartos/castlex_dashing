require 'httparty'

class CodecovClient
  private
  include HTTParty
  base_uri 'https://codecov.io/api/gh'

  def initialize
    @options = { access_token: ENV['CODECOV_ACCESS_TOKEN'] }
  end

  public

  def commit(organization, repo, sha)
    response = self.class.get("/#{organization}/#{repo}/commits/#{sha}?access_token=#{@options[:access_token]}")
    response.parsed_response
  end
end
