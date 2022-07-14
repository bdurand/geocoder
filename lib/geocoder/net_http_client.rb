# frozen_string_literal: true

module Geocoder
  # HTTP client based off the built off the standard Net::HTTP library for making GET requests.
  class NetHttpClient
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def get(uri)
      use_ssl = uri.is_a?(URI::HTTPS)
      http_client(uri).start(uri.host, uri.port, use_ssl: use_ssl, open_timeout: configuration.timeout, read_timeout: configuration.timeout) do |client|
        req = Net::HTTP::Get.new(uri.request_uri, configuration.http_headers)
        if configuration.basic_auth[:user] and configuration.basic_auth[:password]
          req.basic_auth(
            configuration.basic_auth[:user],
            configuration.basic_auth[:password]
          )
        end
        http_resp = client.request(req)
        response(http_resp)
      end
    end

    private

    ##
    # Object used to make HTTP requests.
    #
    def http_client(uri)
      protocol = uri.scheme
      proxy_name = "#{protocol}_proxy"
      if proxy = configuration.send(proxy_name)
        proxy_url = !!(proxy =~ /\A#{protocol}/) ? proxy : protocol + '://' + proxy
        begin
          uri = URI.parse(proxy_url)
        rescue URI::InvalidURIError
          raise ConfigurationError,
            "Error parsing #{protocol.upcase} proxy URL: '#{proxy_url}'"
        end
        Net::HTTP::Proxy(uri.host, uri.port, uri.user, uri.password)
      else
        Net::HTTP
      end
    end

    ##
    # Cast the Net::HTTPResponse to a Geocoder::Response
    #
    def response(http_resp)
      resp = Response.new(code: http_resp.code.to_i, body: http_resp.body)
      http_resp.each_header do |name, value|
        resp.add_header(name, value)
      end
      resp
    end
  end
end
