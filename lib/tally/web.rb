# frozen_string_literal: true

require "sinatra/base"
require "slim"

class Tally::Web < Sinatra::Base

  configure do
    set :views, APP_ROOT.join("app/views")
    disable :logging
    disable :dump_errors
    set :public_folder, APP_ROOT.join("dist")
  end

  configure :development do
    BetterErrors.application_root = APP_ROOT.to_s
    use BetterErrors::Middleware
    use Raven::Rack
  end

  configure :test do
    enable :raise_errors
    enable :dump_errors
  end

  configure :production do
    disable :show_exceptions
  end

  get "/" do
    slim :index
  end

  # OAuth Step 2: The user has told Slack that they want to authorize our app to use their account, so
  # Slack sends us a code which we can use to request a token for the user's account.
  get "/finish_auth" do
    client = Slack::Web::Client.new
    # OAuth Step 3: Success or failure
    response = client.oauth_access(
      client_id:      SLACK_CONFIG[:slack_client_id],
      client_secret:  SLACK_CONFIG[:slack_api_secret],
      redirect_uri:   SLACK_CONFIG[:slack_redirect_uri],
      code:           params[:code],
    )
    # Success:
    # Yay! Auth succeeded! Let's store the tokens and create a Slack client to use in our Events handlers.
    # The tokens we receive are used for accessing the Web API, but this process also creates the Team's bot user and
    # authorizes the app to access the Team's Events.
    team_id = response["team_id"]

    DB[:teams].insert(
      team_id:            team_id,
      user_access_token:  response["access_token"],
      bot_user_id:        response["bot"]["bot_user_id"],
      bot_access_token:   response["bot"]["bot_access_token"],
    )

    # $teams[team_id]["client"] = create_slack_client(response["bot"]["bot_access_token"])
    # Be sure to let the user know that auth succeeded.
    redirect "/thanks"
  rescue Slack::Web::Api::Error => error
    # Failure:
    # D'oh! Let the user know that something went wrong and output the error message returned by the Slack client.
    status 403
    @error = error
    slim :error
  end

  get "/thanks" do
    slim :thanks
  end

end
