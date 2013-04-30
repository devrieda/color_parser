require 'spec_helper'

describe VERSION do 
  describe "version" do 
    it "should be present" do 
      expect(ColorParser::VERSION).not_to be_nil
    end
  end
end