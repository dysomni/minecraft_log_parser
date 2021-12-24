module MinecraftLogParser
  class Timer
    class << self
      attr_accessor :timer

      def time(&block)
        timer.call(block)
      end
    end
  end
end

begin
  exists = Monotime::Duration rescue nil
  require "monotime" unless exists
  MinecraftLogParser::Timer.timer = ->(to_time) { Monotime::Duration.with_measure(&to_time) }
rescue LoadError
  puts "unable to load monotime, include this in your gemfile to track timing of minecraft_log_parser's speed"
  MinecraftLogParser::Timer.timer = ->(to_time) { return to_time.call, nil }
end
