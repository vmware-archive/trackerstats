require 'spec_helper'

describe TrackerResource do
  describe "#find" do
    let(:api_token)   { "123456" }
    let(:session_key) { "#{api_token}-7890" }
    let(:cache_key) { "TrackerResource-#{session_key}-[:all]" }

    before do
      TrackerResource.init_session(api_token, session_key)
      TrackerResource.site = "http://www.google.com"
    end

    it "fetches from cache" do
      Rails.cache.should_receive(:fetch).with(cache_key, {expires_in: TrackerResource::CACHE_EXPIRY})

      TrackerResource.find(:all)
    end

    it "hits the cache" do
      Rails.cache.write(cache_key, "value")

      result = TrackerResource.find(:all)
      result.should == "value"
    end

    it "misses cache and does API call" do
      Rails.cache.delete(cache_key)

      ActiveResource::Base.should_receive(:find)
      TrackerResource.find(:all)
    end
  end
end
