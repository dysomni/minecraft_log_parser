# frozen_string_literal: true

RSpec.describe MinecraftLogParser::Parser do # rubocop:disable Metrics/BlockLength
  describe "#user_death_regex" do
    it "returns an array" do
      expect(MinecraftLogParser::Parser.user_death_regex).to be_a(Array)
    end

    it "should have more than one element" do
      expect(MinecraftLogParser::Parser.user_death_regex.length).to be > 0
    end
  end

  describe "#startup_regex" do
    it "returns an array" do
      expect(MinecraftLogParser::Parser.startup_regex).to be_a(Array)
    end

    it "should have more than one element" do
      expect(MinecraftLogParser::Parser.startup_regex.length).to be > 0
    end
  end

  describe "#definition" do
    it "returns the PARSER_DEFINITION constant" do
      expect(MinecraftLogParser::Parser.definition).to eq(MinecraftLogParser::PARSER_DEFINITION)
    end
  end

  describe "#match_regex_or_array_of_regex" do
    it "returns match if not array" do
      response = MinecraftLogParser::Parser.match_regex_or_array_of_regex(".", "anything")
      expect(response).to be_a(MatchData)
    end

    it "returns first of matches if array" do
      response = MinecraftLogParser::Parser.match_regex_or_array_of_regex([".", "."], "anything")
      expect(response).to be_a(MatchData)
    end

    it "returns nil if no matches" do
      response = MinecraftLogParser::Parser.match_regex_or_array_of_regex(%w[x x], "anything")
      expect(response).to be(nil)
    end
  end
end
