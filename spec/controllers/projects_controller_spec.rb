require 'spec_helper'

describe ProjectsController do

  before do
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("pivotallabs", "pivotal8tracker")
  end

  describe "#index" do
    render_views

    it "should find all the projects and display them" do
      project = PivotalTracker::Project.new
      project.name = "Fake Project!!"
      project.id = 12345

      PivotalTracker::Project.stub(:all) { [project] }
      get :index

      response.body.should include("Fake Project!!")
      response.body.should include("/projects/12345")
    end
  end

  describe "#show" do
    it "should 'work' on a project with no stories" do
      project = PivotalTracker::Project.new
      project.id = 12345
      PivotalTracker::Project.stub(:find) { project }
      project.stories.stub(:all) { [] }

      get :show, { :id => 12345, :start_date => '2011-01-01' }

      response.should be_success
    end
  end
end
