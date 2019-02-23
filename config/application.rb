# frozen_string_literal: true

require_relative "environment"

Bundler.require(:default, APP_ENV)

DB = Sequel.connect(ENV.fetch("DATABASE_URL"))

BOT_SCOPE = "bot"

SLACK_CONFIG = {
  slack_client_id:     ENV["SLACK_CLIENT_ID"],
  slack_api_secret:    ENV["SLACK_CLIENT_SECRET"],
  slack_redirect_uri:  ENV["SLACK_REDIRECT_URI"],
}

require "tally"
