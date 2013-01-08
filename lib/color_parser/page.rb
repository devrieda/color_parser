module ColorParser
  # a webpage
  class Page
    attr_reader :url, :host, :path, :query, :text, :doc

    def initialize(url)
      @url = url
      @host, @path, @query = ColorParser.parse_url(url)

      @text ||= ColorParser.request.get(url)
      @doc  ||= Nokogiri::HTML(@text)
    end

    def colors
      unless @colors
        @colors = {}
        stylesheets.each do |style| 
          style.colors.each do |color, freq|
            @colors[color] ? @colors[color] += freq : @colors[color] = freq
          end
        end
      end

      @colors
    end

    def colors_by_frequency
      colors.sort {|a,b| b[1]<=>a[1] }.map {|clr| clr.first }
    end

    def images
      @images ||= inline_images + stylesheet_images
    end

    def stylesheets
      @stylesheets ||= inline_styles + external_styles
    end


    private

    # find all inline styles and build new stylesheet from them
    def inline_styles
      doc.css("style").map do |style|
        Stylesheet.new(text: style.inner_html, 
                       type: "inline", 
                       url:  "http://#{host}#{path}")
      end
    end

    def external_styles
      styles = []

      doc.css("link[rel='stylesheet']").each do |style|
        next unless href = style["href"]

        asset_url = ColorParser.parse_asset(url, href)
        next unless text = ColorParser.request.get(asset_url)

        css = Stylesheet.new(text: text, 
                             type: "external", 
                             url:  asset_url)
        styles << css
      end

      styles
    end

    def inline_images
      images = []

      doc.css("img").map do |image|
        next unless src = image["src"]
        next unless src.match(/gif|jpg|jpeg|png|bmp/)

        asset_url = ColorParser.parse_asset(url, src)
        images << Image.new(asset_url)
      end

      images
    end

    def stylesheet_images
      [stylesheets.map {|style| style.images }].flatten
    end
  end

end