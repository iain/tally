# frozen_string_literal: true

module Tally
  class Message

    def initialize(data)
      @team_id    = data.dig("team_id")
      @channel    = data.dig("event", "channel")
      @event_type = data.dig("event", "type")
      @message_id = data.dig("event", "client_msg_id")
      @text       = data.dig("event", "text")
      @user       = data.dig("event", "user")
      @time       = Time.at(Float(data.dig("event", "event_ts")))
      @team       = Team.find(@team_id)
    end

    def call
      return if @user == @team.bot_user_id # never respond to self
      @text.scan(/(\S+)\s?\+\+/) do |(term)|
        insert_vote(term, 1)
        new_total = score(term)
        post_message("#{term} gained a point, the new score is `#{new_total}`")
      end
      @text.scan(/(\S+)\s?\-\-/) do |(term)|
        insert_vote(term, -1)
        new_total = score(term)
        post_message("#{term} lost a point, the new score is `#{new_total}`")
      end
      @text.scan(/#{@team.bot_name} leaderboard\b/) do
        message = leaderboard.map { |row| "#{row[:term]}: `#{row[:total_score]}`" }.join("\n")
        post_message(message)
      end
      @text.scan(/#{@team.bot_name} help\b/) do
        post_message("I'm just a poor bot, though my story's seldom told.")
      end
    end

    def leaderboard
      DB[:votes].where(team: @team_id).select { [ term, sum(score).as(:total_score) ] }.order(:total_score).reverse_order.group(:term).limit(20).to_a
    end

    def insert_vote(term, score)
      DB[:votes].insert(term: term, team: @team_id, user: @user, channel: @channel, time: @time.utc, score: score)
    end

    def score(term)
      DB[:votes].where(term: term, team: @team_id).sum(:score)
    end

    def post_message(text)
      @team.post_message(text: text, channel: @channel)
    end

  end
end
