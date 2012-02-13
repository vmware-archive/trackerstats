class Story < TrackerResource
  FEATURE = 'feature'
  BUG = 'bug'
  CHORE = 'chore'

  ALL_STORY_TYPES = [
    FEATURE,
    BUG,
    CHORE
  ]

  self.site = TrackerApi::API_BASE_PATH + "/projects/:project_id"

  def self.filter_stories(stories)
    stories.select {|s| ALL_STORY_TYPES.include? s.story_type }
  end

  def accepted?
    return current_state == "accepted"
  end


end
