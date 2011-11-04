require 'spork'

Spork.prefork do

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'

  
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}
  
  RSpec.configure do |config|
    # == Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr
    config.mock_with :rspec
  
    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"
  
    def test_activate_user(user)
      if !user.activated?
        user.activate!
      end
    end
  
    def test_sign_in(user)
      test_activate_user(user)
      controller.sign_in(user)
    end
    
    def test_web_sign_in(user)
      test_activate_user(user)
      visit signin_path
      fill_in "Email",    :with => user.email
      fill_in "Password", :with => user.password
      click_button "Sign in"
      return user
    end
  
    def create_privacies
      Privacy.create!(:name => "public")
      Privacy.create!(:name => "private")
    end
    
    def create_community_user
      community_user = User.create!(:name => "community", :email => "community@remindmetolive.com", :password => "thesercretpassword123")
      # we don't let anyone to sign in as the community user
      community_user.block!
    end
    
    def future_date
      Time.now.next_year.strftime("%d/%m/%Y")
    end
    
    def puts_validation_errors(model)
      if not model.valid?
        model.errors.full_messages.each do |error|
          puts error
        end
      end
    end
    
    def puts_backtrace(exception)
      exception.backtrace.join("\n")
    end
    
    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true
    config.use_transactional_fixtures = true
  
    config.before :each do
      if Capybara.current_driver == :rack_test
        DatabaseCleaner.strategy = :transaction
      else
        DatabaseCleaner.strategy = :truncation
      end
      DatabaseCleaner.start
    end
  
    config.after(:each) do
      DatabaseCleaner.clean
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.
  FactoryGirl.reload
end