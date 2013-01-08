require_relative "test_helper"

describe ColorParser do
  def setup
    ColorParser.request = ColorParser::TestRequest.new
  end

  it "should retrieve fixture" do
    url = "http://example.com/css/absolute.html?foo=bar"
    result = ColorParser.request.get(url)
    result.wont_be_nil
  end


  # parse_url
  
  it "should parse url" do 
    url = "http://example.com/test/something/"
    assert_equal ["example.com", "/test/something/", nil], ColorParser.parse_url(url)
  end
  
  it "should parse url with no trailing slash" do 

    url = "http://example.com"
    assert_equal ["example.com", "/", nil], ColorParser.parse_url(url)
  end
  
  it "should parse url with query params" do 
    url = "http://example.com?foo=bar&baz=bar"
    assert_equal ["example.com", "/", "foo=bar&baz=bar"], ColorParser.parse_url(url)
  end


  # parse_asset

  it "should parse asset absolute path" do 
    doc   = "http://example.com/stylesheets/base.css"
    asset = "http://asset.example.com/stylesheets/style.css"

    parsed = ColorParser.parse_asset(doc, asset)
    parsed.must_equal "http://asset.example.com/stylesheets/style.css"
  end

  it "should parse asset absolute path with query string" do 
    doc   = "http://example.com/stylesheets/base.css?foo=bar"
    asset = "http://asset.example.com/stylesheets/style.css?baz=bar"
  
    parsed = ColorParser.parse_asset(doc, asset)
    parsed.must_equal "http://asset.example.com/stylesheets/style.css?baz=bar"
  end
  
  it "should parse relative root path" do 
    doc   = "http://example.com/stylesheets/base.css"
    asset = "/styles/style.css"
  
    parsed = ColorParser.parse_asset(doc, asset)
    parsed.must_equal "http://example.com/styles/style.css"
  end
  
  it "should parse relative root path with query string" do 
    doc   = "http://example.com/stylesheets/base.css?foo=bar"
    asset = "/styles/style.css?baz=bar"
  
    parsed = ColorParser.parse_asset(doc, asset)
    parsed.must_equal "http://example.com/styles/style.css?baz=bar"
  end
  
  it "should parse relative path" do 
    doc   = "http://example.com/stylesheets/base.css"
    asset = "ie.css"
  
    parsed = ColorParser.parse_asset(doc, asset)
    parsed.must_equal "http://example.com/stylesheets/ie.css"
  end
  
  it "should parse relative path with query string" do 
    doc   = "http://example.com/stylesheets/base.css?foo=bar"
    asset = "ie.css?baz=bar"
  
    parsed = ColorParser.parse_asset(doc, asset)
    parsed.must_equal "http://example.com/stylesheets/ie.css?baz=bar"
  end
end
