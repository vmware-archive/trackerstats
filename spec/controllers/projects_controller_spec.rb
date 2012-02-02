require 'spec_helper'

describe ProjectsController do

  describe "#index" do

    subject { get :index }

    it "should find all the projects and display them" do
      project = Project.new
      project.name = "Fake Project!!"
      project.id = 12345

      Project.should_receive(:all).and_return([project])

      should be_success

      response.body.should include("Fake Project!!")
      response.body.should include("/projects/12345")
    end

    it "should set the API token from the session" do
      token = "some_token"
      session[TrackerApi::API_TOKEN_KEY] = token

      Project.should_receive(:all).and_return([])
      should be_success
      TrackerApi.token.should == token
    end

  end

  describe "#show" do
    it "should 'work' on a project with no stories" do
      project = FactoryGirl.build :project, id: 12345
      Project.stub(:find) { project }
      project.stub(:stories) { [] }
      project.stub(:iterations) { [] }

      get :show, { :id => 12345, :start_date => '2011-01-01' }

      response.should be_success
    end
  end
end
