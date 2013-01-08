require_relative "test_helper"

describe Page do
  def setup
    ColorParser.request = ColorParser::TestRequest.new
  end

  it "should initialize url" do
    url = "http://example.com/css/inline.html?foo=bar"
    page = ColorParser::Page.new(url)
    
    page.url.must_equal url
  end

  it "should parse url" do
    url = "http://example.com/css/inline.html?foo=bar"
    page = ColorParser::Page.new(url)

    page.host.must_equal  "example.com" 
    page.path.must_equal  "/css/inline.html"
    page.query.must_equal "foo=bar"
  end

  # Stylesheet sources
  it "should build styles from inline css" do 
    url = "http://example.com/css/inline.html"
    page = ColorParser::Page.new(url)
  
    # 2 found
    page.stylesheets.length.must_equal 2

    # stylesheet content
    sheet = page.stylesheets.first
    sheet.type.must_equal "inline"
    sheet.text.must_include "background"
  end

  it "should build styles with inine css with import" do 
    url = "http://example.com/css/inline_import.html"
    page = ColorParser::Page.new(url)

    page.stylesheets.length.must_equal 1
  
    page.stylesheets[0].name.must_equal                "inline_import.html"
    page.stylesheets[0].stylesheets[0].name.must_equal "print.css"
    page.stylesheets[0].stylesheets[1].name.must_equal "fonts.css"
    page.stylesheets[0].stylesheets[2].name.must_equal "colors.css"
  end
  
  it "should build styles from external relative css" do 
    url = "http://example.com/css/relative.html"
    page = ColorParser::Page.new(url)

    # 2 found
    page.stylesheets.length.must_equal 2

    # stylesheet content
    sheet = page.stylesheets.first
    sheet.type.must_equal "external"
    sheet.text.must_include "background"
  end

  it "should build styles from external relative root css" do 
    url = "http://example.com/css/relative_root.html"
    page = ColorParser::Page.new(url)
  
    # 2 found
    page.stylesheets.length.must_equal 2
  
    # stylesheet content
    sheet = page.stylesheets.first
    sheet.type.must_equal "external"
    sheet.text.must_include "background"
  end

  it "should build styles from external absolute css" do 
    url = "http://example.com/css/relative.html"
    page = ColorParser::Page.new(url)
  
    # 2 found
    page.stylesheets.length.must_equal 2
  
    # stylesheet content
    sheet = page.stylesheets.first
    sheet.type.must_equal "external"
    sheet.text.must_include "background"
  end
  
  it "should build styles from imported css" do 
    url = "http://example.com/css_import/index.html"
    page = ColorParser::Page.new(url)
    css = page.stylesheets
  
    css.length.must_equal 2
  
    # 5 found 
    css[0].name.must_include "screen.css"
    css[1].name.must_include "print.css"

    css[0].stylesheets[0].name.must_include "master.css"
    css[0].stylesheets[1].name.must_include "fonts.css"
    css[0].stylesheets[2].name.must_include "ie.css"
    css[0].stylesheets[3].name.must_include "images.css"
    css[0].stylesheets[4].name.must_include "borders.css"
    css[0].stylesheets[5].name.must_include "colors.css"
  end
  
  it "should not fail from an invalid css path" do 
    url = "http://example.com/css/invalid.html"
    page = ColorParser::Page.new(url)
  
    # 1 found
    page.stylesheets.length.must_equal 1
    page.stylesheets[0].name.must_include "screen.css"
  end
  
  
  # IMAGES
  
  it "should build images from inline images with relative paths" do 
    url    = "http://example.com/inline_images/relative.html"
    page   = ColorParser::Page.new(url)
    images = page.images
  
    images.size.must_equal 2
  
    images[0].url.must_equal "http://example.com/inline_images/images/apple.png"
    images[1].url.must_equal "http://example.com/inline_images/images/kiwi.jpg"
  end
  
  it "should build images from inline images with relative root paths" do 
    url    = "http://example.com/inline_images/relative_root.html"
    page   = ColorParser::Page.new(url)
    images = page.images
  
    images.size.must_equal 2
  
    images[0].url.must_equal "http://example.com/inline_images/images/apple.png"
    images[1].url.must_equal "http://example.com/inline_images/images/kiwi.jpg"
  end
  
  it "should build images from inline images with absolute paths" do 
    url    = "http://example.com/inline_images/absolute.html"
    page   = ColorParser::Page.new(url)
    images = page.images
  
    images.size.must_equal 2
  
    images[0].url.must_equal "http://example.com/inline_images/images/apple.png"
    images[1].url.must_equal "http://example.com/inline_images/images/kiwi.jpg"
  end
  
  
  # STYLESHEET IMAGES
  
  it "should combine images from inline external and import styles" do 
    url    = "http://example.com/css_images/paths.html"
    page   = ColorParser::Page.new(url)
    images = page.images
  
    images.size.must_equal 5

    images[0].name.must_equal "mango.png"
    images[1].name.must_equal "apple.png"
    images[2].name.must_equal "kiwi.jpg"
    images[3].name.must_equal "cantaloupe.png"
    images[4].name.must_equal "pineapple.png"
  end


  # STYLESHEET COLORS 

  it "should combine colors from external and import styles" do 
    url    = "http://example.com/css_color/frequency.html"
    page   = ColorParser::Page.new(url)
    colors = page.colors
  
    colors["386ec0"].must_equal 4
    colors["3a5dc4"].must_equal 3
    colors["718ad7"].must_equal 2
    colors["ff0000"].must_equal 1
    colors["357ad1"].must_equal 1
    colors["535353"].must_equal 1
  end
  
  it "should solot colors by frequency" do 
    url    = "http://example.com/css_color/frequency.html"
    page   = ColorParser::Page.new(url)

    colors = ["386ec0", "3a5dc4", "718ad7", "535353", "357ad1", "ff0000"]
    page.colors_by_frequency.must_equal colors
  end
  
end
