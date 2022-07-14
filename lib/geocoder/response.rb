# frozen_string_literal: true

module Geocoder
  # Generic wrapper for an HTTP response.
  class Response
    attr_reader :code, :body

    def initialize(code:, body: nil, headers: nil)
      @code = code.to_i
      @body = body.to_s
      @headers = {}

      if headers
        headers.each do |name, value|
          add_header(name, value)
        end
      end
    end

    def header(name)
      @headers[name.to_s.downcase]
    end

    def add_header(name, value)
      @headers[name.to_s.downcase] = value
    end

    def content_type
      header('content-type')
    end
  end
end
