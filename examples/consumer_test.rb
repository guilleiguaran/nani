$:.unshift(File.expand_path("../../lib", __FILE__))
require "nani"

class Job
  def initialize(name)
    @name = name
  end

  def run
    sleep 2
    puts @name
  end
end

Celluloid.logger = Logger.new('logfile.log')

n = 4
consumer = Nani::Consumer.new("jobs_queue", n)
puts "Starting consumer with queue 'jobs_queue' and #{n} workers"

consumer.start
Signal.trap('INT') { consumer.close_connection }
