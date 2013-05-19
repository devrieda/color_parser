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
      property_list.each do |key, value| 
        color = nil
        value.gsub(/\s?,\s?/, ",").split(" ").each do |part|
          color ||= ColorConversion::Color.new(part) rescue nil
        end
        next unless color

        hex = color.hex.gsub("#", "")
        colors[hex] ? colors[hex] += 1 : colors[hex] = 1
      end

      # sort by colors with most occurrances
      colors
    end
  
  end
end