require_relative "test_helper"

describe Color do
  it "must have textual colors" do
    text_colors = ColorParser::Color.text_colors
    text_colors[:black].must_equal "000000"
  end
end
