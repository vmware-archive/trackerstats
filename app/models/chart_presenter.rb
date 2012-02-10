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
  FEATURE = 'feature'
  BUG = 'bug'
  CHORE = 'chore'

  ALL_STORY_TYPES = [
    FEATURE,
    BUG,
    CHORE
  ]

  DEFAULT_STORY_TYPES = [
    FEATURE,
    BUG
  ]

  STORY_TYPE_COLORS = {
      FEATURE => {default: '#3366CC', additional: '#80b3ff'},
      #FEATURE => {default: '#000000', additional: '#80b3ff'},
      BUG     => {default: '#DC3912', additional: '#ff865f'},
      CHORE   => {default: '#FF9900', additional: '#ffe64d'},
  }

  VELOCITY_COLOR = '#56A5EC'

  attr_accessor :stories, :start_date, :end_date


  def initialize(iterations, stories, start_date = nil, end_date = nil)
    @iterations = iterations
    @stories = stories

    @start_date = start_date ? start_date.to_datetime : first_active_story_date
    @end_date = end_date ? end_date.to_datetime : last_active_story_date

    @start_iteration_nr = iteration_number @start_date
    @end_iteration_nr = iteration_number @end_date
  end

  def accepted_story_types_chart(title = "Accepted Story Types")
    colors = []
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Story Type')
    data_table.new_column('number', 'Number')

    ALL_STORY_TYPES.each do |type|
      colors << STORY_TYPE_COLORS[type][:default]
      data_table.add_row([type.pluralize.capitalize, accepted_stories_with_types([type]).size])
    end

    opts = {
        :width => DEF_CHART_WIDTH,
        :height => DEF_CHART_HEIGHT,
        :title => title,
        :colors => colors}

    ChartWrapper.new(
        GoogleVisualr::Interactive::PieChart.new(data_table, opts),
        I18n.t(:accepted_story_types_chart_desc)
    )
  end

  def discovery_and_acceptance_chart(types = ALL_STORY_TYPES)
    data = {}
    series = []

    data_table = GoogleVisualr::DataTable.new
    data_table.new_column("string", "Iteration")
    types.each do |story_type|
      data_table.new_column("number", "All #{story_type.pluralize.titleize}")
      data_table.new_column("string", nil, nil, "tooltip")
      series << {color: STORY_TYPE_COLORS[story_type][:default]}

      data_table.new_column("number", "Accepted  #{story_type.pluralize.titleize}")
      data_table.new_column("string", nil, nil, "tooltip")
      series << {color: STORY_TYPE_COLORS[story_type][:additional]}
    end


    stories_with_types_states(types, nil).each do |story|
      nr = iteration_number(story.created_at)
      data[nr] ||= {}
      data[nr][story.story_type] ||= {created: 0, accepted: 0}

      data[nr][story.story_type][:created] += 1
      data[nr][story.story_type][:accepted] += 1 if story.accepted?
    end

    (@start_iteration_nr..@end_iteration_nr).each do |nr|
      row = [nr.to_s]
      types.each do |story_type|
        data[nr] ||= {}
        data[nr][story_type] ||= {created: 0, accepted: 0}

        row << data[nr][story_type][:created]
        row << "Iteration ##{nr}\\n#{story_type.pluralize.titleize}: #{data[nr][story_type][:created]}"
        row << data[nr][story_type][:accepted]
        row << "Iteration ##{nr}\\n#{story_type.pluralize.titleize}: #{data[nr][story_type][:accepted]}"

      end
      data_table.add_row(row)
    end

    opts = {
          :width => DEF_CHART_WIDTH,
          :height => DEF_CHART_HEIGHT,
          :title => "Story Discovery and Acceptance",
          :hAxis => {:title => 'Iteration'},
          :series => series}

    ChartWrapper.new(
        GoogleVisualr::Interactive::AreaChart.new(data_table, opts),
        I18n.t(:discovery_and_acceptance_chart_desc)
    )

  end

  def acceptance_days_by_iteration_chart(types = ALL_STORY_TYPES)

    # Iteration # | Feature Days | Bug Days | Chore Days
    # --------------------------------------------------
    #      1            2             0           0
    #      1            0             5           0

    series = []

    data_table = GoogleVisualr::DataTable.new
    data_table.new_column("number", "Iteration")
    types.each do |story_type|
      data_table.new_column("number", "#{story_type.titleize}")
      data_table.new_column("string", nil, nil, "tooltip")

      series << {color: STORY_TYPE_COLORS[story_type][:default]}
    end

    accepted_stories_with_types(types).each do |story|
      nr = iteration_number(story.created_at)
      days =  interval_in_days story.accepted_at, story.created_at
      row = [nr]
      types.each do |story_type|
         row <<  (story.story_type == story_type ? days : nil)
         row << (story.story_type == story_type ? "Iteration ##{nr}\\nDays: #{days}" : "")
      end
      data_table.add_row(row)
    end

    opts = {
        :width => DEF_CHART_WIDTH,
        :height => DEF_CHART_HEIGHT,
        :title => "Story Duration to Acceptance Per Iteration",
        :hAxis => {
            :title => 'Iteration',
            :minValue => @start_iteration_nr,
            :maxValue => @end_iteration_nr,
        },
        :vAxis => {
            :title => 'Number of Days'},
        :series => series
    }

    ChartWrapper.new(
        GoogleVisualr::Interactive::ScatterChart.new(data_table, opts),
        I18n.t(:acceptance_days_by_iteration_chart_desc)
    )

  end

  def acceptance_by_days_chart(types = ALL_STORY_TYPES)

    #  Days  | Feature #| Bug # | Chore #
    # --------------------------------------------------
    #    10       2        0        0
    #    25       0        1        0
    series = []
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column("string", "Days")
    types.each do |story_type|
      data_table.new_column("number", "Number of #{story_type.pluralize.titleize}")
      data_table.new_column("string", nil, nil, "tooltip")

      series << {color: STORY_TYPE_COLORS[story_type][:default]}
    end

    data = {}
    max_days = 0
    accepted_stories_with_types(types).each do |story|
      days = interval_in_days(story.accepted_at, story.created_at)
      max_days = days if max_days < days

      data[days] ||= {}
      data[days][story.story_type] ||= 0
      data[days][story.story_type] += 1
    end

   (0..max_days).each do |days|
     row = [days.to_s]
     types.each do |story_type|
        stories_count = data[days].nil? ? 0 : (data[days][story_type] || 0)
        row << stories_count
        row << (stories_count > 0 ? "Days: #{days}\\n#{story_type.pluralize.titleize}: #{stories_count}" : "")
     end
     data_table.add_row(row)
   end

    opts = {
        :width => DEF_CHART_WIDTH,
        :height => DEF_CHART_HEIGHT,
        :title => "Story Duration to Acceptance By Days",
        :hAxis => {
            :title => 'Days'},
        :vAxis => {:title => "Number of stories"},
        :series => series}

    ChartWrapper.new(
        GoogleVisualr::Interactive::ColumnChart.new(data_table, opts),
        I18n.t(:acceptance_by_days_chart_desc)
    )

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
        GoogleVisualr::Interactive::LineChart.new(data_table, options.merge({:series => [:color => VELOCITY_COLOR]})),
        I18n.t(:velocity_chart_desc)
    )
  end

  def stories_with_types_states(types, states)
    @stories.select do |story|
      next if story.created_at < self.start_date || (self.end_date && story.created_at > self.end_date)
      (types.present? ? types.include?(story.story_type) : true) && (states.present? ? states.include?(story.current_state) : true)
    end
  end

  def accepted_stories_with_types(types)
    stories_with_types_states(types, ["accepted"])
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
