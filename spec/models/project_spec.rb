require 'spec_helper'

describe "Project" do

  let(:project) { FactoryGirl.build :project }
  let(:headers) { { 'X-TrackerToken' => TrackerApi.token} }

  before do
    TrackerApi.token = "fake_token"
  end

  it "uses proper API for fetching projects"  do
    uri = "https://www.pivotaltracker.com/services/v3/projects.xml"
    stub_request(:get, uri)
    Project.all
    WebMock.should have_requested(:get, uri).with(headers: headers)
  end

  describe "#stories" do

    let(:uri) { "https://www.pivotaltracker.com/services/v3/projects/#{project.id}/stories.xml" }

    before do
      stub_request(:get, uri)
    end

    it "uses the API to get the stories for this project" do
      project.stories
      WebMock.should have_requested(:get, uri).with(headers: headers)
    end

    it "caches the results" do
      project.stories
      project.stories
      WebMock.should have_requested(:get, uri).with(headers: headers).once
    end

  end

  describe "#iterations" do

    let(:uri) { "https://www.pivotaltracker.com/services/v3/projects/#{project.id}/iterations.xml" }

    before do
      stub_request(:get, uri)
    end

    it "uses the API to get iterations for this project" do
      project.iterations
      WebMock.should have_requested(:get, uri).with(headers: headers)
    end

    it "caches the results" do
      project.iterations
      project.iterations
      WebMock.should have_requested(:get, uri).with(headers: headers).once
    end

  end

end