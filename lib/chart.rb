class Chart
  attr_accessor :start_date, :end_date

  def initialize(start_date, end_date=nil)
    self.start_date = start_date
    self.end_date = end_date
  end

  #TODO: Let all chart generation methods take in an opts hash

  def accepted_story_types(stories, title = "Story Types")
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Story Type')
    data_table.new_column('number', 'Number')
    %W{feature chore bug}.each do |type|
      data_table.add_row( [ type.pluralize.capitalize, stories_with_types_states(stories, [type] , ["accepted"]).size ] )
    end
    opts     = { :width => 1000, :height => 500, :title => title }
    GoogleVisualr::Interactive::PieChart.new(data_table, opts)
  end

  def new_features_distribution(stories, title = "Distribution of New Features")
    features = {1 => { created: 0, accepted:0 }}
    stories_with_types_states(stories, ["feature"], nil).each do |story|
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

    opts     = { :width => 1000, :height => 500, :title => title, :hAxis => { :title => 'Week' } }
    GoogleVisualr::Interactive::AreaChart.new(data_table, opts)
  end

  def accepted_features_per_week(stories)
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('number', 'Week')
    data_table.new_column('number', 'Features')
    stories_with_types_states(stories, ["feature"], ["accepted"]).each do |story|
      week = week?(story.created_at)
      days = (story.accepted_at - story.created_at).to_i
      data_table.add_row([week, days])
    end

    opts     = { :width => 1000, :height => 500, :title => 'How long did it take for features to be accepted in each week?' , :hAxis => { :title => 'Week', :minValue => 0 }, :vAxis => { :title => 'Number of Days' }}
    GoogleVisualr::Interactive::ScatterChart.new(data_table, opts)
  end

  protected

  def stories_with_types_states(stories, types, states)
    stories.select do |story|
      next if story.created_at < self.start_date || (self.end_date && story.created_at > self.end_date)
      (types.present? ? types.include?(story.story_type) : true) && (states.present? ? states.include?(story.current_state) : true)
    end
  end

  def max_value(obj)
    obj.to_a.sort { |x,y| x[0] <=> y[0] }.last[0]
  end

  def week?(date)
    return nil if date.blank?
    return nil if date < start_date || (end_date && date > end_date)
    ((date - start_date).to_i / 7) + 1
  end
end
