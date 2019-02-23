# frozen_string_literal: true

source "https://rubygems.org"

ruby ">= 2.5.3"

gem "aws-sdk-sqs"
gem "concurrent-ruby"
gem "sequel"
gem "pg"
gem "http"

gem "slack-ruby-client"

gem "sinatra",  require: false
gem "puma",     require: false
gem "slim",     require: false

gem "rake", require: false
gem "sentry-raven"

group :development, :test do
  gem "dotenv", require: "dotenv/load"
  gem "rerun"
  gem "rspec"
  gem "dalziel"
  gem "better_errors"
  gem "binding_of_caller"
end
