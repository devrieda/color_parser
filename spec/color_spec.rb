require 'spec_helper'

describe Color do
  describe ".text_colors" do 
    it "must have textual colors" do
      text_colors = ColorParser::Color.text_colors
      expect(text_colors[:black]).to eq "000000"
    end
  end
end
