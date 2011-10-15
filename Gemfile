source 'http://rubygems.org'

gem "rails", "3.1.1"
gem 'jquery-rails'
gem 'gravatar_image_tag'
gem "kaminari"
gem "transitions", :require => ["transitions", "active_record/transitions"]
gem 'table_builder', '0.0.3', :git => 'https://github.com/jchunky/table_builder.git'

gem "rake"

# to remove
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
  gem 'sass-rails', "  ~> 3.1.4"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'uglifier'
end

group :development, :test do
  gem 'mysql2'
  gem 'execjs'
  gem 'therubyracer'
end

group :development do
  gem 'rspec-rails'
  #  sudo gem install ruby-debug19 -- --with-ruby-include=/usr/include/ruby-1.9.1
  gem "ruby-debug19" unless ENV["CI"]
#  gem 'annotate-models'
end

group :production do
  gem 'pg'
end

group :test do
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
