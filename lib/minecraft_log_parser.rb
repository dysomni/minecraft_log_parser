# frozen_string_literal: true

require_relative "minecraft_log_parser/version"
require_relative "minecraft_log_parser/constants"
require_relative "minecraft_log_parser/timer"
require_relative "minecraft_log_parser/parser"

# Module for parsing minecraft logs
module MinecraftLogParser
  class Error < StandardError; end

  class << self
    def parse(str)
      response, time = Timer.time { Parser.parse(str) }
      response.merge({
                       parse_duration: time&.secs
                     })
    end
  end
end
