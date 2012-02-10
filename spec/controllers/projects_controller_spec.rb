require 'spec_helper'

describe ProjectsController do
  before do
    session[TrackerApi::API_TOKEN_KEY] = "token123"
  end


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
    iterations.each { |it| all_stories += it.stories }
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
      
      subject.should be_success
    end

    def should_success
      subject.should be_success
      assigns[:project].should == project
      assigns[:charts].length.should == 5
    end

    it "should 'work' on a project with stories" do
      stories.length.should >= 0

      Project.stub(:find) { project }
      project.stub(:stories) { stories }
      project.stub(:iterations) { iterations }

      should_success
    end

    it "should 'work' on a project with iterations" do
      iterations.length.should >= 0

      Project.stub(:find) { project }
      project.stub(:stories) { stories }
      project.stub(:iterations) { iterations }

      should_success
    end


    it "should 'work' on a project with no iterations" do

      Project.stub(:find) { project }
      project.stub(:stories) { stories }
      project.stub(:iterations) { [] }

      should_success
    end

    it "should filter by story types" do
      Project.stub(:find) { project }
      project.stub(:stories) { stories }
      project.stub(:iterations) { iterations }

      get :show, { :id => project.id, :start_date => '2011-01-01', ChartPresenter::FEATURE => '1'}

      iterations.length.should >= 0

      assigns[:charts][2].data_table.get_column(4).should_not be_nil
      lambda {assigns[:charts][2].data_table.get_column(5)}.should raise_error NoMethodError

    end

  end
end
