# Gemfile
source 'https://rubygems.org'

ruby '3.1.2'

# web framework
gem 'sinatra'

# http server toolkit, required by sinatra
gem 'webrick'

# database adapter
gem 'sqlite3'

# database connection and ORM
gem 'sinatra-activerecord'
gem 'rake'

group :test do
  # makes http verbs available as testing methods
  gem 'rack-test'

  # main testing tool
  gem 'rspec'
end

group :development, :test do
  # populates tests and seeds with usable data
  gem 'factory_bot'
end