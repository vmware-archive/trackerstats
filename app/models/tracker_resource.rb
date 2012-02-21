class TrackerResource < ActiveResource::Base
  CACHE_EXPIRY = 30.minutes

  self.format = :xml

  class << self
    def init_session(api_token, session_cache_key)
      @@api_token = api_token
      @@session_cache_key = session_cache_key
    end

    def headers
      TrackerApi.default_headers(@@api_token)
    end

    def find(*arguments)
      cache_key = "#{self.name}-#{@@session_cache_key}-#{arguments}"
      Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRY) do
        super(*arguments)
      end.try(:dup)
    end
  end
end
