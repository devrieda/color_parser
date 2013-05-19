## ColorParser

The ColorParser gem provides a simple way to parse the colors from an HTML page. 
It scans both the HTML and CSS to find all colors and sort them by frequency 
used. 

## Example

Get colors on a given webpage

```ruby
page = ColorParser::Page.new("http://google.com/")
colors = page.colors
=> {"ffffff"=>5, "c9d7f1"=>1, "0000cc"=>2, "dd8e27"=>1, "990000"=>1, 
    "3366cc"=>3, "000000"=>2, "1111cc"=>5, "cccccc"=>2, "551a8b"=>1}

colors = page.colors_by_freqency
=> ["ffffff", "1111cc", "3366cc", "000000", "cccccc", 
    "0000cc", "dd8e27", "c9d7f1", "990000", "551a8b"]
```

## Installation

To install ColorParser, add the gem to your Gemfile: 

```ruby
gem "color_parser"
```

## LICENSE

Copyright (c) 2013 Derek DeVries

Released under the [MIT License](http://www.opensource.org/licenses/MIT)
