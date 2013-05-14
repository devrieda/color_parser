module ColorParser

  class Stylesheet
    
    def initialize(style_sheet)
      @style_sheet = style_sheet
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

    def rules
      rules = {}
      
      ([@style_sheet] + style_sheets).each do |css|
        css.style_rules.each do |rule|
          rules[rule.selector_text] ||= {}
          rules[rule.selector_text].merge!(rule.style.declarations)
        end
      end

      rules
    end

    # split up selectors into properties, and return property key/value pairs
    def properties
      properties = []

      rules.values.each do |declarations|
        declarations.each {|property, value| properties << [property, value] }
      end
      
      properties
    end

    private

    # get imported stylesheets
    def style_sheets
      @style_sheets ||= @style_sheet.import_rules.map {|rule| rule.style_sheet }
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