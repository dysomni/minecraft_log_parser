# frozen_string_literal: true

module MinecraftLogParser
  # responsible for parsing out a minecraft log object from a log string
  class Parser
    class << self
      def parse(str)
        definition.select do |_test_name, node|
          x = rec_parse(node, str)
          break x if x
        end
      end

      def rec_parse(node, str)
        regex = node[:regex] || /./
        matches = node[:matches] || []
        metadata = node[:metadata] || {}
        process_matches = node[:process_matches] || {}
        regex_response = match_regex_or_array_of_regex(regex, str)
        return unless regex_response

        obj = matches.zip(regex_response.captures).to_h
        obj.merge!(metadata)
        process_matches_iter(obj, process_matches)
      end

      def match_regex_or_array_of_regex(regex, str)
        return regex.map { |r| str.match(r) }.compact.first if regex.is_a?(Array)

        str.match(regex)
      end

      def process_matches_iter(obj, process_matches)
        process_matches.map do |attribute, tests|
          tests.select do |_test_name, sub_node|
            x = rec_parse(sub_node, obj[attribute])
            break x if x
          end
        end.compact.reduce(obj, &:merge!)
      end

      def definition
        @definition ||= begin
          # lazy load the definition until we need it
          require_relative "./parser_definition"
          PARSER_DEFINITION
        end
      end

      def user_death_regex
        @user_death_regex ||= begin
          path = File.join(__dir__, "store", "user_death_regex.txt")
          lines = File.read(path).gsub("####", USER_NAME_REGEX).split("\n")
          lines.map { |line| Regexp.new(line) }
        end
      end

      def startup_regex
        @startup_regex ||= begin
          path = File.join(__dir__, "store", "startup_regex.txt")
          lines = File.read(path).split("\n")
          lines.map { |line| Regexp.new(line) }
        end
      end
    end
  end
end
