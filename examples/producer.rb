$:.unshift(File.expand_path("../../lib", __FILE__))
require "nani"

class Job
  def initialize(name)
    @name = name
  end

  def run
    puts @name
  end
end

queue = Nani::Queue.new("jobs_queue")
["one", "two", "three"].each do |name|
  job = Job.new(name)
  queue.push(job)
end
