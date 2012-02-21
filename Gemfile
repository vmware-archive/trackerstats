source 'http://rubygems.org'

gem 'rails'           , '3.2.1'
gem 'haml'            , '>= 3.1.4'
gem 'jquery-rails'    , '>= 1.0.19'
gem 'jquery-ui-themes' ,'>= 0.0.4'
gem 'rest-client'     , '>= 1.6.7'

gem 'google_visualr'  , '>= 2.1.0'
gem 'nokogiri'        , '>= 1.3.3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'    , '>= 3.2.3'
  gem 'uglifier'      , '>= 1.1.0'
end

group :development do
  gem 'heroku'         , '>= 2.9.0'
  gem 'pivotal_git_scripts'
  gem 'awesome_print'
end

group :test do
  # Pretty printed test output
  gem 'turn', :require => false
  gem 'capybara', '>= 1.1.2'
  gem "webmock", "~> 1.7.10"
end

group :test, :development do
  gem 'rspec-rails', '>= 2.8.1'
  gem 'evergreen', require: 'evergreen/rails'
  gem 'ruby-debug19'
  gem 'factory_girl_rails'
  gem 'timecop'
end
