= ColorParser


== Retrieving styles

  parser = ColorParser::Page.fetch("http://sportspyder.com/")
  styles = parser.stylesheets


== Retrieving images

  parser = ColorParser::Page.fetch("http://sportspyder.com/")
  images = parser.images
  
  
== Retrieving colors

  parser = ColorParser::Page.fetch("http://sportspyder.com/")
  colors = parser.colors