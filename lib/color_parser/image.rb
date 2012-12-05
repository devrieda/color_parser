module ColorParser
  class Image
    attr_reader :host, :path, :query

    def initialize(options)
      @host  = options[:host]
      @path  = options[:path]
      @query = options[:query]
    end

    def url
      "http://#{host}#{path}#{"?"+query if query}" 
    end

    def name
      path.split("/").last
    end

    # find colors in the image
    def colors
      []
    end

  end
end