require_relative "test_helper"

describe VERSION do
  it "must be defined" do
    ColorParser::VERSION.wont_be_nil
  end
end
