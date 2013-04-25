module Nani
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
