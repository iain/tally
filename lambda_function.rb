# frozen_string_literal: true

require "json"
require "aws-sdk-sns"
require "openssl"

SNS = Aws::SNS::Client.new

def lambda_handler(event:, context:)
  if verify_signature(event)
    body = JSON.parse(event["body"])
    if body["type"] == "url_verification"
      { statusCode: 200, body: body["challenge"], headers: { "Content-Type" => "text/plain" } }
    else
      SNS.publish(topic_arn: ENV["TOPIC_ARN"], message: event["body"])
      { statusCode: 200 }
    end
  else
    { statusCode: 400, body: "invalid signature" }
  end
end

def verify_signature(event)
  timestamp = event.dig("headers", "X-Slack-Request-Timestamp")
  return false if Integer(timestamp) < (Time.now.to_i - 300)
  data = "v0:" + timestamp + ":" + event["body"]
  hash = "v0=" + OpenSSL::HMAC.hexdigest("SHA256", ENV["SLACK_SIGNING_SECRET"], data)
  hash == event.dig("headers", "X-Slack-Signature")
rescue StandardError
  false
end
