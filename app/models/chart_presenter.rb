class ChartWrapper
  attr_accessor :description

  def initialize(chart, description)
    self.description = description
    @chart = chart
  end

  def method_missing(m, *args, &block)
    @chart.send m, *args, &block
  end
end

class ChartPresenter
  DEF_CHART_WIDTH = 1000
  DEF_CHART_HEIGHT = 500

  attr_accessor :stories, :start_date, :end_date


  def initialize(iterations, stories, start_date = nil, end_date = nil)
    @iterations = iterations
    @stories = stories

    @start_date = start_date ? start_date.to_datetime : first_active_story_date
    @end_date = end_date ? end_date.to_datetime : last_active_story_date

    @start_iteration_nr = iteration_number @start_date
    @end_iteration_nr = iteration_number @end_date
  end

  def accepted_story_types(title = "Accepted Story Types")
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Story Type')
    data_table.new_column('number', 'Number')

    %W{feature chore bug}.each do |type|
      data_table.add_row([type.pluralize.capitalize, stories_with_types_states([type], ["accepted"]).size])
    end

    opts = {
        :width => DEF_CHART_WIDTH,
        :height => DEF_CHART_HEIGHT,
        :title => title}

    ChartWrapper.new(
        GoogleVisualr::Interactive::PieChart.new(data_table, opts),
        I18n.t('chart_accepted_story_types_desc')
    )
  end


  %W{feature bug}.each do |type|
    type_pluralized = type.pluralize
    type_titleized = type.pluralize.titleize

    # Methods:
    # features_discovery_and_acceptance
    # bugs_discovery_and_acceptance
    define_method "#{type_pluralized}_discovery_and_acceptance" do |title="#{type_titleized} Discovery and Acceptance"|

      stories = {}

      stories_with_types_states([type], nil).each do |story|
        nr = iteration_number(story.created_at)
        stories[nr] ||= {created: 0, accepted: 0}
        stories[nr][:created] += 1
        stories[nr][:accepted] += 1 if story.accepted?
      end

      data_table = GoogleVisualr::DataTable.new
      data_table.new_column("string", "Iteration")
      data_table.new_column("number", "All #{type_titleized}")
      data_table.new_column("string", nil, nil, "tooltip")
      data_table.new_column("number", "Accepted #{type_titleized}")
      data_table.new_column("string", nil, nil, "tooltip")

      (@start_iteration_nr..@end_iteration_nr).each do |number|
        values = stories[number] || {created: 0, accepted: 0}
        data_table.add_row([
          number.to_s,
          values[:created],
          "Iteration ##{number}\\n#{type_titleized}: #{values[:created]}",
          values[:accepted],
          "Iteration ##{number}\\n#{type_titleized}: #{values[:accepted]}",
          ]
        )

      end

      opts = {
          :width => DEF_CHART_WIDTH,
          :height => DEF_CHART_HEIGHT,
          :title => title,
          :hAxis => {:title => 'Iteration'}}
      ChartWrapper.new(
          GoogleVisualr::Interactive::AreaChart.new(data_table, opts),
          I18n.t("chart_#{type_pluralized}_discovery_and_acceptance_desc")
      )
    end

    # Methods:
    # features_acceptance_days_by_weeks
    # bugs_acceptance_days_by_weeks
    define_method "#{type_pluralized}_acceptance_days_by_iteration" do |title="#{type_titleized} Duration to Acceptance Per Iteration"|

      data_table = GoogleVisualr::DataTable.new
      data_table.new_column("number", "Iteration")
      data_table.new_column("number", "#{type_titleized}")
      data_table.new_column("string", nil, nil, "tooltip")


      stories_with_types_states([type], ["accepted"]).each do |story|
        nr = iteration_number(story.created_at)
        days = interval_in_days story.accepted_at, story.created_at
        data_table.add_row([nr, days, "Iteration ##{nr}\\nDays: #{days}"])
      end

      opts = {
          :width => DEF_CHART_WIDTH,
          :height => DEF_CHART_HEIGHT,
          :title => title,
          :hAxis => {
              :title => 'Iteration',
              :minValue => @start_iteration_nr,
              :maxValue => @end_iteration_nr,
          },
          :vAxis => {
              :title => 'Number of Days'}}

      ChartWrapper.new(
          GoogleVisualr::Interactive::ScatterChart.new(data_table, opts),
          I18n.t("chart_#{type_pluralized}_acceptance_days_by_iteration_desc")
      )

    end

    # Methods:
    # features_acceptance_total_by_days
    # bugs_acceptance_total_by_days
    define_method "#{type_pluralized}_acceptance_total_by_days" do |title="#{type_titleized} Duration to Acceptance By Days"|

      stories = {}
      max_days = 0
      stories_with_types_states([type], ["accepted"]).each do |story|
        days = interval_in_days story.accepted_at, story.created_at
        stories[days] ||= 0
        stories[days] += 1
        max_days = days if max_days < days
      end

      data_table = GoogleVisualr::DataTable.new
      data_table.new_column("string", "Days")
      data_table.new_column("number", "Number of #{type_titleized}")
      data_table.new_column("string", nil, nil, "tooltip")
      (0..max_days).each do |days|
        data_table.add_row([days.to_s, stories[days], "Days: #{days}\\n#{type_titleized}: #{stories[days]}"])
      end

      opts = {
          :width => DEF_CHART_WIDTH,
          :height => DEF_CHART_HEIGHT,
          :title => title,
          :hAxis => {:title => 'Days'},
          :vAxis => {:title => "Number of #{type_titleized}"}}

      ChartWrapper.new(
          GoogleVisualr::Interactive::ColumnChart.new(data_table, opts),
          I18n.t("chart_#{type_pluralized}_acceptance_total_by_days_desc")
      )

    end
  end

  def whole_project_velocity_chart()

    start_iteration_nr = iteration_number first_active_story_date
    end_iteration_nr = iteration_number last_active_story_date

    velocity_chart(start_iteration_nr, end_iteration_nr, {
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
    })
  end


  def date_range_velocity_chart()
    velocity_chart(@start_iteration_nr, @end_iteration_nr, {
        :title => "Velocity",
        :hAxis => {:title => 'Iterations'},
        :vAxis => {:title => "Points accepted"},
        width: DEF_CHART_WIDTH,
        height: DEF_CHART_HEIGHT
    })
  end

  private

  def first_active_story_date
    if not @stories.empty?
      @stories.map { |story| story.created_at }.sort.first
    else
      DateTime.now
    end
  end

  def last_active_story_date
    if not @stories.empty?
      @stories.map { |story| story.accepted? ? story.accepted_at : story.created_at }.sort.last
    else
      DateTime.now
    end
  end

  def velocity_chart(first_iteration_nr, last_iteration_nr, options = {})
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column("string", "Iteration")
    data_table.new_column("number", "Points accepted")
    data_table.new_column('string', nil, nil, 'tooltip')

    @iterations.each do |iteration|
      next if iteration.number < first_iteration_nr or iteration.number > last_iteration_nr

      points = 0
      iteration.stories.each do |story|
        points += story.estimate if story.respond_to?(:estimate) and story.accepted?
      end

      data_table.add_row([iteration.number.to_s, points, "Iteration ##{iteration.number}\\nPoints accepted: #{points}"])
    end

    formatter = GoogleVisualr::NumberFormat.new({prefix: 'Iteration #', fractionDigits: 0})
    formatter.columns(0)

    data_table.format(formatter)

    ChartWrapper.new(
        GoogleVisualr::Interactive::LineChart.new(data_table, options),
        I18n.t(:chart_velocity_desc)
    )
  end


  def stories_with_types_states(types, states)
    @stories.select do |story|
      next if story.created_at < self.start_date || (self.end_date && story.created_at > self.end_date)
      (types.present? ? types.include?(story.story_type) : true) && (states.present? ? states.include?(story.current_state) : true)
    end
  end

  def iteration_number(timestamp)
    date = timestamp.to_datetime
    return 0 if @iterations.empty? or @iterations.first.start > date
    @iterations.each do |it|
      return it.number if it.start <= date && it.finish > date
    end
    @iterations.last.number
  end

  def interval_in_days(time1, time2)
    (time1.to_datetime - time2.to_datetime).to_i.abs
  end

end
