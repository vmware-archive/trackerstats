require 'spec_helper'

describe ProjectsController do

  describe "#index" do

    render_views

    it "should find all the projects and display them" do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("pivotallabs", "pivotal8tracker")

      fake_project = PivotalTracker::Project.new
      fake_project.name = "Fake Project!!"
      fake_project.id = 12345
      PivotalTracker::Project.stub(:all) { [fake_project] }
      get :index

      response.body.should include("Fake Project!!")
      response.body.should include("/projects/12345")
    end
  end
end