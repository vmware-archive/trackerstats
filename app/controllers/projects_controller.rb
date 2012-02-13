class ProjectsController < ApplicationController
  before_filter :init_api_token
  before_filter :init_project_and_date_range, :only => :show

  def index
    @projects = Project.all
  end

  def show
    stories = @project.stories
    iterations = @project.iterations

    chart_presenter = ChartPresenter.new(iterations, stories, @start_date, @end_date)
    @active_iterations = chart_presenter.active_iterations

    @velocity_range_chart = chart_presenter.whole_project_velocity_chart()
    @velocity_range_chart.description = ""

    @charts = []
    @charts << chart_presenter.accepted_story_types_chart

    # Chart 1: Velocity
    @charts << chart_presenter.date_range_velocity_chart

    # Chart 2:  When are features discovered?
    @charts << chart_presenter.discovery_and_acceptance_chart(@story_filter)

    # Chart 3: How long did it take for features to be accepted in each week?
    @charts << chart_presenter.acceptance_days_by_iteration_chart(@story_filter)

    # Chart 4: What is the distribution of time to acceptance for features?
    @charts << chart_presenter.acceptance_by_days_chart(@story_filter)
  end

  private

  def init_api_token
    TrackerApi.token = session[:api_token]
  end

  def init_project_and_date_range
    @project  = Project.find(params[:id].to_i)

    @start_date = Date.parse(params[:start_date]) unless params[:start_date].blank?
    @end_date = Date.parse(params[:end_date]) unless params[:end_date].blank?

    @story_filter = []
    Story::ALL_STORY_TYPES.each do |type|
      if not params[type].blank?
        @story_filter << type
      end
    end

    @story_filter = ChartPresenter::DEFAULT_STORY_TYPES if @story_filter.empty?
    @story_filter.each do |type|
      params[type] = '1'
    end
  end
end
