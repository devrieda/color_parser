require 'rubygems'
require 'bundler/setup'

require_relative '../lib/color_parser.rb'
require_relative '../spec/stubs/fake_request.rb'

include ColorParser

RSpec.configure do |config|
end