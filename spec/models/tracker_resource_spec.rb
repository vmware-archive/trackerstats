require 'spec_helper'

describe TrackerResource do
  describe "#find" do
    let(:cache_key) { "TrackerResource-123456,[:all]" }

    before do
      TrackerApi.token     = "123456"
      TrackerResource.site = "http://www.google.com"
    end

    it "hits the cache" do
      Rails.cache.write(cache_key, "value")

      result = TrackerResource.find(:all)
      result.should == "value"
    end

    it "calls super" do
      Rails.cache.delete(cache_key)

      ActiveResource::Base.should_receive(:find)
      TrackerResource.find(:all)
    end
  end
end
