require "bunny"
require "celluloid"

module Nani
  VERSION = "0.0.1"

  class Worker
    include Celluloid

    def initialize(connection, queue, n)
      @channel  = connection.create_channel
      @channel.prefetch(1)
      @queue = @channel.queue(queue)
      @n = n
    end

    def call
      @queue.subscribe(block: true, ack: true) do |info, properties, payload|
        $stdout.puts "[#{@n}] Before ack"
        @channel.ack(info.delivery_tag)
        sleep 0.5
        $stdout.puts "[#{@n}] Received: #{payload}"
      end
    end

    def finalize
      @channel.close
      super
      true
    end
    alias_method :terminate, :finalize
  end

  class Consumer
    def initialize(queue, workers = 2, options = {})
      @size = (ENV['POOL'] || workers).to_i
      @connection = Bunny.new(options)
      @connection.start

      @workers = @size.times.map do |n|
        Worker.new(@connection, queue, n)
      end
    end

    def call
      @workers.map { |w| w.call! }
    end

    def close_connection
      futures = @workers.map { |w| w.future(:finalize) }
      @connection.stop if futures.all?
    end
  end

  class Queue
    def initialize(name, options = {})
      @connection = Bunny.new(options)
      @connection.start
      @channel = @connection.create_channel
      @exchange = @channel.direct(name)
    end

    def push(message)
      @exchange.publish(message)
    end

    def close_connection
      @connection.stop
    end
  end
end
