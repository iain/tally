# frozen_string_literal: true

module Tally
  class Worker

    def initialize(query_url: ENV.fetch("QUEUE_URL"), worker_count: Concurrent.processor_count)
      @query_url = query_url
      @worker_count = worker_count
      @stop = false
    end

    def start
      poller = Aws::SQS::QueuePoller.new(@query_url)
      pool = Concurrent::FixedThreadPool.new(@worker_count)

      poller.before_request do |stats|
        Tally.handle_stats(stats)
        throw :stop_polling if @stop
      end

      poller.poll(max_number_of_messages: @worker_count) do |messages|
        messages.each do |message|
          pool.post do
            Raven.capture do
              Tally.handle_message(message)
            end
          end
        end
      end

      pool.shutdown
      pool.wait_for_termination
    end

    def stop
      @stop = true
    end

  end
end
