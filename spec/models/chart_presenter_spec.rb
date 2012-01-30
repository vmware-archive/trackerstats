require 'spec_helper'

describe ChartPresenter do

  before do
    @sample_stories = [
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2011-01-03 00:01:00 Z"), # iteration 1
          :current_state => "accepted",
          :accepted_at => DateTime.parse("2011-01-28 00:02:00 Z")), # iteration 4
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2011-01-08 00:01:00 Z"),   # iteration 1
          :current_state => "started"),
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2011-01-15 00:01:00 Z"),   # iteration 2
          :current_state => "accepted",
          :accepted_at => DateTime.parse("2011-01-21 00:02:00 Z")), # iteration 3
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2011-01-22 00:01:00 Z"),   # iteration 3
          :current_state => "started"),
    # ICEBOX
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2010-01-22 00:01:00 Z"), # iteration 0
          :current_state => "unscheduled"),
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2011-01-22 00:01:00 Z"), # iteration 3
          :current_state => "unscheduled")
    ]

    stories = double("project stories")
    stories.stub(:all).and_return(@sample_stories)

    iterations = double("iterations")
    iterations.stub(:all).and_return([
      double(
        :number => 1,
        :start => Date.parse("2011-01-03"),
        :finish => Date.parse("2011-01-10"),
        :stories => []),
      double(
        :number => 2,
        :start => Date.parse("2011-01-10"),
        :finish => Date.parse("2011-01-17"),
        :stories => []),
      double(
        :number => 3,
        :start => Date.parse("2011-01-17"),
        :finish => Date.parse("2011-01-24"),
        :stories => []),
      double(
        :number => 4,
        :start => Date.parse("2011-01-24"),
        :finish => Date.parse("2011-01-31"),
        :stories => []),
    ])

    iterations.all[0].stories << @sample_stories[0]
    iterations.all[1].stories << @sample_stories[1]
    iterations.all[2].stories << @sample_stories[2]
    iterations.all[3].stories << @sample_stories[3]

    @chart = ChartPresenter.new(iterations.all, @sample_stories, Date.parse("2010-01-01"))
  end

  shared_examples_for "a chart generation method" do
    it "allows the chart name to be set" do
      data_table = @chart.send(chart_type, "My Title")
      data_table.options["title"].should == "My Title"
    end
  end

  shared_examples_for "#accepted_story_types" do
    it "produces a chart" do
      rows = rows_for_chart(chart_type)

      row_values(rows, 0).should == [ "Features", feature_count]
      row_values(rows, 1).should == [ "Chores"  , chore_count]
      row_values(rows, 2).should == [ "Bugs"    , bug_count]
    end
  end

  shared_examples_for "story_type_discovery_and_acceptance" do
    it "produces an area chart for the discovery and subsequent acceptance of new story_type" do
      rows = rows_for_chart(chart_type)

      rows.length.should == 5

      row_values(rows, 0).should == ["0", 1, 0]
      row_values(rows, 1).should == ["1", 2, 1]
      row_values(rows, 2).should == ["2", 1, 1]
      row_values(rows, 3).should == ["3", 2, 0]
      row_values(rows, 4).should == ["4", 0, 0]
    end
  end

  shared_examples_for "story_type_acceptance_days_by_weeks" do
    it "produces a scatter chart of accepted stories per week" do
      rows = rows_for_chart(chart_type)

      rows.length.should == 2

      row_values(rows, 0).should == [1, 25]
      row_values(rows, 1).should == [3, 6]
    end
  end

  shared_examples_for "story_type_acceptance_total_by_days" do
    it "produces a bar chart for the time to acceptance of each story_type" do
      rows = rows_for_chart(chart_type)

      rows.length.should == 26

      row_values(rows, 6).should  == ["6", 1]
      row_values(rows, 25).should == ["25", 1]
    end
  end

  context "features" do
    let(:story_type) { "feature" }

    describe "#accepted_story_types" do
      let(:chart_type) { :accepted_story_types }

      it_should_behave_like "a chart generation method"

      it_should_behave_like "#accepted_story_types" do
        let(:feature_count) { 2 }
        let(:chore_count)   { 0 }
        let(:bug_count)     { 0 }
      end
    end

    describe "#features_discovery_and_acceptance" do
      let(:chart_type) { :features_discovery_and_acceptance }

      it_should_behave_like "a chart generation method"

      it_should_behave_like "story_type_discovery_and_acceptance"
    end

    describe "#features_acceptance_days_by_weeks" do
      let(:chart_type) { :features_acceptance_days_by_weeks }

      it_should_behave_like "a chart generation method"

      it_should_behave_like "story_type_acceptance_days_by_weeks"
    end

    describe "#features_acceptance_total_by_days" do
      let(:chart_type) { :features_acceptance_total_by_days }

      it_should_behave_like "a chart generation method"

      it_should_behave_like "story_type_acceptance_total_by_days"
    end
  end

  context "bugs" do
    let(:story_type) { "bug" }

    describe "#accepted_story_types" do
      let(:chart_type) { :accepted_story_types }

      it_should_behave_like "a chart generation method"

      it_should_behave_like "#accepted_story_types" do
        let(:feature_count) { 0 }
        let(:chore_count)   { 0 }
        let(:bug_count)     { 2 }
      end
    end

    describe "#bugs_discovery_and_acceptance" do
      let(:chart_type) { :bugs_discovery_and_acceptance }

      it_should_behave_like "a chart generation method"

      it_should_behave_like "story_type_discovery_and_acceptance"
    end

    describe "#bugs_acceptance_days_by_weeks" do
      let(:chart_type) { :bugs_acceptance_days_by_weeks }

      it_should_behave_like "a chart generation method"

      it_should_behave_like "story_type_acceptance_days_by_weeks"
    end

    describe "#bugs_acceptance_total_by_days" do
      let(:chart_type) { :bugs_acceptance_total_by_days }

      it_should_behave_like "a chart generation method"

      it_should_behave_like "story_type_acceptance_total_by_days"
    end
  end

  def rows_for_chart(method)
    @chart.send(method, @sample_stories).data_table.rows
  end

  def row_values(rows, num)
    rows[num].map { |c| c.v }
  end
end
