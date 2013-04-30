require 'spec_helper'

describe Image do
  before(:each) do 
    ColorParser.request = FakeRequest.new
  end
  
  describe "" do 
    it "should assign url" do
      image = ColorParser::Image.new("http://example.com/foo/bar.png")
    
      expect(image.url).to eq "http://example.com/foo/bar.png"
    end
  end
  
  describe "" do 
    it "should parse host path and query from url" do 
      image = ColorParser::Image.new("http://example.com/foo/bar.png?baz=bar")

      expect(image.host).to eq  "example.com"
      expect(image.path).to eq  "/foo/bar.png"
      expect(image.query).to eq "baz=bar"
    end
  end

  describe "" do 
    it "should parse name" do 
      image = ColorParser::Image.new("http://example.com/foo/bar.png?baz=bar")

      expect("bar.png").to eq image.name
    end
  end
end
