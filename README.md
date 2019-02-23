# Tally

Visit me live at [tally.iain.nl](http://tally.iain.nl).

A simple Slack bot to count things. Made as proof of concept.

Slack's Event API posts off to AWS API Gateway, which points to the lambda
function in `lib/slack_events_to_sns.rb`

This lambda function verifies the request, handles URL verification, and posts
the events to SNS. An SQS queue is subscribed to this topic, from where messages
can be processed in your own tempo.

## Installation

You need the following environment variables, you can put in `.env` in development:

``` bash
AWS_ACCESS_KEY_ID="..."
AWS_SECRET_ACCESS_KEY="..."
AWS_REGION="us-east-1"

# for worker
QUEUE_URL="https://sqs.us-east-1.amazonaws.com/account-id/queue-name"

DATABASE_URL="postgres://localhost:5432/tally"

# for auth web server
SLACK_CLIENT_ID="..."
SLACK_CLIENT_SECRET="..."
SLACK_REDIRECT_URI="..."
```

Make sure you create the database you specified with `DATABASE_URL`.

Run the migrations:

    $ ./bin/migrate

Run the worker:

    $ ./bin/worker

Run the web server:

    $ puma
