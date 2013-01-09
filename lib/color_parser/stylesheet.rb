module ColorParser
  # a set of css selectors
  class Stylesheet
    attr_reader :url, :type, :host, :path, :query, :text
    
    def initialize(options)
      @type  = options[:type]
      @text  = options[:text]
      @url   = options[:url]

      @host, @path, @query = ColorParser.parse_url(url)
    end

    def name
      path.split("/").last
    end

    # get imported stylesheets
    def stylesheets
      @stylesheets ||= imported_stylesheets
    end

    # gst list of colors from styles
    def colors
      @colors ||= parse_colors(color_properties)
    end

    def bg_colors
      @bg_colors ||= parse_colors(bg_properties)
    end

    def text_colors
      @text_colors ||= parse_colors(text_properties)
    end

    def border_colors
      @border_colors ||= parse_colors(border_properties)
    end


    def images
      images = []

      image_properties.each do |key, value|
        if value.include?("url") && match = value.match(/url\(['"]?([^'")]+)/)
          asset_url = ColorParser.parse_asset(url, match[1])
          images << Image.new(asset_url)
        end
      end

      images
    end


    # groups of css selectors (including imported styles)
    def selectors
      selectors = {}

      text.scan(/([^\s\}]+)[\s]*?\{(.*?)\}/m).each do |match|
        selector, rule = match
        selectors[selector] ||= []
        selectors[selector] << rule.strip 
      end

      # imported styles
      stylesheets.each do |style| 
        style.selectors.each do |selector, rule| 
          selectors[selector] ||= []
          selectors[selector] += rule
        end
      end

      selectors
    end

    # split up selectors into properties, and return property key/value pairs
    def properties
      properties = []

      selectors.each do |selector, rules| 
        rules.each do |rule|
          rule.split(";").each do |property| 
            props = property.split(":", 2).map {|v| v.strip }
            properties << props if props.size == 2
          end
        end
      end

      properties
    end


    private

    def imported_stylesheets
      return [] unless text.include?("@import")

      styles = []
      text.scan(/@import(?:\surl|\s)(.*?)[;\n]+/).each do |style|
        style_path = style.first.gsub(/['"\(\);]/, "")

        asset_url = ColorParser.parse_asset(url, style_path)
        next unless text = ColorParser.request.get(asset_url)

        css = Stylesheet.new(text: text, 
                             type: "imported", 
                             url:  asset_url)
        styles << css
      end

      styles
    end

    # find properties that might have a color
    def color_properties
      properties.select do |key, value| 
        ["background-color", "background", "border-color", "border", 
         "border-top-color", "border-right-color", "border-bottom-color", 
         "border-left-color", "color", "outline-color"].include?(key)
      end
    end
    
    # properties with bg colors
    def bg_properties 
      color_properties.select {|key, value| key.include?("background") }
    end
    
    # properties with textual color
    def text_properties
      color_properties.select {|key, value| key == "color" }
    end
    
    # properties with borders
    def border_properties
      color_properties.select do |key, value| 
        key.include?("border") || key.include?("outline")
      end
    end

    # find properties that might have an image
    def image_properties
      color_properties.select {|key, value| key.include?("background") }
    end

    def parse_colors(property_list)
      colors = {}
      
      text_colors = ColorParser::Color.text_colors.map {|k,v| k }.join("|")

      property_list.each do |key, value|
        # hex
        hex = if matches = value.match(/#([0-9a-f]{3,6})/i)
          normalize_hex(matches[1])

        # rgb/rgba
        elsif matches = value.match(/rgba?\((\d{1,3}[,\s]+\d{1,3}[,\s]+\d{1,3})/)
          rgb_to_hex(matches[1])

        # textual
        elsif matches = value.match(/(#{text_colors})/)
          text_to_hex(matches[1])
        end

        next unless hex

        colors[hex] ? colors[hex] += 1 : colors[hex] = 1
      end

      # sort by colors with most occurrances
      colors
    end

    # convert rgb to hex
    def rgb_to_hex(rgb)
      r, g, b = rgb.split(",").map {|color| color.strip }
      "%02x" % r + "%02x" % g + "%02x" % b
    end

    # find hex for textual color
    def text_to_hex(color)
      ColorParser::Color.text_colors[color.intern]
    end
    
    # convert 3 digit hex to 6
    def normalize_hex(hex)
      (hex.length == 3 ? hex[0,1]*2 + hex[1,1]*2 + hex[2,1]*2: hex).downcase
    end

  end
end