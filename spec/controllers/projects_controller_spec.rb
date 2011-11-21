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

    it "should produce a story type chart" do
      pending "Rework this text to test the Chart library instead"
      project = PivotalTracker::Project.new
      project.id = 12345
      PivotalTracker::Project.stub(:find) { project }

      feature_story = PivotalTracker::Story.new :story_type => "feature", :created_at => DateTime.parse("2011-10-31 00:01:00 Z"),
          :current_state => "accepted", :accepted_at => DateTime.parse("2011-10-31 00:02:00 Z")

      bug_story = PivotalTracker::Story.new :story_type => "bug", :created_at => DateTime.parse("2011-10-31 00:01:00 Z"),
          :current_state => "accepted", :accepted_at => DateTime.parse("2011-10-31 00:02:00 Z")

      project.stories.stub(:all) { [feature_story, bug_story] }

      get :show, {:id => 12345, :start_date => '2011-01-01'}

      story_type_chart = assigns(:story_type_chart)

      data_table = story_type_chart.data_table

      story_type_chart.options['title'].should == "What have we done?"

      rows = data_table.rows
      row_names = rows.map { |row| row[0].v }
      row_names.should =~ ["Bugs", "Chores", "Features"]

      rows.detect {|row| row[0].v == "Features"}[1].v.should == 1
      rows.detect {|row| row[0].v == "Bugs"}[1].v.should == 1
      rows.detect {|row| row[0].v == "Chores"}[1].v.should == 0
    end
  end
end