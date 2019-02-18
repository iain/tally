# frozen_string_literal: true

require "tally/worker"

module Tally

  def self.handle_message(message)
    data = JSON.parse(message.body)

    team       = data.dig("team_id")
    channel    = data.dig("event", "channel")
    event_type = data.dig("event", "type")
    user       = data.dig("event", "user")
    message_id = data.dig("event", "client_msg_id")
    time       = Time.at(Float(data.dig("event", "event_ts")))

    case event_type
    when "message"
      text = data.dig("event", "text")
      text.scan(/(\S+)\s?\+\+/).each { |term|
        new_total = insert_vote(
          term:        term.first,
          team:        team,
          user:        user,
          channel:     channel,
          message_id:  message_id,
          time:        time,
          score:       1,
        )
        send_message(
          text: "#{term.first} got a point, current total: #{new_total}",
          channel: channel,
        )
      }
      text.scan(/(\S+)\s?\-\-/).each { |term|
        new_total = insert_vote(
          term:        term.first,
          team:        team,
          user:        user,
          channel:     channel,
          message_id:  message_id,
          time:        time,
          score:       -1,
        )
        send_message(
          text: "#{term.first} lost a point, current total: #{new_total}",
          channel: channel,
        )
      }
    else
      LOGGER.debug "skipping event type #{event_type}"
    end
  end

  def self.handle_stats(stats)
    puts "requests: #{stats.request_count}, messages: #{stats.received_message_count}, last-timestamp: #{stats.last_message_received_at}"
  end

  def self.insert_vote(term:, team:, user:, channel:, message_id:, time:, score:)
    DB[:votes].insert(term: term, team: team, user: user, channel: channel, time: time.utc, score: score)
    DB[:votes].where(term: term, team: team).sum(:score)
  end

  def self.send_message(body)
    HTTP
      .auth("Bearer #{ENV.fetch("BOT_USER_OAUTH_ACCESS_TOKEN")}")
      .headers("Content-Type" => "application/json")
      .post("https://slack.com/api/chat.postMessage", body: body.to_json)
  end

end
