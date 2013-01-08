module ColorParser
  # a webpage
  class Page
    attr_reader :url, :host, :path, :query, :text, :doc

    def initialize(url)
      @url = url
      @host, @path, @query = ColorParser.parse_url(url)

      @text ||= ColorParser.retrieve(@host, @path, @query)
      @doc  ||= Hpricot(@text)
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

    def stylesheets
      @stylesheets ||= inline_styles + external_styles
    end



    private

    # find all inline styles and build new stylesheet from them
    def inline_styles
      doc.search("style").map do |style|
        Stylesheet.new(:text => style.inner_html, 
                       :type => "inline", 
                       :host => host, 
                       :path => path)
      end
    end

    def external_styles
      styles = []

      doc.search("//link[@rel='stylesheet']").each do |style|
        next unless href = style.attributes["href"]

        host, path, query = ColorParser.parse_asset(url, href)
        next unless text = ColorParser.retrieve(host, path, query)

        css = Stylesheet.new(:text  => text, 
                             :type  => "external", 
                             :host  => host, 
                             :path  => path, 
                             :query => query)
        styles << css
      end

      styles
    end
  end

end