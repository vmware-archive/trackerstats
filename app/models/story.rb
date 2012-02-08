class Story < TrackerResource

  self.site = TrackerApi::API_BASE_PATH + "/projects/:project_id"

  def accepted?
    return current_state == "accepted"
  end
end
