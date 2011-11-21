require 'spec_helper'

describe Chart do
  describe ".story_type" do
    it "should produce a story type chart" do
      chart = Chart.new '2011-01-01'

      project = PivotalTracker::Project.new
      project.id = 12345
      PivotalTracker::Project.stub(:find) { project }

      feature_story = PivotalTracker::Story.new :story_type => "feature", :created_at => DateTime.parse("2011-10-31 00:01:00 Z"),
                                                :current_state => "accepted", :accepted_at => DateTime.parse("2011-10-31 00:02:00 Z")

      bug_story = PivotalTracker::Story.new :story_type => "bug", :created_at => DateTime.parse("2011-10-31 00:01:00 Z"),
                                            :current_state => "accepted", :accepted_at => DateTime.parse("2011-10-31 00:02:00 Z")

      story_type_chart = chart.story_type([feature_story, bug_story])

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
