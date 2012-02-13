class Iteration < TrackerResource

  self.site = TrackerApi::API_BASE_PATH + "/projects/:project_id"


  def stories
    Story.filter_stories super
  end
end
