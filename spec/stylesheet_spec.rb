require 'spec_helper'

describe Stylesheet do
  before(:each) do 
    ColorParser.request = FakeRequest.new
  end
  
  describe "#new" do 
    it "must initialize params" do
      sheet = ColorParser::Stylesheet.new(text: "a { background: #fff; }", 
                                          type: "inline",
                                          url:  "http://example.com/css/inline.html?foo=bar")
      expect(sheet.type).to eq  "inline"
      expect(sheet.text).to eq  "a { background: #fff; }"
      expect(sheet.url).to eq   "http://example.com/css/inline.html?foo=bar"
      expect(sheet.host).to eq  "example.com"
      expect(sheet.path).to eq  "/css/inline.html"
      expect(sheet.query).to eq "foo=bar"
    end
  end

  describe "import quoting" do 
    let :style do 
      ColorParser::Stylesheet.new(text: fixture("/css_import/stylesheets/screen.css"), 
                                  url: "http://example.com/css_import/stylesheets/screen.css")
    end

    it "should import stylesheets with double quotes" do 
      imported = style.stylesheets[0]
      expect(imported.name).to eq "master.css"
      expect(imported.text).to include "a:link"
    end
    
    it "should import stylesheets with single quotes" do     
      imported = style.stylesheets[1]
      expect(imported.name).to eq "fonts.css"
      expect(imported.text).to include "font-family"
    end
    
    it "should import stylesheets with no quotes" do 
      imported = style.stylesheets[2]
      expect(imported.name).to eq "ie.css"
      expect(imported.text).to include "background-color"
    end
  end

  describe "import paths" do 
    let :style do 
      ColorParser::Stylesheet.new(text: fixture("/css_import/stylesheets/screen.css"), 
                                  url: "http://example.com/css_import/stylesheets/screen.css")
    end

    it "should import from relative path" do 
      imported = style.stylesheets[0]
      expect(imported.url).to eq "http://example.com/css_import/stylesheets/master.css"
    end
  
    it "should import from relative root path" do   
      imported = style.stylesheets[1]
      expect(imported.url).to eq "http://example.com/css_import/stylesheets/fonts.css"
    end
  
    it "should import from absolute path" do 
      imported = style.stylesheets[2]
      expect(imported.url).to eq "http://example.com/css_import/stylesheets/ie.css"
    end

    it "should not fail on invalid import path" do 
      expect(style.stylesheets[6]).to be_nil
    end
  end

  describe "selector parsing" do 
    let :style do 
      ColorParser::Stylesheet.new(text: fixture("/css_color/stylesheets/properties.css"), 
                                  url: "http://example.com/css_color/stylesheets/properties.css")
    end

    it "should parse selectors" do 
      selectors = style.selectors
      
      expect(selectors.size).to eq 4
    
      expect(selectors["p"].size).to eq   2
      expect(selectors["div"].size).to eq 1
      expect(selectors["h1"].size).to eq  2
    
      # imported 
      expect(selectors["dl"].size).to eq 1
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
      ColorParser::Stylesheet.new(text: fixture("/css_color/stylesheets/color_styles.css"), 
                                  url: "http://example.com/css_color/stylesheets/color_styles.css")
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
      ColorParser::Stylesheet.new(text: fixture("/css_color/stylesheets/frequency.css"), 
                                  url: "http://example.com/css_color/stylesheets/frequency.css")
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

  describe "image parsing" do 
    let :style do 
      ColorParser::Stylesheet.new(text: fixture("/css_images/stylesheets/quotes.css"), 
                                  url: "http://example.com/css_images/stylesheets/quotes.css")
    end

    it "should parse images with double quotes" do 
      expect(style.images[0].name).to eq "apple.png"
    end

    it "should parse images with single quotes" do 
      expect(style.images[1].name).to eq "kiwi.jpg"
    end

    it "should parse images with no quotes" do 
      expect(style.images[2].name).to eq "cantaloupe.png"
    end
  end

  describe "image paths" do 
    let :style do 
      ColorParser::Stylesheet.new(text: fixture("/css_images/stylesheets/paths.css"), 
                                  url: "http://example.com/css_images/stylesheets/paths.css")
    end

    it "should build image from absolute path" do 
      urls = style.images.map {|image| image.url }

      expect(urls.size).to eq 4
      expect(urls).to include "http://example.com/css_images/images/apple.png"
    end

    it "should build image from relative path" do 
      urls = style.images.map {|image| image.url }

      expect(urls.size).to eq 4
      expect(urls).to include "http://example.com/css_images/images/kiwi.jpg"
    end

    it "should build image from relative root path" do 
      urls = style.images.map {|image| image.url }

      expect(urls.size).to eq 4
      expect(urls).to include "http://example.com/css_images/images/cantaloupe.png"
    end

    it "should build image from imported path" do 
      urls = style.images.map {|image| image.url }

      expect(urls.size).to eq 4
      expect(urls).to include "http://example.com/css_images/images/pineapple.png"
    end
  end
end

private 

def fixture(path)
  fixture = "#{File.dirname(__FILE__)}/../spec/fixtures#{path}"
  File.read(fixture) if File.exist?(fixture)
end
