require 'net/http'
require 'uri'
require 'curb'
require 'nokogiri'

require 'color_parser/version'
require 'color_parser/page'
require 'color_parser/stylesheet'

module ColorParser

  def self.retrieve(host, path, query = nil, redirect_limit = 10)
    # redirect too deep
    return "" if redirect_limit == 0
    
    # test by reading in fixtures with path
    if host == "example.com"
      fixture = "#{File.dirname(__FILE__)}/../test/fixtures#{path}"
      File.read(fixture) if File.exist?(fixture)

    # GET the resource
    else
      http = Net::HTTP.new(host)
      http.open_timeout = 15
      http.read_timeout = 30
      response = http.start {|http| http.get "#{path}#{"?" + query if query}" }

      case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPRedirection
        location = response["location"]
        host, path, query = self.parse_asset("http://#{host}#{path}", location)
        self.retrieve(host, path, query, redirect_limit - 1)
      end      
    end
  end

  # find host/path of an asset based on the relative/absolute url
  def self.parse_asset(doc_url, asset_url)
    doc_host,   doc_path,   doc_query   = self.parse_url(doc_url)
    asset_host, asset_path, asset_query = self.parse_url(asset_url)

    # absolute path
    if asset_url.include?("http")
      [asset_host, asset_path, asset_query]

    # root relative
    elsif asset_url[0,1] == "/"
      [doc_host, asset_path, asset_query]

    # relative
    else
      path = File.expand_path("#{doc_path.gsub(/[^\/]*$/, "")}#{asset_path}", "/")
      [doc_host, path, asset_query]
    end
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
  
  # Instantiate a request for a source page
  #
  class Request    
    attr_reader :response_time, :parse_time

    @@last_request = Time.now

    # default throttle requests 1 per sec
    def initialize(params={})
      @throttle = params[:throttle] || 1
    end

    def get_page(url)
      throttle

      # perform request
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Get.new(uri.request_uri)
      request["User-Agent"] = user_agent

      response = http.request(request)

      # redirect
      @prev_redirect ||= ""
      if response.header['location']
        # make sure we're not in an infinite loop
        if response.header['location'] == @prev_redirect
          raise HTTPError, "Recursive redirect: #{@prev_redirect}"
        end
        @prev_redirect = response.header['location']

        return get_page(response.header['location'])
      end
      
      # bad req
      if response.to_s.index 'Bad Request' || response.nil?
        raise HTTPError, "invalid HTTP request #{url}" 
      end

      # Use charset in content-type, default to UTF-8 if absent
      # 
      # text/html; charset=UTF-8
      # - or -
      # text/html; charset=iso-8859-1
      # - or - 
      # text/html
      charset = if response.header["Content-Type"].to_s.include?("charset")
        response.header["Content-Type"].split(";")[1].split("=")[1]
      else
        "UTF-8"
      end

      response.body.force_encoding(charset.upcase).encode("UTF-8")
      response.body
    end
    
    def user_agent
      "SportSpyder/ColorParser Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.8.0.7) Gecko/20060909 Firefox/1.5.0.7"
    end


    private

    # throttle requests to 1 per sec
    def throttle
      sleep @throttle if @@last_request + @throttle > Time.now
      @@last_request = Time.now
    end
  end

end