require 'uri'
require 'curb'
require 'nokogiri'

require 'color_parser/errors'
require 'color_parser/version'
require 'color_parser/request'
require 'color_parser/page'
require 'color_parser/stylesheet'
require 'color_parser/color'
require 'color_parser/image'

module ColorParser
  # Build url of an asset based on the relative/absolute url
  def self.parse_asset(doc_url, asset_url)
    doc_host,   doc_path,   doc_query   = self.parse_url(doc_url)
    asset_host, asset_path, asset_query = self.parse_url(asset_url)

    # absolute path
    host, path, query = if asset_url.include?("http")
      [asset_host, asset_path, asset_query]

    # root relative
    elsif asset_url[0,1] == "/"
      [doc_host, asset_path, asset_query]

    # relative
    else
      path = File.expand_path("#{doc_path.gsub(/[^\/]*$/, "")}#{asset_path}", "/")
      [doc_host, path, asset_query]
    end

    "http://#{host}#{path}#{"?"+query if query}"
  end

  # parse url parts
  def self.parse_url(url)
    begin
      uri = URI.parse(url.strip)
    rescue URI::InvalidURIError
      uri = URI.parse(URI.escape(url.strip))
    end

    [uri.host, (uri.path != "" ? uri.path : "/"), uri.query]
  end


  # Request

  def self.request=(request)
    @request = request
  end

  def self.request
    @request ||= Request.new
  end
end