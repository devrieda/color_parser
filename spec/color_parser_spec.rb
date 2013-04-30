require 'spec_helper'

describe ColorParser do
  before(:each) do 
    ColorParser.request = FakeRequest.new
  end

  it "should retrieve fixture" do
    url = "http://example.com/css/absolute.html?foo=bar"
    result = ColorParser.request.get(url)
    expect(result).to be
  end


  # parse_url
  
  it "should parse url" do 
    url = "http://example.com/test/something/"
    parsed = ColorParser.parse_url(url)

    expect(parsed).to eq ["example.com", "/test/something/", nil]
  end
  
  it "should parse url with no trailing slash" do 
    url = "http://example.com"
    parsed = ColorParser.parse_url(url)

    expect(parsed).to eq ["example.com", "/", nil]
  end
  
  it "should parse url with query params" do 
    url = "http://example.com?foo=bar&baz=bar"
    parsed = ColorParser.parse_url(url)

    expect(parsed).to eq ["example.com", "/", "foo=bar&baz=bar"]
  end


  # parse_asset

  it "should parse asset absolute path" do 
    doc   = "http://example.com/stylesheets/base.css"
    asset = "http://asset.example.com/stylesheets/style.css"

    parsed = ColorParser.parse_asset(doc, asset)
    expect(parsed).to eq "http://asset.example.com/stylesheets/style.css"
  end

  it "should parse asset absolute path with query string" do 
    doc   = "http://example.com/stylesheets/base.css?foo=bar"
    asset = "http://asset.example.com/stylesheets/style.css?baz=bar"
  
    parsed = ColorParser.parse_asset(doc, asset)
    expect(parsed).to eq "http://asset.example.com/stylesheets/style.css?baz=bar"
  end
  
  it "should parse relative root path" do 
    doc   = "http://example.com/stylesheets/base.css"
    asset = "/styles/style.css"
  
    parsed = ColorParser.parse_asset(doc, asset)
    expect(parsed).to eq "http://example.com/styles/style.css"
  end
  
  it "should parse relative root path with query string" do 
    doc   = "http://example.com/stylesheets/base.css?foo=bar"
    asset = "/styles/style.css?baz=bar"
  
    parsed = ColorParser.parse_asset(doc, asset)
    expect(parsed).to eq "http://example.com/styles/style.css?baz=bar"
  end
  
  it "should parse relative path" do 
    doc   = "http://example.com/stylesheets/base.css"
    asset = "ie.css"
  
    parsed = ColorParser.parse_asset(doc, asset)
    expect(parsed).to eq "http://example.com/stylesheets/ie.css"
  end
  
  it "should parse relative path with query string" do 
    doc   = "http://example.com/stylesheets/base.css?foo=bar"
    asset = "ie.css?baz=bar"
  
    parsed = ColorParser.parse_asset(doc, asset)
    expect(parsed).to eq "http://example.com/stylesheets/ie.css?baz=bar"
  end
end
