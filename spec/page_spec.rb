require 'spec_helper'

describe Page do
  before(:each) do 
    ColorParser.request = FakeRequest.new
  end

  it "should initialize url" do
    url = "http://example.com/css/inline.html?foo=bar"
    page = ColorParser::Page.new(url)
    
    expect(page.url).to eq url
  end

  it "should parse url" do
    url = "http://example.com/css/inline.html?foo=bar"
    page = ColorParser::Page.new(url)

    expect(page.host).to eq  "example.com" 
    expect(page.path).to eq  "/css/inline.html"
    expect(page.query).to eq "foo=bar"
  end

  # Stylesheet sources
  it "should build styles from inline css" do 
    url = "http://example.com/css/inline.html"
    page = ColorParser::Page.new(url)
  
    # 2 found
    expect(page.stylesheets.length).to eq 2

    # stylesheet content
    sheet = page.stylesheets.first
    expect(sheet.type).to eq "inline"
    expect(sheet.text).to include "background"
  end

  it "should build styles with inine css with import" do 
    url = "http://example.com/css/inline_import.html"
    page = ColorParser::Page.new(url)

    expect(page.stylesheets.length).to eq 1
  
    expect(page.stylesheets[0].name).to eq                "inline_import.html"
    expect(page.stylesheets[0].stylesheets[0].name).to eq "print.css"
    expect(page.stylesheets[0].stylesheets[1].name).to eq "fonts.css"
    expect(page.stylesheets[0].stylesheets[2].name).to eq "colors.css"
  end
  
  it "should build styles from external relative css" do 
    url = "http://example.com/css/relative.html"
    page = ColorParser::Page.new(url)

    # 2 found
    expect(page.stylesheets.length).to eq 2

    # stylesheet content
    sheet = page.stylesheets.first
    expect(sheet.type).to eq "external"
    expect(sheet.text).to include "background"
  end

  it "should build styles from external relative root css" do 
    url = "http://example.com/css/relative_root.html"
    page = ColorParser::Page.new(url)
  
    # 2 found
    expect(page.stylesheets.length).to eq 2
  
    # stylesheet content
    sheet = page.stylesheets.first
    expect(sheet.type).to eq "external"
    expect(sheet.text).to include "background"
  end

  it "should build styles from external absolute css" do 
    url = "http://example.com/css/relative.html"
    page = ColorParser::Page.new(url)
  
    # 2 found
    expect(page.stylesheets.length).to eq 2
  
    # stylesheet content
    sheet = page.stylesheets.first
    expect(sheet.type).to eq "external"
    expect(sheet.text).to include "background"
  end
  
  it "should build styles from imported css" do 
    url = "http://example.com/css_import/index.html"
    page = ColorParser::Page.new(url)
    css = page.stylesheets
  
    expect(css.length).to eq 2
  
    # 5 found 
    expect(css[0].name).to include "screen.css"
    expect(css[1].name).to include "print.css"

    expect(css[0].stylesheets[0].name).to include "master.css"
    expect(css[0].stylesheets[1].name).to include "fonts.css"
    expect(css[0].stylesheets[2].name).to include "ie.css"
    expect(css[0].stylesheets[3].name).to include "images.css"
    expect(css[0].stylesheets[4].name).to include "borders.css"
    expect(css[0].stylesheets[5].name).to include "colors.css"
  end
  
  it "should not fail from an invalid css path" do 
    url = "http://example.com/css/invalid.html"
    page = ColorParser::Page.new(url)
  
    # 1 found
    expect(page.stylesheets.length).to eq 1
    expect(page.stylesheets[0].name).to include "screen.css"
  end
  
  
  # IMAGES
  
  it "should build images from inline images with relative paths" do 
    url    = "http://example.com/inline_images/relative.html"
    page   = ColorParser::Page.new(url)
    images = page.images
  
    expect(images.size).to eq 2
  
    expect(images[0].url).to eq "http://example.com/inline_images/images/apple.png"
    expect(images[1].url).to eq "http://example.com/inline_images/images/kiwi.jpg"
  end
  
  it "should build images from inline images with relative root paths" do 
    url    = "http://example.com/inline_images/relative_root.html"
    page   = ColorParser::Page.new(url)
    images = page.images
  
    expect(images.size).to eq 2
  
    expect(images[0].url).to eq "http://example.com/inline_images/images/apple.png"
    expect(images[1].url).to eq "http://example.com/inline_images/images/kiwi.jpg"
  end
  
  it "should build images from inline images with absolute paths" do 
    url    = "http://example.com/inline_images/absolute.html"
    page   = ColorParser::Page.new(url)
    images = page.images
  
    expect(images.size).to eq 2
  
    expect(images[0].url).to eq "http://example.com/inline_images/images/apple.png"
    expect(images[1].url).to eq "http://example.com/inline_images/images/kiwi.jpg"
  end
  
  
  # STYLESHEET IMAGES
  
  it "should combine images from inline external and import styles" do 
    url    = "http://example.com/css_images/paths.html"
    page   = ColorParser::Page.new(url)
    images = page.images
  
    expect(images.size).to eq 5

    expect(images[0].name).to eq "mango.png"
    expect(images[1].name).to eq "apple.png"
    expect(images[2].name).to eq "kiwi.jpg"
    expect(images[3].name).to eq "cantaloupe.png"
    expect(images[4].name).to eq "pineapple.png"
  end


  # STYLESHEET COLORS 

  it "should combine colors from external and import styles" do 
    url    = "http://example.com/css_color/frequency.html"
    page   = ColorParser::Page.new(url)
    colors = page.colors
  
    expect(colors["386ec0"]).to eq 4
    expect(colors["3a5dc4"]).to eq 3
    expect(colors["718ad7"]).to eq 2
    expect(colors["ff0000"]).to eq 1
    expect(colors["357ad1"]).to eq 1
    expect(colors["535353"]).to eq 1
  end
  
  it "should solot colors by frequency" do 
    url    = "http://example.com/css_color/frequency.html"
    page   = ColorParser::Page.new(url)

    colors = ["386ec0", "3a5dc4", "718ad7", "535353", "357ad1", "ff0000"]
    expect(page.colors_by_frequency).to eq colors
  end
  
end
