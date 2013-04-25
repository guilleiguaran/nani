require "celluloid/autostart"
module Nani
  Work = Struct.new(:info, :properties, :payload)
  FinishedWork = Struct.new(:worker, :tag)

  class Consumer
    def initialize(queue, workers = 2, options = {})
      @size = (ENV['POOL'] || workers).to_i
      @connection = Bunny.new(options)
      @connection.start
      @channel = @connection.create_channel
      @channel.prefetch(1)
      @queue = @channel.queue(queue)
      super()
    end

    def start
      @queue.subscribe(block: true, ack: true) do |info, properties, payload|
        begin
          work = Work.new(info, properties, payload)
          workers_pool.future.process(work)
          @channel.ack(info.delivery_tag, false)
        rescue => err
          $stderr.puts(err.message)
        end
      end
    end

    def close_connection
      @connection.stop
    end

    def workers_pool
      Worker.pool(size: @size)
    end
  end
end
