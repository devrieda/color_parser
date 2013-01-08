require_relative "test_helper"

describe Image do
  def setup
    ColorParser.request = ColorParser::TestRequest.new
  end

  it "should assign url" do
    image = ColorParser::Image.new("http://example.com/foo/bar.png")
    
    image.url.must_equal "http://example.com/foo/bar.png"
  end
  
  it "should parse host path and query from url" do 
    image = ColorParser::Image.new("http://example.com/foo/bar.png?baz=bar")

    image.host.must_equal  "example.com"
    image.path.must_equal  "/foo/bar.png"
    image.query.must_equal "baz=bar"
  end

  it "should parse name" do 
    image = ColorParser::Image.new("http://example.com/foo/bar.png?baz=bar")

    "bar.png".must_equal image.name
  end
end
