require 'spec_helper'

describe Page do
  before(:each) do 
    Stylesheet.request = FakeRequest.new
  end
  
  describe ".new" do 
    
    it "should initialize url" do
      url = "http://example.com/css/inline.html?foo=bar"
      page = ColorParser::Page.new(url)

      expect(page.url).to eq url
    end
  end

  describe ".colors" do 
    let :page do 
      ColorParser::Page.new("http://example.com/css_color/frequency.html")
    end

    it "should combine colors from external and import styles" do 
      colors = page.colors
    
      expect(colors["386ec0"]).to eq 4
      expect(colors["3a5dc4"]).to eq 3
      expect(colors["718ad7"]).to eq 2
      expect(colors["ff0000"]).to eq 1
      expect(colors["357ad1"]).to eq 1
      expect(colors["535353"]).to eq 1
    end
    
    it "should solot colors by frequency" do 
      colors = ["386ec0", "3a5dc4", "718ad7", "535353", "357ad1", "ff0000"]
      expect(page.colors_by_frequency).to eq colors
    end
  end
end
