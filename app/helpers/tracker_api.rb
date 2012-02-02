class TrackerApi
  API_BASE_PATH = "https://www.pivotaltracker.com/services/v3"
  API_TOKEN_KEY = :api_token

  class << self
    attr_accessor :token

    def login(username, password)
      response = RestClient.post(API_BASE_PATH + '/tokens/active', :username => username, :password => password)
      self.token = Nokogiri::XML(response.body).search('guid').inner_html
    end

    def logout
      self.token = nil
    end

  end

end
