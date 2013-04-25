module Nani
  class Worker
    include Celluloid

    def initialize(supervisor)
      @supervisor = supervisor
      async.wait_for_work
    end

    def wait_for_work
      loop do
        work = receive { |msg| msg.is_a? Work }
        job = Marshal.load(JSON.parse(work.payload)['job'])
        job.run
        puts "Got a work: #{work.inspect}"
      end
    end

  end
end
