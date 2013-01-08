require 'net/http'
require 'uri'
require 'nokogiri'

require 'color_parser/version'
require 'color_parser/page'
require 'color_parser/stylesheet'
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
  
  # Request an asset
  #
  class Request    
    @@last_request = Time.now

    # default throttle requests 1 per sec
    def initialize(params={})
      @throttle = params[:throttle] || 1
    end

    def get(url)
      throttle

      begin
        uri = URI.parse(url.strip)
      rescue URI::InvalidURIError
        uri = URI.parse(URI.escape(url.strip))
      end

      response = get_response(uri)

      # redirect
      @prev_redirect ||= ""
      if response.header['location']
        # make sure we're not in an infinite loop
        if response.header['location'] == @prev_redirect
          raise HTTPError, "Recursive redirect: #{@prev_redirect}"
        end
        @prev_redirect = response.header['location']

        return get(response.header['location'])
      end
      
      # bad req
      if response.to_s.index 'Bad Request' || response.nil?
        raise HTTPError, "invalid HTTP request #{url}" 
      end
      
      response = fix_encoding(response)
      response.body
    end

    def user_agent
      "ColorParser Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.8.0.7) Gecko/20060909 Firefox/1.5.0.7"
    end


    private

    # Use charset in content-type, default to UTF-8 if absent
    # 
    # text/html; charset=UTF-8
    # - or -
    # text/html; charset=iso-8859-1
    # - or - 
    # text/html    
    def fix_encoding(response)
      charset = if response.header["Content-Type"].to_s.include?("charset")
        response.header["Content-Type"].split(";")[1].split("=")[1]
      else
        "UTF-8"
      end

      response.body.force_encoding(charset.upcase).encode("UTF-8")
      response
    end

    # build http request object
    def get_response(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 15
      http.read_timeout = 30

      request = Net::HTTP::Get.new(uri.request_uri)
      request["User-Agent"] = user_agent

      http.request(request)
    end

    # throttle requests to 1 per sec
    def throttle
      sleep @throttle if @@last_request + @throttle > Time.now
      @@last_request = Time.now
    end
  end

end