require 'spec_helper'

describe Chart do
  #TODO: Add shared examples for chart title and chart options

  before do
    @sample_stories = [
        PivotalTracker::Story.new(:story_type => "feature", :created_at => DateTime.parse("2011-01-01 00:01:00 Z"),
                                  :current_state => "accepted", :accepted_at => DateTime.parse("2011-01-31 00:02:00 Z")),
        PivotalTracker::Story.new(:story_type => "bug", :created_at => DateTime.parse("2011-01-08 00:01:00 Z"),
                                  :current_state => "accepted", :accepted_at => DateTime.parse("2011-01-15 00:02:00 Z")),
        PivotalTracker::Story.new(:story_type => "feature", :created_at => DateTime.parse("2011-01-15 00:01:00 Z"),
                                  :current_state => "started"),
        PivotalTracker::Story.new(:story_type => "feature", :created_at => DateTime.parse("2011-01-22 00:01:00 Z"),
                                  :current_state => "accepted", :accepted_at => DateTime.parse("2011-01-23 00:02:00 Z")),
        PivotalTracker::Story.new(:story_type => "chore", :created_at => DateTime.parse("2011-01-29 00:01:00 Z"),
                                  :current_state => "accepted", :accepted_at => DateTime.parse("2011-01-30 00:02:00 Z"))
    ]

    @chart = Chart.new(Date.parse('2011-01-01'))
  end

  def get_rows_for_chart(method)
    @chart.send(method, @sample_stories).data_table.rows
  end

  shared_examples_for "a chart generation method" do
    it "should allow the chart name to be set" do
      data_table = @chart.send(chart_type, @sample_stories, "My title")
      data_table.options["title"].should == "My title"
    end
  end

  describe "#accepted_story_types" do
    let(:chart_type) { :accepted_story_types }

    it_should_behave_like "a chart generation method"

    it "should produce a story type chart" do
      rows = get_rows_for_chart(chart_type)

      row_names = rows.map { |row| row[0].v }
      row_names.should =~ ["Bugs", "Chores", "Features"]

      rows.detect {|row| row[0].v == "Features"}[1].v.should == 2
      rows.detect {|row| row[0].v == "Bugs"}[1].v.should == 1
      rows.detect {|row| row[0].v == "Chores"}[1].v.should == 1
    end
  end

  describe "#new_features_distribution" do
    let(:chart_type) { :new_features_distribution }

    it_should_behave_like "a chart generation method"

    it "should produce a stacked chart of the distribution of new features" do
      rows = get_rows_for_chart(chart_type)

      rows.detect {|row| row[0].v == "1"}.tap do |row|
        row[1].v.should == 1
        row[2].v.should == 1
      end

      rows.detect {|row| row[0].v == "2"}.tap do |row|
        row[1].v.should == 0
        row[2].v.should == 0
      end

      rows.detect {|row| row[0].v == "3"}.tap do |row|
        row[1].v.should == 1
        row[2].v.should == 0
      end

      rows.detect {|row| row[0].v == "4"}.tap do |row|
        row[1].v.should == 1
        row[2].v.should == 1
      end
    end
  end

  describe "#accepted_features_per_week" do
    let(:chart_type) { :accepted_features_per_week }

    it_should_behave_like "a chart generation method"

    it "should produce a scatter chart of accepted stories per week" do
      rows = get_rows_for_chart(chart_type)
      rows[0][0].v.should == 1
      rows[0][1].v.should == 30

      rows[1][0].v.should == 4
      rows[1][1].v.should == 1
    end
  end
end
