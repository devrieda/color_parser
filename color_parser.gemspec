# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'color_parser/version'

Gem::Specification.new do |gem|
  gem.name          = "color_parser"
  gem.version       = ColorParser::VERSION
  gem.summary       = %q{Color Parser finds the colors on a given webpage}
  gem.description   = gem.summary

  gem.required_ruby_version = '>= 1.9.3'
  gem.license       = "MIT"

  gem.authors       = ["Derek DeVries"]
  gem.email         = ["derek@sportspyder.com"]
  gem.homepage      = "http://sportspyder.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency("nokogiri", "~> 1.5")
  gem.add_runtime_dependency("curb",     "~> 0.8.0")
  gem.add_development_dependency("rake")
end
