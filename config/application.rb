# frozen_string_literal: true

require_relative "environment"

Bundler.require(:default, APP_ENV)

DB = Sequel.connect(ENV.fetch("DATABASE_URL"))

require "tally"
