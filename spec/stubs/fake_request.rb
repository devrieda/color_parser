module ColorParser
  class FakeRequest
    def initialize(params={})
    end
    
    # Read in fixture file instead of url
    def get(url)
      begin
        uri = URI.parse(url.strip)
      rescue URI::InvalidURIError
        uri = URI.parse(URI.escape(url.strip))
      end

      # simple hack to read in fixtures instead of url for tests
      fixture = "#{File.dirname(__FILE__)}/../fixtures#{uri.path}"
      File.read(fixture) if File.exist?(fixture)
    end
  end
end