class Iteration < TrackerResource

  self.site = TrackerApi::API_BASE_PATH + "/projects/:project_id"


  def stories
    Story.filter_stories super
  end

  def start_date
    @start_date ||= start.to_date
  end

  def finish_date
    @finish_date ||= finish.to_date
  end
end
