require 'spec_helper'

describe Stylesheet do
  before(:each) do 
    Stylesheet.request = FakeRequest.new
  end
  
  describe "selector parsing" do 
    let :style do 
      url = "http://example.com/css_color/stylesheets/properties.css"
      css = ::Stylesheet::CssStyleSheet.new(url)
  
      stylesheet = ColorParser::Stylesheet.new(css)
    end
  
    it "should parse rules" do 
      rules = style.rules
  
      expect(rules.size).to eq 4
    
      expect(rules["p"].size).to eq   3
      expect(rules["div"].size).to eq 2
      expect(rules["h1"].size).to eq  3
    
      # imported 
      expect(rules["dl"].size).to eq 1
    end
    
    it "should parse properties" do 
      props = style.properties
  
      expect(props.size).to eq 9
      
      expect(props).to include ["background",       "#000"]
      expect(props).to include ["color",            "#fff"]
      expect(props).to include ["margin",           "0"]
      expect(props).to include ["background-color", "#ccc"]
      expect(props).to include ["font-size",        "100%"]
      expect(props).to include ["border-color",     "rgb(1,2,3)"]
    
      # imported
      expect(props).to include ["border", "1px solid red"]
    end
  end

  describe "color parsing" do 
    let :style do 
      url = "http://example.com/css_color/stylesheets/color_styles.css"
      css = ::Stylesheet::CssStyleSheet.new(url)

      stylesheet = ColorParser::Stylesheet.new(css)
    end
  
    it "should parse hex colors" do 
      expect(style.colors["386ec0"]).to be # 386ec0
    end
  
    it "should parse hex short colors" do 
      expect(style.colors["cc00cc"]).to be # c0c
    end
  
    it "should parse textual colors" do 
      expect(style.colors["008080"]).to be # teal
    end
  
    it "should parse rgb colors" do 
      expect(style.colors["718ad7"]).to be # rgb(113,138,215)
    end
  
    it "should parse rgb colors with space" do 
      expect(style.colors["3a5dc4"]).to be # rgb(58, 93, 196)
    end
  
    it "should parse rgba colors" do 
      expect(style.colors["29469e"]).to be # rgba(41,70,158,0.5);
    end
  
    it "should parse rgba colors with space" do 
      expect(style.colors["3f6aeb"]).to be # rgba(63, 106, 235, 0.5);
    end
  end
  
  describe "color weighting" do 
    let :style do 
      url = "http://example.com/css_color/stylesheets/frequency.css"
      css = ::Stylesheet::CssStyleSheet.new(url)

      stylesheet = ColorParser::Stylesheet.new(css)
    end
  
    it "should order colors by frequency" do 
      colors = {"386ec0" => 4, "3a5dc4" => 3, 
                "718ad7" => 2, "ff0000" => 1}
      expect(style.colors).to eq colors
    end
  
    # BG colors
    it "should order background colors by frequency" do 
      colors = {"386ec0" => 2, "3a5dc4" => 1}
      expect(style.bg_colors).to eq colors
    end
  
    # Text colors
    it "should order text colors by frequency" do 
      colors = {"386ec0" => 2, "718ad7" => 1}
      expect(style.text_colors).to eq colors
    end
  
    # Border colors
    it "should order border colors by frequency" do 
      colors = {"3a5dc4" => 2, "ff0000" => 1, "718ad7" => 1}
      expect(style.border_colors).to eq colors
    end
  end

end
