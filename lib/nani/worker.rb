require "celluloid/autostart"
module Nani
  class Worker
    include Celluloid

    def process(work)
      job = Marshal.load(JSON.parse(work.payload)['job'])
      job.run
    end
  end
end
