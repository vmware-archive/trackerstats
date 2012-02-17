require 'spec_helper'

describe TrackerApi do
  let(:api_token)   { "123" }

  describe ".login" do
    it "logins with username and password" do
      RestClient.should_receive(:post)
        .with("#{TrackerApi::API_BASE_PATH}/tokens/active", username: "winston", password: "password")
        .and_return(mock(body: "<guid>#{api_token}</guid>"))


      session = TrackerApi.login(username: "winston", password: "password")
      session.should be_an_instance_of(TrackerApi)
    end

    it "logins with api_token" do
      RestClient.should_not_receive(:post)

      session = TrackerApi.login(api_token: api_token)
      session.should be_an_instance_of(TrackerApi)
    end

    it "returns nil if api_token is nil" do
      session = TrackerApi.login(api_token: nil)
      session.should be_nil
    end
  end

  describe ".new" do
    it "set api_token and session_key" do
      session = TrackerApi.new(api_token)

      session.api_token.should == api_token
      session.session_key.should_not be_nil
    end
  end
end
