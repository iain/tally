# frozen_string_literal: true

require "tally/worker"
require "tally/team"
require "tally/message"

module Tally

  def self.handle_message(message)
    data = JSON.parse(message.body)
    LOGGER.debug("Handling message: #{message.body}")

    event_type = data.dig("event", "type")

    case event_type
    when "message"
      Message.new(data).call
    else
      LOGGER.debug "skipping event type #{event_type}"
    end
  end

  def self.handle_stats(stats)
    puts "requests: #{stats.request_count}, messages: #{stats.received_message_count}, last-timestamp: #{stats.last_message_received_at}"
  end

end
