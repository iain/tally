# frozen_string_literal: true

module Tally
  class Team

    def self.find(team_id)
      new(DB[:teams].where(team_id: team_id).first!)
    end

    attr_reader :bot_user_id

    def initialize(row)
      @bot_access_token = row[:bot_access_token]
      @bot_user_id      = row[:bot_user_id]
      @team_id          = row[:team_id]
    end

    def bot_name
      "<@#{@bot_user_id}>"
    end

    def post_message(body)
      client.post("https://slack.com/api/chat.postMessage", body: body.to_json)
    end

    private

    def client
      HTTP
        .auth("Bearer #{@bot_access_token}")
        .headers("Content-Type" => "application/json")
    end

  end
end
