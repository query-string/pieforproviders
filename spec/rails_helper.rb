# frozen_string_literal: true

require 'simplecov'
SimpleCov.maximum_coverage_drop 5
unless ENV['COVERAGE'] == 'false'
  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/config/'
    add_filter '/vendor/'
    add_filter '/test/'
    add_filter '/db/'
    add_filter '/log/'
    add_filter '/tmp/'

    add_group 'Blueprints', 'app/blueprints'
    add_group 'Channels', 'app/channels'
    add_group 'Constraints', 'app/constraints'
    add_group 'Controllers', ['app/controllers', 'app/controllers/api/v1']
    add_group 'Jobs', 'app/jobs'
    add_group 'Lib', 'app/lib'
    add_group 'Models', ['app/models', 'app/models/concerns']
    add_group 'Mailers', 'app/mailers'
    add_group 'Policies', 'app/policies'
    add_group 'Services', 'app/services'
    add_group 'Validators', 'app/validators'
    add_group 'Views', 'app/views'
  end
end

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../config/environment', __dir__)
Rails.application.eager_load!

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# require database cleaner at the top level
require 'database_cleaner'

# this allows us to act on the "remote" postgres docker container
DatabaseCleaner.allow_remote_database_url = true

require 'money-rails/test_helpers'
require 'pundit/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Add ActiveJob Test helpers and configure
ActiveJob::Base.queue_adapter = :test

RSpec.configure do |config|
  # add helper methods
  config.include Helpers
  config.extend Helpers
  config.include FactoryBot::Syntax::Methods
  config.include ActiveJob::TestHelper
  config.include Devise::Test::IntegrationHelpers, type: :request

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # start by truncating all the tables, but then use the faster transaction strategy
  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
  config.before do |example|
    DatabaseCleaner.strategy = if example.metadata[:use_truncation]
                                 :truncation
                               else
                                 :transaction
                               end

    DatabaseCleaner.start
  end

  config.append_after { DatabaseCleaner.clean }
end

# configure shoulda matchers to use rspec as the test framework and full matcher libraries for rails
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
