# frozen_string_literal: true

RSpec.describe MinecraftLogParser do
  it "has a version number" do
    expect(MinecraftLogParser::VERSION).not_to be nil
  end
end
