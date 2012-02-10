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
            :story_type => ChartPresenter::FEATURE,
            :created_at => DateTime.parse("2011-01-03 00:01:00 Z"), # iteration 1
            :current_state => "accepted",
            :accepted_at => DateTime.parse("2011-01-28 00:02:00 Z"),# ->iteration 4
            :estimate => 1,
            :accepted? => true),
        double(
            :story_type => ChartPresenter::BUG,
            :created_at => DateTime.parse("2011-01-08 00:01:00 Z"), # ->iteration 1
            :current_state => "started",
            :accepted? => false),
        double(
            :story_type => ChartPresenter::FEATURE,
            :created_at => DateTime.parse("2011-01-15 00:01:00 Z"), # iteration 2
            :current_state => "accepted",
            :estimate => 1,
            :accepted_at => DateTime.parse("2011-01-21 00:02:00 Z"),# ->iteration 3
            :accepted? => true),
        double(
            :story_type => ChartPresenter::CHORE,
            :created_at => DateTime.parse("2011-01-22 00:01:00 Z"), # ->iteration 3
            :current_state => "started",
            :accepted? => false),
        # ICEBOX
        double(
            :story_type => ChartPresenter::FEATURE,
            :created_at => DateTime.parse("2010-01-22 00:01:00 Z"), # iteration 0
            :current_state => "unscheduled",
            :accepted? => false),
        double(
            :story_type => ChartPresenter::BUG,
            :created_at => DateTime.parse("2011-01-22 00:01:00 Z"), # iteration 3
            :current_state => "unscheduled",
            :accepted? => false)
    ]

    stories = double("project stories")
    stories.stub(:all).and_return(@sample_stories)

    @iterations = double("iterations")
    @iterations.stub(:all).and_return([
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

    @iterations.all[0].stories << @sample_stories[1]
    @iterations.all[2].stories << @sample_stories[3]
    @iterations.all[2].stories << @sample_stories[2]
    @iterations.all[3].stories << @sample_stories[0]
  end

  context "feature/bug/chore charts" do
    let(:chart) {@chart_presenter.send(chart_method)}

    before do
      @chart_presenter = ChartPresenter.new(@iterations.all, @sample_stories, Date.parse("2010-01-01"))
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

        row_values(rows, 0).should == ["Features", count_accepted_stories(ChartPresenter::FEATURE)]
        row_values(rows, 1).should == ["Bugs", count_accepted_stories(ChartPresenter::BUG)]
        row_values(rows, 2).should == ["Chores", count_accepted_stories(ChartPresenter::CHORE)]
      end
    end

    describe "charts that can be filtered" do

      let(:story_filter) {ChartPresenter::ALL_STORY_TYPES}
      let(:chart) {@chart_presenter.send(chart_method, story_filter)}

      describe "#discovery_and_acceptance_chart" do
        let(:chart_method) {"discovery_and_acceptance_chart"}

        it_should_behave_like "a chart generation method"

        context "filtering by story type" do

          let(:story_filter) {[ChartPresenter::BUG] }

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
          let(:story_filter) {[ChartPresenter::FEATURE]}

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
          let(:story_filter) {[ChartPresenter::FEATURE, ChartPresenter::CHORE]}

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
      @chart = ChartPresenter.new(@iterations.all, @sample_stories)
      rows = @chart.whole_project_velocity_chart().data_table.rows

      rows.should_not be_nil
      rows.length.should == 4

      filter_tooltips(rows, 0).should == [@iterations.all[0].number.to_s, 0]
      filter_tooltips(rows, 1).should == [@iterations.all[1].number.to_s, 0]
      filter_tooltips(rows, 2).should == [@iterations.all[2].number.to_s, 1]
      filter_tooltips(rows, 3).should == [@iterations.all[3].number.to_s, 1]
    end
  end


  context "if start date and end date not provided" do

    it "should detect start and end date from provided stories" do
      chart_presenter = ChartPresenter.new(@iterations.all, @sample_stories)
      chart_presenter.start_date.should == @sample_stories[4].created_at
      chart_presenter.end_date.should == @sample_stories[0].accepted_at
    end

    it "should default to current date for start and end date when no stories provided" do
      Timecop.freeze(Time.now) do
        chart_presenter = ChartPresenter.new(@iterations.all, [])
        chart_presenter.start_date.should == DateTime.now
        chart_presenter.end_date.should == DateTime.now
      end
    end
  end
end
