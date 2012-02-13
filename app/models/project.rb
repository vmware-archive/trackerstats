class Project < TrackerResource

  self.site = TrackerApi::API_BASE_PATH

  def stories
    @stories ||= Story.filter_stories(Story.find(:all, params: { project_id: self.id }))
  end

  def iterations
    @iterations ||= Iteration.find(:all, params: { project_id: self.id })
  end
end
