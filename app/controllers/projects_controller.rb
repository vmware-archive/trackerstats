class ProjectsController < ApplicationController
  before_filter :init_api_token
  before_filter :init_project_and_date_range, :only => :show

  def index
    @projects = Project.all
  end

  def show
    @stories = @project.stories
    @iterations = @project.iterations

    chart_presenter = ChartPresenter.new(@iterations, @stories, @start_date, @end_date)

    @velocity_range_chart = chart_presenter.velocity(0,
      @iterations.empty? ? 0 : @iterations.last.number, {
        theme: 'maximized',
        title: nil,
        legend: {position: 'none'},
        height: 75,
        hAxis: {
          title: nil,
          textPosition: 'none',
          maxAlternation: 1,
        },
        vAxis: {
          title: nil,
          textPosition: 'none',
          gridlines: {color: '#fff'}
        },
      }
    )
    @velocity_range_chart.description = ""

    @charts = []
    @charts << chart_presenter.accepted_story_types

    # Chart 1:  When are features discovered?
    @charts << chart_presenter.features_discovery_and_acceptance

    # Chart 2: How long did it take for features to be accepted in each week?
    @charts << chart_presenter.features_acceptance_days_by_iteration

    # Chart 3: What is the distribution of time to acceptance for features?
    @charts << chart_presenter.features_acceptance_total_by_days

    # Chart 4: When are bugs discovered?
    @charts << chart_presenter.bugs_discovery_and_acceptance

    # Chart 5: How long did it take for bugs to be accepted in each week?
    @charts << chart_presenter.bugs_acceptance_days_by_iteration

    # Chart 6: What is the distribution of time to acceptance for bugs?
    @charts << chart_presenter.bugs_acceptance_total_by_days

    # Chart 7: Velocity
    @charts << chart_presenter.date_range_velocity_chart
  end

  private

  def init_api_token
    TrackerApi.token = session[:api_token]
  end

  def init_project_and_date_range
    @project  = Project.find(params[:id].to_i)

    @start_date = if (not params[:start_date].blank?)
      Date.parse(params[:start_date])
    elsif not @project.iterations.empty?
      @project.iterations.detect { |iteration| iteration.number == 1 }.start
    elsif @project.respond_to?(:start_date)
      @project.start_date
    else
      Date.today
    end

    @end_date = Date.parse(params[:end_date]) unless params[:end_date].blank?
  end
end
