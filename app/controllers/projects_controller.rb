class ProjectsController < ApplicationController
  before_filter :init_api_token
  before_filter :init_project_and_date_range, :only => :show

  def index
    @projects = PivotalTracker::Project.all
  end

  def show
    @stories  = @project.stories.all
    chart_presenter = ChartPresenter.new @stories, @start_date, @end_date

    @story_type_chart = chart_presenter.accepted_story_types

    # Chart 1:  When are features discovered?
    @chart_1 = chart_presenter.features_discovery_and_acceptance

    # Chart 2: How long did it take for features to be accepted in each week?
    @chart_2 = chart_presenter.features_acceptance_days_by_weeks

    # Chart 3: What is the distribution of time to acceptance for features?
    @chart_3 = chart_presenter.features_acceptance_total_by_days

    # Chart 4: When are bugs discovered?
    @chart_4 = chart_presenter.bugs_discovery_and_acceptance

    # Chart 5: How long did it take for bugs to be accepted in each week?
    @chart_5 = chart_presenter.bugs_acceptance_days_by_weeks

    # Chart 6: What is the distribution of time to acceptance for bugs?
    @chart_6 = chart_presenter.bugs_acceptance_total_by_days

    @charts = [@chart_1, @chart_2, @chart_3, @chart_4, @chart_5, @chart_6]
  end

  private

  def init_api_token
    PivotalTracker::Client.token = session[:api_token]
  end

  def init_project_and_date_range
    @project  = PivotalTracker::Project.find(params[:id].to_i)

    if params[:start_date].blank?
      @start_date = @project.iterations.all.detect { |iteration| iteration.number == 1 }.start
    else
      @start_date = Date.parse(params[:start_date])
    end

    @end_date = Date.parse(params[:end_date]) unless params[:end_date].blank?
  end
end
