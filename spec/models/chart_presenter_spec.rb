require 'spec_helper'

describe ChartPresenter do
  before do
    @project = double("project")

    @sample_stories = [
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2011-01-03 00:01:00 Z"), # week 1
          :current_state => "accepted",
          :accepted_at => DateTime.parse("2011-01-28 00:02:00 Z")), # week 4
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2011-01-08 00:01:00 Z"), # week 2
          :current_state => "started"),
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2011-01-15 00:01:00 Z"), # week 3
          :current_state => "accepted",
          :accepted_at => DateTime.parse("2011-01-21 00:02:00 Z")), # week 3
      double(
          :story_type => story_type,
          :created_at => DateTime.parse("2011-01-22 00:01:00 Z"), # week 4
          :current_state => "started")
    ]

    stories = double("project stories")
    stories.stub(:all).and_return(@sample_stories)

    @project.stub(:stories).and_return(stories)

    iterations = double("iterations")
    iterations.stub(:all).and_return([
      double(
        :number => 1,
        :start => Date.parse("2011-01-03"),
        :finish => Date.parse("2011-01-10")),
      double(
        :number => 2,
        :start => Date.parse("2011-01-10"),
        :finish => Date.parse("2011-01-17")),
      double(
        :number => 3,
        :start => Date.parse("2011-01-17"),
        :finish => Date.parse("2011-01-24")),
      double(
        :number => 4,
        :start => Date.parse("2011-01-24"),
        :finish => Date.parse("2011-01-31")),
    ])

    @project.stub(:iterations).and_return(iterations)

    @chart = ChartPresenter.new(@sample_stories, Date.parse('2011-01-01'))
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

      row_values(rows, 0).should == ["1", 1, 1]
      row_values(rows, 1).should == ["2", 1, 0]
      row_values(rows, 2).should == ["3", 1, 1]
      row_values(rows, 3).should == ["4", 1, 0]
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


  context "use iteration number" do
    let(:story_type) {"feature"}
    before do
      @project = double("project")
      stories = double("project stories")
      stories.stub(:all).and_return(@sample_stories)

      @project.stub(:stories).and_return(stories)

      it1 = double("it1")
      it1.stub(:start).and_return(Date.parse("2011-01-03"))
      it1.stub(:finish).and_return(Date.parse("2011-01-10"))
      it1.stub(:number).and_return(1)

      it2 = double("it2")
      it2.stub(:start).and_return(Date.parse("2011-01-10"))
      it2.stub(:finish).and_return(Date.parse("2011-01-17"))
      it2.stub(:number).and_return(2)

      it3 = double("it3")
      it3.stub(:start).and_return(Date.parse("2011-01-17"))
      it3.stub(:finish).and_return(Date.parse("2011-01-24"))
      it3.stub(:number).and_return(3)

      it4 = double("it4")
      it4.stub(:start).and_return(Date.parse("2011-01-24"))
      it4.stub(:finish).and_return(Date.parse("2011-01-31"))
      it4.stub(:number).and_return(3)

      iterations = double("iterations")
      iterations.stub(:all).and_return([it1, it2, it3, it4])

      @project.stub(:iterations).and_return(iterations)
    end

    describe "test" do
      it "project should have iterations" do
        @project.iterations.should_not be_nil
        @project.iterations.should respond_to(:all)
        @project.iterations.all.count.should  == 4

        @project.stories.should respond_to(:all)
        @project.stories.all.count.should == 4
      end
    end
  end

  def rows_for_chart(method)
    @chart.send(method, @sample_stories).data_table.rows
  end

  def row_values(rows, num)
    rows[num].map { |c| c.v }
  end
end
