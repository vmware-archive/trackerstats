class Chart
  attr_accessor :start_date, :end_date

  def initialize(start_date, end_date=nil)
    self.start_date = start_date
    self.end_date = end_date
  end

  def story_type(stories)
    data_table = GoogleVisualr::DataTable.new
    data_table.new_column('string', 'Story Type')
    data_table.new_column('number', 'Number')
    data_table.add_row( [ "Features", stories_with_types_states(stories, ["feature"] , ["accepted"]).size ] )
    data_table.add_row( [ "Chores"  , stories_with_types_states(stories, ["chore"]   , ["accepted"]).size ] )
    data_table.add_row( [ "Bugs"    , stories_with_types_states(stories, ["bug"]     , ["accepted"]).size ] )
    opts     = { :width => 1000, :height => 500, :title => 'What have we done?' }
    GoogleVisualr::Interactive::PieChart.new(data_table, opts)
  end

  protected

  def stories_with_types_states(stories, types, states)
    stories.select do |story|
      next if story.created_at < self.start_date || (self.end_date && story.created_at > self.end_date)
      (types.present? ? types.include?(story.story_type) : true) && (states.present? ? states.include?(story.current_state) : true)
    end
  end
end
