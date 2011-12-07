class Chart

  attr_accessor :stories, :start_date, :end_date

  def initialize(stories, start_date, end_date=nil)
    @stories    = stories
    @start_date = start_date
    @end_date   = end_date
  end

  def accepted_story_types(title = "Accepted Story Types")
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Story Type')
    data_table.new_column('number', 'Number')

    %W{feature chore bug}.each do |type|
      data_table.add_row( [ type.pluralize.capitalize, stories_with_types_states(@stories, [type] , ["accepted"]).size ] )
    end

    opts = { :width => 1000, :height => 500, :title => title }
    GoogleVisualr::Interactive::PieChart.new(data_table, opts)
  end

  %W{feature bug}.each do |type|
    type_pluralized = type.pluralize
    type_titleized  = type.pluralize.titleize

    # Methods:
    # features_discovery_and_acceptance
    # bugs_discovery_and_acceptance
    define_method "#{type_pluralized}_discovery_and_acceptance" do |title="#{type_titleized} Discovery and Acceptance"|

      stories = { 1 => { created: 0, accepted:0 } }
      stories_with_types_states(@stories, [type], nil).each do |story|
        week = week?(story.created_at)
        stories[week] ||= { created: 0, accepted:0 }
        stories[week][:created]  += 1
        stories[week][:accepted] += 1 if story.current_state == "accepted"
      end

      data_table = GoogleVisualr::DataTable.new
      data_table.new_column("string", "Week")
      data_table.new_column("number", "All #{type_titleized}")
      data_table.new_column("number", "Accepted #{type_titleized}")

      (1..max_value(stories)).each do |week|
        values = stories[week] || { created: 0, accepted:0 }
        data_table.add_row([week.to_s, values[:created], values[:accepted]])
      end

      opts = { :width => 1000, :height => 500, :title => title, :hAxis => { :title => 'Week' } }
      GoogleVisualr::Interactive::AreaChart.new(data_table, opts)

    end

    # Methods:
    # features_acceptance_days_by_weeks
    # bugs_acceptance_days_by_weeks
    define_method "#{type_pluralized}_acceptance_days_by_weeks" do |title="#{type_titleized} Duration to Acceptance Per Week"|

      data_table = GoogleVisualr::DataTable.new
      data_table.new_column("number", "Week")
      data_table.new_column("number", "#{type_titleized}")

      stories_with_types_states(@stories, [type], ["accepted"]).each do |story|
        week = week?(story.created_at)
        days = (story.accepted_at - story.created_at).to_i
        data_table.add_row([week, days])
      end

      opts = { :width => 1000, :height => 500, :title => title , :hAxis => { :title => 'Week', :minValue => 0 }, :vAxis => { :title => 'Number of Days' }}
      GoogleVisualr::Interactive::ScatterChart.new(data_table, opts)

    end

    # Methods:
    # features_acceptance_total_by_days
    # bugs_acceptance_total_by_days
    define_method "#{type_pluralized}_acceptance_total_by_days" do |title="#{type_titleized} Duration to Acceptance By Days"|

      stories = {1 => 0}
      stories_with_types_states(@stories, [type], ["accepted"]).each do |story|
        days = (story.accepted_at - story.created_at).to_i
        stories[days] ||= 0
        stories[days]  += 1
      end

      data_table = GoogleVisualr::DataTable.new
      data_table.new_column("string", "Days")
      data_table.new_column("number", "Number of #{type_titleized}")
      (0..max_value(stories)).each do |days|
        data_table.add_row([days.to_s, stories[days]])
      end

      opts = { :width => 1000, :height => 500, :title => title, :hAxis => { :title => 'Days' }, :vAxis => { :title => "Number of #{type_titleized}" }}
      GoogleVisualr::Interactive::ColumnChart.new(data_table, opts)

    end
  end

  protected

  def stories_with_types_states(stories, types, states)
    stories.select do |story|
      next if story.created_at < self.start_date || (self.end_date && story.created_at > self.end_date)
      (types.present? ? types.include?(story.story_type) : true) && (states.present? ? states.include?(story.current_state) : true)
    end
  end

  def week?(date)
    return nil if date.blank?
    return nil if date < start_date || (end_date && date > end_date)
    ((date - start_date).to_i / 7) + 1
  end

  def max_value(obj)
    obj.to_a.sort { |x,y| x[0] <=> y[0] }.last[0]
  end
end
