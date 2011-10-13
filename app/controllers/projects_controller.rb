class ProjectsController < ApplicationController
  before_filter :init_api_token
  before_filter :init_project_and_date_range, :only => :show

  def index
    @projects = PivotalTracker::Project.all
  end

  def show
    @stories  = @project.stories.all

    # Chart 0: Features, Bugs and Chores Total
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Story Type')
    data_table.new_column('number', 'Number')
    data_table.add_row( [ "Features", stories_with_types_states(@stories, ["feature"] , ["accepted"]).size ] )
    data_table.add_row( [ "Chores"  , stories_with_types_states(@stories, ["chore"]   , ["accepted"]).size ] )
    data_table.add_row( [ "Bugs"    , stories_with_types_states(@stories, ["bug"]     , ["accepted"]).size ] )

    opts     = { :width => 1000, :height => 500, :title => 'What have we done?' }
    @chart_0 = GoogleVisualr::Interactive::PieChart.new(data_table, opts)


    # Chart 1:  When are features discovered?
    features = {}
    stories_with_types_states(@stories, ["feature"], nil).each do |story|
      week = week?(story.created_at)
      features[week] ||= { created: 0, accepted:0 }
      features[week][:created]  += 1
      features[week][:accepted] += 1 if story.current_state == "accepted"
    end

    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Week')
    data_table.new_column('number', 'All Features')
    data_table.new_column('number', 'Accepted Features')
    (1..max_value(features)).each do |week|
      values = features[week] || { created: 0, accepted:0 }
      data_table.add_row([week.to_s, values[:created], values[:accepted]])
    end

    opts     = { :width => 1000, :height => 500, :title => 'When are features discovered?', :hAxis => { :title => 'Week' } }
    @chart_1 = GoogleVisualr::Interactive::AreaChart.new(data_table, opts)


    # Chart 2: How long did it take for features to be accepted in each week?
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('number', 'Week')
    data_table.new_column('number', 'Features')
    stories_with_types_states(@stories, ["feature"], ["accepted"]).each do |story|
      week = week?(story.created_at)
      days = (story.accepted_at - story.created_at).to_i
      data_table.add_row([week, days])
    end

    opts     = { :width => 1000, :height => 500, :title => 'How long did it take for features to be accepted in each week?' , :hAxis => { :title => 'Week', :minValue => 0 }, :vAxis => { :title => 'Number of Days' }}
    @chart_2 = GoogleVisualr::Interactive::ScatterChart.new(data_table, opts)


    # Chart 3: What is the distribution of time to acceptance for features?
    features = {}
    stories_with_types_states(@stories, ["feature"], ["accepted"]).each do |story|
      days = (story.accepted_at - story.created_at).to_i
      features[days] ||= 0
      features[days]  += 1
    end

    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Days')
    data_table.new_column('number', 'Number of Features')
    (0..max_value(features)).each do |days|
      data_table.add_row([days.to_s, features[days]])
    end

    opts     = { :width => 1000, :height => 500, :title => 'What is the distribution for time to acceptance of features?' , :hAxis => { :title => 'Days' }, :vAxis => { :title => 'Number of Features' }}
    @chart_3 = GoogleVisualr::Interactive::ColumnChart.new(data_table, opts)


    # Chart 4:  When are bugs discovered?
    bugs = {}
    stories_with_types_states(@stories, ["bug"], nil).each do |story|
      week = week?(story.created_at)
      bugs[week] ||= { created: 0, accepted:0 }
      bugs[week][:created]  += 1
      bugs[week][:accepted] += 1 if story.current_state == "accepted"
    end

    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Week')
    data_table.new_column('number', 'All Bugs')
    data_table.new_column('number', 'Accepted Bugs')
    (1..max_value(bugs)).each do |week|
      values = bugs[week] || { created: 0, accepted:0 }
      data_table.add_row([week.to_s, values[:created], values[:accepted]])
    end

    opts     = { :width => 1000, :height => 500, :title => 'When are bugs discovered?', :hAxis => { :title => 'Week' } }
    @chart_4 = GoogleVisualr::Interactive::AreaChart.new(data_table, opts)


    # Chart 5: How long did it take for bugs to be accepted in each week?
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('number', 'Week')
    data_table.new_column('number', 'Bugs')
    stories_with_types_states(@stories, ["bug"], ["accepted"]).each do |story|
      week = week?(story.created_at)
      days = (story.accepted_at - story.created_at).to_i
      data_table.add_row([week, days])
    end

    opts     = { :width => 1000, :height => 500, :title => 'How long did it take for bugs to be accepted in each week?' , :hAxis => { :title => 'Week', :minValue => 0 }, :vAxis => { :title => 'Number of Days' }}
    @chart_5 = GoogleVisualr::Interactive::ScatterChart.new(data_table, opts)


    # Chart 6: What is the distribution of time to acceptance for bugs?
    bugs = {}
    stories_with_types_states(@stories, ["bug"], ["accepted"]).each do |story|
      days = (story.accepted_at - story.created_at).to_i
      bugs[days] ||= 0
      bugs[days]  += 1
    end

    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Days')
    data_table.new_column('number', 'Number of Bugs')
    (0..max_value(bugs)).each do |days|
      data_table.add_row([days.to_s, bugs[days]])
    end

    opts     = { :width => 1000, :height => 500, :title => 'What is the distribution for time to acceptance of bugs?' , :hAxis => { :title => 'Days' }, :vAxis => { :title => 'Number of Bugs' }}
    @chart_6 = GoogleVisualr::Interactive::ColumnChart.new(data_table, opts)
  end

  private

  def init_api_token
    PivotalTracker::Client.token = session[:api_token]
  end

  def init_project_and_date_range
    @project  = PivotalTracker::Project.find(params[:id].to_i)

    @start_date = params[:start_date].present? ? Date.parse(params[:start_date]) : 3.months.ago.to_date
    @end_date = Date.parse(params[:end_date]) unless params[:end_date].blank?
  end

  def stories_with_types_states(stories, types, states)
    stories.select do |story|
      next if story.created_at < @start_date || (@end_date && story.created_at > @end_date)
      (types.present? ? types.include?(story.story_type) : true) && (states.present? ? states.include?(story.current_state) : true)
    end
  end

  def week?(date)
    return nil if date.blank?
    return nil if date < @start_date || (@end_date && date > @end_date)
    ((date - @start_date).to_i / 7) + 1
  end

  def max_value(obj)
    obj.to_a.sort { |x,y| x[0] <=> y[0] }.last[0]
  end
end
