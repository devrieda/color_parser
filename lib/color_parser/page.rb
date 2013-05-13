module ColorParser
  # a webpage
  class Page
    attr_reader :url, :text

    def initialize(url)
      @style_document = self.class.style_document.new(url)

      @url  = @style_document.location.href
      @text = @style_document.text
    end

    def stylesheets
      @stylesheets ||= @style_document.style_sheets.map do |style_sheet|
        Stylesheet.new(style_sheet)
      end
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


    def self.style_document
      @style_document ||= ::Stylesheet::Document
    end

    def self.style_document=(style_document)
      @style_document = style_document
    end
  end
end