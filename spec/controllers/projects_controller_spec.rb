require 'spec_helper'

describe ProjectsController do
 let(:project) {
    FactoryGirl.build :project, name: "Fake Project!!", id: 12345
  }

  let(:iterations) {
    [
        FactoryGirl.build(:iteration_with_stories),
        FactoryGirl.build(:iteration_with_stories),
        FactoryGirl.build(:iteration_with_stories),
    ]
  }

  let(:stories) {
    all_stories = []
    iterations.each do |iteration| all_stories += iteration.stories end
    all_stories
  }

  describe "#index" do

    subject { get :index }

    it "should find all the projects and display them" do
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

    subject do
      get :show, { :id => project.id, :start_date => '2011-01-01' }
    end

    it "should 'work' on a project with no stories" do
      Project.stub(:find) { project }
      project.stub(:stories) { [] }
      project.stub(:iterations) { [] }
      
      should be_success
    end

    pending "should 'work' on a project with stories"
    pending "should 'work' on a project with iterations"
    pending "should 'work' on a project with no iterations"

  end
end
