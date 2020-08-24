# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'color_parser/version'

Gem::Specification.new do |gem|
  gem.name          = "color_parser"
  gem.version       = ColorParser::VERSION
  gem.summary       = %q{Finds colors on a given webpage}
  gem.description   = gem.summary

  gem.required_ruby_version = '>= 1.9.3'
  gem.license       = "MIT"

  gem.authors       = ["Derek DeVries"]
  gem.email         = ["derek@sportspyder.com"]
  gem.homepage      = "https://github.com/devrieda/color_parser"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_runtime_dependency("stylesheet",       "~> 0.1.8")
  gem.add_runtime_dependency("color_conversion", "~> 0.1.0")

  gem.add_development_dependency("rake")
  gem.add_development_dependency("rspec", "~> 2.9")

  # guard
  gem.add_development_dependency("guard", "~> 1.7")
  gem.add_development_dependency("guard-rspec", "~> 2.5")
  gem.add_development_dependency("rb-fsevent", "~> 0.9")
end
