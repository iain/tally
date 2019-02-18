# frozen_string_literal: true

require "bundler/setup"
Bundler.setup

require "English"
require "pathname"
require "logger"

APP_ROOT = Pathname(File.expand_path("../", __dir__)).freeze
$LOAD_PATH.unshift(APP_ROOT.join("lib").to_s)
Dir.chdir(APP_ROOT)

APP_ENV     = (ENV["APP_ENV"] || "development").to_sym
APP_VERSION = File.exist?("VERSION") ? File.read("VERSION").chomp : "unknown"
LOGGER      = Logger.new($stdout)

require "raven"
Raven.configure do |config|
  config.release             = APP_VERSION
  config.logger              = LOGGER
  config.current_environment = APP_ENV
end
