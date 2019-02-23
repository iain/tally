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
      puts text.inspect
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
          team,
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
          team,
          text: "#{term.first} lost a point, current total: #{new_total}",
          channel: channel,
        )
      }
      if text.include?("leaderboard")
        board = leaderboard(team)
        send_message(
          team,
          text: board.map { |row| "#{row[:term]}: #{row[:total_score]}" }.join("\n"),
          channel: channel,
        )
      end
    else
      LOGGER.debug "skipping event type #{event_type}"
    end
  end

  def self.leaderboard(team_id)
    DB[:votes].where(team: team_id).select { [ term, sum(score).as(:total_score) ] }.order(:total_score).reverse_order.group(:term).limit(20).to_a
  end

  def self.handle_stats(stats)
    puts "requests: #{stats.request_count}, messages: #{stats.received_message_count}, last-timestamp: #{stats.last_message_received_at}"
  end

  def self.insert_vote(term:, team:, user:, channel:, message_id:, time:, score:)
    DB[:votes].insert(term: term, team: team, user: user, channel: channel, time: time.utc, score: score)
    DB[:votes].where(term: term, team: team).sum(:score)
  end

  def self.send_message(team_id, body)
    team = DB[:teams].where(team_id: team_id).first
    return if team.nil?
    HTTP
      .auth("Bearer #{team[:bot_access_token]}")
      .headers("Content-Type" => "application/json")
      .post("https://slack.com/api/chat.postMessage", body: body.to_json)
  end

end
