require "bunny"
require "celluloid"
require "json"

module Nani
  class Worker
    include Celluloid

    finalizer :close_channel

    def initialize(connection, queue)
      @channel = connection.create_channel
      @queue = @channel.queue(queue)
    end

    def call
      @queue.subscribe(block: true, ack: true) do |info, properties, payload|
        begin
          job = Marshal.load(JSON.parse(payload)['job'])
          puts job.run
        rescue => err
          $stderr.puts(err.message)
        end
        @channel.ack(info.delivery_tag, false)
      end
    end

    def close_channel
      @channel.close
    end
    alias_method :terminate, :close_channel
  end

  class Consumer
    def initialize(queue, workers = 2, options = {})
      @size = (ENV['POOL'] || workers).to_i
      @connection = Bunny.new(options)
      @connection.start

      @workers = @size.times.map do
        Worker.new(@connection, queue)
      end
    end

    def start
      @workers.map { |w| w.async.call }
    end

    def close_connection
      futures = @workers.map { |w| w.future(:finalize) }
      @connection.stop if futures.all?
    end
  end

  class Queue
    attr_reader :name

    def initialize(name, options = {})
      @name = name
      @connection = Bunny.new(options)
      @connection.start
      @queue = @connection.queue(@name)
    end

    def push(job, opts = {})
      @queue.publish({'job' => Marshal.dump(job)}.to_json, opts.merge({ content_type: "application/json" }))
    end

    def close_connection
      @connection.stop
    end
  end
end
