# encoding: utf-8
require 'test_helper'

class ProxyTest < GeocoderTestCase

  def test_uses_proxy_when_specified
    Geocoder.configure(:http_proxy => 'localhost')
    client = Geocoder::NetHttpClient.new(Geocoder.config)
    assert client.send(:http_client, URI('http://example.com/')).proxy_class?
  end

  def test_doesnt_use_proxy_when_not_specified
    client = Geocoder::NetHttpClient.new(Geocoder.config)
    assert !client.send(:http_client, URI('http://example.com/')).proxy_class?
  end

  def test_exception_raised_on_bad_proxy_url
    Geocoder.configure(:http_proxy => ' \\_O< Quack Quack')
    assert_raise Geocoder::ConfigurationError do
      Geocoder::NetHttpClient.new(Geocoder.config).send(:http_client, URI('http://example.com/'))
    end
  end

  def test_accepts_proxy_with_http_protocol
    Geocoder.configure(:http_proxy => 'http://localhost')
    client = Geocoder::NetHttpClient.new(Geocoder.config)
    assert client.send(:http_client, URI('http://example.com/')).proxy_class?
  end

  def test_accepts_proxy_with_https_protocol
    Geocoder.configure(:https_proxy => 'https://localhost')
    client = Geocoder::NetHttpClient.new(Geocoder.config)
    assert client.send(:http_client, URI('https://example.com/')).proxy_class?
  end
end
