require_relative "test_helper"

describe Stylesheet do
  def setup
    ColorParser.request = ColorParser::TestRequest.new
  end

  it "must initialize params" do
    sheet = ColorParser::Stylesheet.new(text: "a { background: #fff; }", 
                                        type: "inline",
                                        url:  "http://example.com/css/inline.html?foo=bar")
    sheet.type.must_equal "inline"
    sheet.text.must_equal "a { background: #fff; }"
    sheet.url.must_equal  "http://example.com/css/inline.html?foo=bar"
    sheet.host.must_equal  "example.com"
    sheet.path.must_equal  "/css/inline.html"
    sheet.query.must_equal "foo=bar"
  end


  # Import Quoting
  
  it "should import stylesheets with double quotes" do 
    css = style("/css_import/stylesheets/screen.css")
  
    imported = css.stylesheets[0]
    imported.name.must_equal "master.css"
    imported.text.must_include "a:link"
  end
  
  it "should import stylesheets with single quotes" do 
    css = style("/css_import/stylesheets/screen.css")
  
    imported = css.stylesheets[1]
    imported.name.must_equal "fonts.css"
    imported.text.must_include "font-family"
  end

  it "should import stylesheets with no quotes" do 
    css = style("/css_import/stylesheets/screen.css")
  
    imported = css.stylesheets[2]
    imported.name.must_equal "ie.css"
    imported.text.must_include "background-color"
  end


  # Import Paths
  
  it "should import from relative path" do 
    css = style("/css_import/stylesheets/screen.css")
  
    imported = css.stylesheets[0]
    imported.url.must_equal "http://example.com/css_import/stylesheets/master.css"
  end
  
  it "should import from relative root path" do 
    css = style("/css_import/stylesheets/screen.css")
  
    imported = css.stylesheets[1]
    imported.url.must_equal "http://example.com/css_import/stylesheets/fonts.css"
  end
  
  it "should import from absolute path" do 
    css = style("/css_import/stylesheets/screen.css")
  
    imported = css.stylesheets[2]
    imported.url.must_equal "http://example.com/css_import/stylesheets/ie.css"
  end

  it "should not fail on invalid import path" do 
    css = style("/css_import/stylesheets/screen.css")
    css.stylesheets[6].must_be_nil
  end


  # Selector parsing

  it "should parse selectors" do 
    css = style("/css_color/stylesheets/properties.css")
    selectors = css.selectors
    
    selectors.size.must_equal 4
  
    selectors["p"].size.must_equal   2
    selectors["div"].size.must_equal 1
    selectors["h1"].size.must_equal  2
  
    # imported 
    selectors["dl"].size.must_equal 1
  end

  it "should parse properties" do 
    css = style("/css_color/stylesheets/properties.css")
    props = css.properties
    
    props.size.must_equal 9
    
    props.must_include ["background",       "#000"]
    props.must_include ["color",            "#fff"]
    props.must_include ["margin",           "0"]
    props.must_include ["background-color", "#ccc"]
    props.must_include ["font-size",        "100%"]
    props.must_include ["border-color",     "rgb(1,2,3)"]
  
    # imported
    props.must_include ["border", "1px solid red"]
  end


  # Color Parsing

  it "should parse hex colors" do 
    css = style("/css_color/stylesheets/color_styles.css")
  
    css.colors["386ec0"].wont_be_nil # 386ec0
  end

  it "should parse hex short colors" do 
    css = style("/css_color/stylesheets/color_styles.css")
  
    css.colors["cc00cc"].wont_be_nil # c0c
  end

  it "should parse textual colors" do 
    css = style("/css_color/stylesheets/color_styles.css")
  
    css.colors["008080"].wont_be_nil # teal
  end
  
  it "should parse rgb colors" do 
    css = style("/css_color/stylesheets/color_styles.css")
  
    css.colors["718ad7"].wont_be_nil # rgb(113,138,215)
  end

  it "should parse rgb colors with space" do 
    css = style("/css_color/stylesheets/color_styles.css")
  
    css.colors["3a5dc4"].wont_be_nil # rgb(58, 93, 196)
  end

  it "should parse rgba colors" do 
    css = style("/css_color/stylesheets/color_styles.css")
  
    css.colors["29469e"].wont_be_nil # rgba(41,70,158,0.5);
  end
  
  it "should parse rgba colors with space" do 
    css = style("/css_color/stylesheets/color_styles.css")
  
    css.colors["3f6aeb"].wont_be_nil # rgba(63, 106, 235, 0.5);
  end


  # Color weighting
  
  it "should order colors by frequency" do 
    css = style("/css_color/stylesheets/frequency.css")
  
    colors = {"386ec0" => 4, "3a5dc4" => 3, 
              "718ad7" => 2, "ff0000" => 1}
    css.colors.must_equal colors
  end
  
  # BG colors
  it "should order background colors by frequency" do 
    css = style("/css_color/stylesheets/frequency.css")
    
    colors = {"386ec0" => 2, "3a5dc4" => 1}
    css.bg_colors.must_equal colors
  end
  
  # Text colors
  it "should order text colors by frequency" do 
    css = style("/css_color/stylesheets/frequency.css")
    
    colors = {"386ec0" => 2, "718ad7" => 1}
    css.text_colors.must_equal colors
  end
  
  # Border colors
  it "should order border colors by frequency" do 
    css = style("/css_color/stylesheets/frequency.css")
    
    colors = {"3a5dc4" => 2, "ff0000" => 1, "718ad7" => 1}
    css.border_colors.must_equal colors
  end


  # Images Parsing
  
  it "should parse images with double quotes" do 
    css = style("/css_images/stylesheets/quotes.css")
  
    css.images[0].name.must_equal "apple.png"
  end
  
  it "should parse images with single quotes" do 
    css = style("/css_images/stylesheets/quotes.css")
  
    css.images[1].name.must_equal "kiwi.jpg"
  end

  it "should parse images with no quotes" do 
    css = style("/css_images/stylesheets/quotes.css")
  
    css.images[2].name.must_equal "cantaloupe.png"
  end


  # Image paths

  it "should build image from absolute path" do 
    css = style("/css_images/stylesheets/paths.css")
    urls = css.images.map {|image| image.url }
    
    urls.size.must_equal 4
    urls.must_include "http://example.com/css_images/images/apple.png"
  end
  
  it "should build image from relative path" do 
    css = style("/css_images/stylesheets/paths.css")
    urls = css.images.map {|image| image.url }
  
    urls.size.must_equal 4
    urls.must_include "http://example.com/css_images/images/kiwi.jpg"
  end

  it "should build image from relative root path" do 
    css = style("/css_images/stylesheets/paths.css")
    urls = css.images.map {|image| image.url }
  
    urls.size.must_equal 4
    urls.must_include "http://example.com/css_images/images/cantaloupe.png"
  end

  it "should build image from imported path" do 
    css = style("/css_images/stylesheets/paths.css")
    urls = css.images.map {|image| image.url }
  
    urls.size.must_equal 4
    urls.must_include "http://example.com/css_images/images/pineapple.png"
  end
end

private 

def style(path)
  ColorParser::Stylesheet.new(text: fixture(path), 
                              url: "http://example.com#{path}")
end

def fixture(path)
  fixture = "#{File.dirname(__FILE__)}/../test/fixtures#{path}"
  File.read(fixture) if File.exist?(fixture)
end
