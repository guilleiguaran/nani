module Nani
  Work = Struct.new(:info, :properties, :payload)
  FinishedWork = Struct.new(:worker, :tag)

  class Consumer
    include Celluloid

    def initialize(queue, workers = 2, options = {})
      @size = (ENV['POOL'] || workers).to_i
      @connection = Bunny.new(options)
      @connection.start
      @channel = @connection.create_channel
      @channel.prefetch(1)
      @queue = @channel.queue(queue)

      @inactive_workers = @size.times.map do
        Worker.new
      end
      @inactive_workers = []
    end

    def start
      @queue.subscribe(block: true, ack: true) do |info, properties, payload|
        begin
          worker = @inactive_workers.pop
          worker.mailbox << Work.new(info, properties, payload)
          @active_workers.push(worker)
        rescue => err
          $stderr.puts(err.message)
        end
      end
    end

    def close_connection
      @connection.stop
    end

    def wait_for_finished_work
      loop do
        work = receive { |msg| msg.is_a? FinishedWork }
        @active_workers.delete(work.worker)
        @inactive_workers.push(work.worker)
        @channel.ack(work.tag, false)
      end
    end

  end
end
