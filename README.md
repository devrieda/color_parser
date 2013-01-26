## ColorParser

The ColorParser gem provides a simple way to parse the colors from an HTML page. 
It scans both the HTML and CSS to find all colors and sort them by frequency 
used. 

## Example

Get colors on a given webpage

```ruby
page = ColorParser::Page.new("http://google.com/")
colors = page.colors
```

Get stylesheets on a given webpage

```ruby
page = ColorParser::Page.new("http://google.com/")
stylesheets = page.stylesheets
```

Get images on a given webpage

```ruby
page = ColorParser::Page.new("http://google.com/")
images = page.images
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
