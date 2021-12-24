RSpec.describe MinecraftLogParser::Timer do
  it "has a timer attribute" do
    expect(MinecraftLogParser::Timer.timer).not_to be nil
  end

  describe "timer attribute" do
    it "is a proc" do
      expect(MinecraftLogParser::Timer.timer.class).to eq(Proc)
    end

    it "returns a value and time" do
      resp = MinecraftLogParser::Timer.timer.call(-> { "response" })
      expect(resp[0]).to eq("response")
      expect(resp[1]).to be_a(Monotime::Duration).or be(nil)
    end
  end

  it "has a time method" do
    expect(MinecraftLogParser::Timer.methods.include?(:time)).to be true
  end

  describe "time method" do
    it "calls the timer proc" do
      allow(MinecraftLogParser::Timer.timer).to receive(:call)
      this_proc = -> {}
      MinecraftLogParser::Timer.time(&this_proc)
      expect(MinecraftLogParser::Timer.timer).to have_received(:call).with(this_proc)
    end
  end
end
