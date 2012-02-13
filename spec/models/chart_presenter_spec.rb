require 'spec_helper'

describe ChartPresenter do

  def row_values(rows, num)
    rows[num].map { |c| c.v }
  end

  def filter_tooltips(rows, row_idx)
    row_values(rows, row_idx).select{|x| !(x =~ /^(Iteration|Days|^$)/)}
  end

  before :each do
    @sample_stories = [
        double(
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2011-01-03 00:01:00 Z"), # iteration 1
            :current_state => "accepted",
            :accepted_at => DateTime.parse("2011-01-28 00:02:00 Z"),# ->iteration 4
            :estimate => 1,
            :accepted? => true),
        double(
            :story_type => Story::BUG,
            :created_at => DateTime.parse("2011-01-08 00:01:00 Z"), # ->iteration 1
            :current_state => "started",
            :accepted? => false),
        double(
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2011-01-15 00:01:00 Z"), # iteration 2
            :current_state => "accepted",
            :estimate => 1,
            :accepted_at => DateTime.parse("2011-01-21 00:02:00 Z"),# ->iteration 3
            :accepted? => true),
        double(
            :story_type => Story::CHORE,
            :created_at => DateTime.parse("2011-01-22 00:01:00 Z"), # ->iteration 3
            :current_state => "started",
            :accepted? => false),
        # ICEBOX
        double(
            :story_type => Story::FEATURE,
            :created_at => DateTime.parse("2010-01-22 00:01:00 Z"), # iteration 0
            :current_state => "unscheduled",
            :accepted? => false),
        double(
            :story_type => Story::BUG,
            :created_at => DateTime.parse("2011-01-22 00:01:00 Z"), # iteration 3
            :current_state => "unscheduled",
            :accepted? => false)
    ]

    stories = double("project stories")
    stories.stub(:all).and_return(@sample_stories)

    @iterations = [
      double(
        :number => 1,
        :start_date => Date.parse("2011-01-03"),
        :finish_date => Date.parse("2011-01-10"),
        :stories => []),
      double(
        :number => 2,
        :start_date => Date.parse("2011-01-10"),
        :finish_date => Date.parse("2011-01-17"),
        :stories => []),
      double(
        :number => 3,
        :start_date => Date.parse("2011-01-17"),
        :finish_date => Date.parse("2011-01-24"),
        :stories => []),
      double(
        :number => 4,
        :start_date => Date.parse("2011-01-24"),
        :finish_date => Date.parse("2011-01-31"),
        :stories => []),
      ]

    @iterations[0].stories << @sample_stories[1]
    @iterations[2].stories << @sample_stories[3]
    @iterations[2].stories << @sample_stories[2]
    @iterations[3].stories << @sample_stories[0]
  end


  describe "active iterations" do
    let(:iterations) {  @iterations }

    it "should return the list of iterations within the active stories date range" do
      expected_first_iteration_nr = iterations.first.number
      expected_last_iteration_nr = iterations.last.number


      chart_presenter = ChartPresenter.new(iterations, @sample_stories)
      active_iterations = chart_presenter.active_iterations

      active_iterations.length.should == @iterations.length

      active_iterations.first.number.should == expected_first_iteration_nr
      active_iterations.last.number.should == expected_last_iteration_nr
    end

    it "should return only one iteration for given date range" do
      # Case #2
      chart_presenter = ChartPresenter.new(iterations, @sample_stories)
      chart_presenter.stub(first_active_story_date: DateTime.parse("2011-01-17 00:01:00 Z") )
      chart_presenter.stub(last_active_story_date: DateTime.parse("2011-01-23 00:02:00 Z") )
      active_iterations = chart_presenter.active_iterations

      active_iterations.length.should == 1

      active_iterations.first.number.should == 3
      active_iterations.last.number.should == 3
    end

    it "should return zero iterations for active date range before the first iteration" do
      # Case #3
      chart_presenter = ChartPresenter.new(iterations, @sample_stories)
      chart_presenter.stub(first_active_story_date: DateTime.parse("2010-01-17 00:01:00 Z") )
      chart_presenter.stub(last_active_story_date: DateTime.parse("2010-01-23 00:02:00 Z") )
      active_iterations = chart_presenter.active_iterations

      active_iterations.length.should == 0
    end

    it "should return zero iterations for active date range after the last iteration" do
      # Case #4
      chart_presenter = ChartPresenter.new(iterations, @sample_stories)
      chart_presenter.stub(first_active_story_date: DateTime.parse("2012-01-17 00:01:00 Z") )
      chart_presenter.stub(last_active_story_date: DateTime.parse("2012-01-23 00:02:00 Z") )
      active_iterations = chart_presenter.active_iterations

      active_iterations.length.should == 0
    end

    it "should return two iteration for active date range that is matching the iterations start and end date" do
      chart_presenter = ChartPresenter.new(iterations, @sample_stories)
      chart_presenter.stub(first_active_story_date: DateTime.parse("2011-01-10 00:00:01 Z") )
      chart_presenter.stub(last_active_story_date: DateTime.parse("2011-01-23 23:59:59 Z") )
      active_iterations = chart_presenter.active_iterations

      active_iterations.length.should == 2

      active_iterations.first.number.should == 2
      active_iterations.last.number.should == 3
    end
  end

  context "feature/bug/chore charts" do
    let(:chart) {@chart_presenter.send(chart_method)}

    before do
      @chart_presenter = ChartPresenter.new(@iterations, @sample_stories, Date.parse("2010-01-01"))
    end

    shared_examples_for "a chart generation method" do

      it "allows the chart description to be set" do
        desc = "My Description"
        chart.description.should_not == desc
        chart.description = desc
        chart.description.should == desc
      end

      it "and gets its description from I18n" do
        I18n.should_receive(:t).with("#{chart_method}_desc".to_sym).and_return("#{chart_method} description")
        @chart_presenter.send(chart_method)
      end
    end

    describe "#accepted_story_types_chart" do
      let(:chart_method) {"accepted_story_types_chart"}

      it_should_behave_like "a chart generation method"

      it "produces a chart" do
        rows = chart.data_table.rows

       def count_accepted_stories(type)
          result = 0
          @sample_stories.each do |story|
            result += 1 if story.accepted? and story.story_type == type
          end
          result
        end

        row_values(rows, 0).should == ["Features", count_accepted_stories(Story::FEATURE)]
        row_values(rows, 1).should == ["Bugs", count_accepted_stories(Story::BUG)]
        row_values(rows, 2).should == ["Chores", count_accepted_stories(Story::CHORE)]
      end
    end

    describe "charts that can be filtered" do

      let(:story_filter) {Story::ALL_STORY_TYPES}
      let(:chart) {@chart_presenter.send(chart_method, story_filter)}

      describe "#discovery_and_acceptance_chart" do
        let(:chart_method) {"discovery_and_acceptance_chart"}

        it_should_behave_like "a chart generation method"

        context "filtering by story type" do

          let(:story_filter) {[Story::BUG] }

          it "accepts an array of the story types to be filtered" do
            rows = chart.data_table.rows

            rows.length.should == 5
                                               # I   Bc Ba
            filter_tooltips(rows, 0).should == ["0", 0, 0]
            filter_tooltips(rows, 1).should == ["1", 1, 0]
            filter_tooltips(rows, 2).should == ["2", 0, 0]
            filter_tooltips(rows, 3).should == ["3", 1, 0]
            filter_tooltips(rows, 4).should == ["4", 0, 0]
          end
        end

        it "produces an area chart for the discovery and subsequent acceptance of stories" do
          rows = chart.data_table.rows

          rows.length.should == 5
                                             # I   Fc Fa Bc Ba Cc Ca
          filter_tooltips(rows, 0).should == ["0", 1, 0, 0, 0, 0, 0]
          filter_tooltips(rows, 1).should == ["1", 1, 1, 1, 0, 0, 0]
          filter_tooltips(rows, 2).should == ["2", 1, 1, 0, 0, 0, 0]
          filter_tooltips(rows, 3).should == ["3", 0, 0, 1, 0, 1, 0]
          filter_tooltips(rows, 4).should == ["4", 0, 0, 0, 0, 0, 0]
        end
      end

      describe "#acceptance_days_by_iteration_chart" do
        let(:chart_method) {"acceptance_days_by_iteration_chart"}

        it_should_behave_like "a chart generation method"

        context "filtering by story type" do
          let(:story_filter) {[Story::FEATURE]}

          it "accepts an array of story types to filter" do
            rows = chart.data_table.rows

            rows.length.should == 2
                                              # I  Fd
            filter_tooltips(rows, 0).should == [1, 25]
            filter_tooltips(rows, 1).should == [2, 06]
          end
        end

        it "produces a scatter chart of accepted stories per iteration" do
          rows = chart.data_table.rows

          rows.length.should == 2
                                            # I  Fd   Bd   Cd
          filter_tooltips(rows, 0).should == [1, 25, nil, nil]
          filter_tooltips(rows, 1).should == [2, 06, nil, nil]
        end
      end

      describe "#acceptance_by_days_chart" do
        let(:chart_method) {"acceptance_by_days_chart"}

        it_should_behave_like "a chart generation method"

        context "filtering by story type" do
          let(:story_filter) {[Story::FEATURE, Story::CHORE]}

          it "accepts an array of story types to filter" do
            rows = chart.data_table.rows

            rows.length.should == 26
                                                # D    Fd Cd
            filter_tooltips(rows, 6).should  == ["6",  1, 0]
            filter_tooltips(rows, 25).should == ["25", 1, 0]
          end
        end

        it "produces a bar chart for the time to acceptance of each story" do
          rows = chart.data_table.rows

          rows.length.should == 26
                                              # D    Fd Bd Cd
          filter_tooltips(rows, 6).should  == ["6",  1, 0, 0]
          filter_tooltips(rows, 25).should == ["25", 1, 0, 0]
        end
      end
    end
  end

  describe "#whole_project_velocity_chart" do
    it "should detect first and last iteration with any activity for the chart" do
      chp = ChartPresenter.new(@iterations, @sample_stories)
      chart = chp.whole_project_velocity_chart

      chart.chart.instance_of?(GoogleVisualr::Interactive::AreaChart).should == true

      rows = chart.data_table.rows

      rows.should_not be_nil
      rows.length.should == 5

      filter_tooltips(rows, 0).should == ["0", 0]
      filter_tooltips(rows, 1).should == [@iterations[0].number.to_s, 0]
      filter_tooltips(rows, 2).should == [@iterations[1].number.to_s, 0]
      filter_tooltips(rows, 3).should == [@iterations[2].number.to_s, 1]
      filter_tooltips(rows, 4).should == [@iterations[3].number.to_s, 1]
    end
  end

  describe "#date_range_velocity_chart" do
    it "should produce correct chart" do
      chp = ChartPresenter.new(@iterations, @sample_stories, @iterations[1].start_date, @iterations[2].finish_date)
      rows = chp.date_range_velocity_chart.data_table.rows

      rows.should_not be_nil
      rows.length.should == 2

      filter_tooltips(rows, 0).should == [@iterations[1].number.to_s, 0]
      filter_tooltips(rows, 1).should == [@iterations[2].number.to_s, 1]
    end
  end

  context "if start date and end date not provided" do

    it "should detect start and end date from provided stories" do
      chart_presenter = ChartPresenter.new(@iterations, @sample_stories)
      chart_presenter.start_date.should == @sample_stories[4].created_at.to_date
      chart_presenter.end_date.should == @sample_stories[0].accepted_at.to_date
    end

    it "should default to current date for start and end date when no stories provided" do
      Timecop.freeze(Time.now) do
        chart_presenter = ChartPresenter.new(@iterations, [])
        chart_presenter.start_date.should == Date.today
        chart_presenter.end_date.should == Date.today
      end
    end
  end
end
