class Request
  def get(url)
    curl = Curl::Easy.perform(url) do |curl| 
      curl.headers["User-Agent"] = user_agent
      curl.follow_location       = true
    end

    curl.body_str

  rescue ColorParser::Error
    raise

  # re-raise external library errors in our namespace
  rescue => error
    raise ColorParser::Error.new("#{error.class}: #{error.message}")
  end

  def user_agent
    "Ruby/ColorParser Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.8.0.7) Gecko/20060909 Firefox/1.5.0.7"
  end
end