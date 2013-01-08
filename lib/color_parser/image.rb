module ColorParser
  class Image
    attr_reader :url, :host, :path, :query

    def initialize(url)
      @url = url
      @host, @path, @query = ColorParser.parse_url(url)
    end

    def name
      path.split("/").last
    end

    # TODO - find colors in the image
    def colors
      []
    end

  end
end