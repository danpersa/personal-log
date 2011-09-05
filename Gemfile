source 'http://rubygems.org'

gem "rails", "3.1.0"
gem 'jquery-rails'
gem 'gravatar_image_tag'
gem "will_paginate", "~> 3.0.pre2"
gem "transitions", :require => ["transitions", "active_record/transitions"]
gem 'table_builder', '0.0.3', :git => 'https://github.com/jchunky/table_builder.git'

gem "rake", "0.8.7"
gem 'faker'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
# gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:

group :development do
  gem 'mysql2'
  gem 'rspec-rails'
  gem "ruby-debug19"
#  sudo gem install ruby-debug19 -- --with-ruby-include=/usr/include/ruby-1.9.1
#  gem 'annotate-models'
end

group :production do
  gem 'pg'
end

group :test do
  gem 'mysql2'
  gem 'rspec'
  #gem 'webrat'
  gem 'factory_girl_rails'
  gem 'spork', '~> 0.9.0.rc'
  
  gem 'capybara', :git => 'https://github.com/jnicklas/capybara.git'
  gem 'launchy'
  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem "guard-rspec"
  gem "libnotify"
  gem "rb-inotify"
end
