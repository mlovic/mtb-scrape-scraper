source 'https://rubygems.org'

gem 'activerecord'
gem 'chronic'
gem 'mechanize'
gem 'sqlite3'

group :production do
  gem 'unicorn'
  gem 'pg'
end

group :test, :development do
  gem 'thin'
  gem 'rspec'

  gem 'vcr'
  gem 'webmock'
  gem 'database_cleaner'
  gem 'guard-rspec'
  gem 'factory_girl'
  gem 'guard-rake'
  gem 'timecop'
end

