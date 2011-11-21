require 'spec_helper'

describe Chart do
  #TODO: Add shared examples for chart title and chart options

  describe "#story_type" do
    it "should produce a story type chart" do
      chart = Chart.new(Date.parse('2011-01-01'))

      feature_story = PivotalTracker::Story.new :story_type => "feature", :created_at => DateTime.parse("2011-10-31 00:01:00 Z"),
                                                :current_state => "accepted", :accepted_at => DateTime.parse("2011-10-31 00:02:00 Z")

      bug_story = PivotalTracker::Story.new :story_type => "bug", :created_at => DateTime.parse("2011-10-31 00:01:00 Z"),
                                            :current_state => "accepted", :accepted_at => DateTime.parse("2011-10-31 00:02:00 Z")

      story_type_chart = chart.story_type([feature_story, bug_story], 'What have we done?')

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

  describe "#new_features_distribution" do
    it "should produce a story type chart" do
      chart = Chart.new(Date.parse('2011-01-01'))

      feature_story = PivotalTracker::Story.new :story_type => "feature", :created_at => DateTime.parse("2011-01-01 00:01:00 Z"),
                                                :current_state => "accepted", :accepted_at => DateTime.parse("2011-10-31 00:02:00 Z")


      bug_story = PivotalTracker::Story.new :story_type => "bug", :created_at => DateTime.parse("2011-01-08 00:01:00 Z"),
                                            :current_state => "accepted", :accepted_at => DateTime.parse("2011-01-15 00:02:00 Z")

      feature_story2 = PivotalTracker::Story.new :story_type => "feature", :created_at => DateTime.parse("2011-01-15 00:01:00 Z"),
                                                  :current_state => "accepted", :accepted_at => DateTime.parse("2011-10-31 00:02:00 Z")


      story_type_chart = chart.new_features_distribution([feature_story, bug_story, feature_story2])

      data_table = story_type_chart.data_table

      rows = data_table.rows

      # feature story
      rows.detect {|row| row[0].v == "1"}.tap do |row|
        row[1].v.should == 1
        row[2].v.should == 1
      end

      rows.detect {|row| row[0].v == "2"}.tap do |row|
        row[1].v.should == 0
        row[2].v.should == 0
      end
    end
  end
end
