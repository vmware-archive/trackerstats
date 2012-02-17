class TrackerResource < ActiveResource::Base
  self.format = :xml

  def self.headers
    { 'X-TrackerToken' => TrackerApi.token }
  end

  def self.find(*arguments)
    cache_key = "#{self.name}-#{TrackerApi.token},#{arguments}"
    Rails.cache.fetch(cache_key) do
      super(*arguments)
    end.try(:dup)
  end
end
