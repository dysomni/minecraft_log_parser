# frozen_string_literal: true

RSpec.describe "MinecraftLogParser::PARSER_DEFINITION" do # rubocop:disable Metrics/BlockLength
  it "is defined after accessing definition" do
    MinecraftLogParser::Parser.definition
    expect(MinecraftLogParser::PARSER_DEFINITION).to_not be nil
  end

  it "contains root objects for 'base' and 'invalid'" do
    expect(MinecraftLogParser::PARSER_DEFINITION[:base]).to_not be nil
    expect(MinecraftLogParser::PARSER_DEFINITION[:invalid]).to_not be nil
  end

  describe "schema" do # rubocop:disable Metrics/BlockLength
    MinecraftLogParser::Parser.definition
    recurse = lambda { |node, path|
      describe path.join("/").to_s do
        it "is valid" do
          expect(node).to be_a(Hash)
          expect(node[:regex]).to be_a(Regexp).or be_a(Array)
          expect(node[:matches]).to be_a(Array).or be(nil)
          expect(node[:metadata]).to be_a(Hash).or be(nil)
          expect(node[:process_matches]).to be_a(Hash).or be(nil)

          if node[:process_matches].is_a?(Hash)
            expect(node[:process_matches].values).to all(be_a(Hash))
            expect(node[:process_matches].values.map(&:values).flatten).to all(be_a(Hash))
          end
        end

        if node.is_a?(Hash)
          (node[:process_matches] || {}).each do |attribute, tests|
            tests.each do |test_name, sub_node|
              recurse.call(sub_node, [*path, attribute, test_name])
            end
          end
        end
      end
    }

    MinecraftLogParser::PARSER_DEFINITION.each do |key, value|
      recurse.call(value, [key])
    end
  end
end
