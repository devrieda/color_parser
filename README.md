## ColorParser

The ColorParser gem provides a simple way to parse the colors from an HTML page. It scans both the HTML and CSS to find all colors and sort them by frequency used. 

## Example

```ruby
page = ColorParser::Page.new("http://sportspyder.com/")
colors = page.colors
```

## Installation

```
gem install color_parser
```
```
gem "color_parser"
```

## LICENSE

Copyright (c) 2012 Derek DeVries

Released under the [MIT License](http://www.opensource.org/licenses/MIT)
