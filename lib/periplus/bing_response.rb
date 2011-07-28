require 'pp'

module Periplus
  class BingResponse
    def initialize(httparty_response)
      @response = httparty_response

      raise error if @response.response.kind_of? Net::HTTPClientError

      parse
    end

    def parse
      resource_sets = @response.parsed_response["resourceSets"]
      raise "Not found." if resource_sets == nil or resource_sets.length == 0

      resources = resource_sets.first["resources"]
      raise "Not found." if resources == nil or resources.length == 0

      @primary_resource = resources.first
    end
    
    def error
      http_code = @response.response.code
      http_message = @response.response.message
      message = "An error has occurred communicating with the Bing Maps service. HTTP Status: #{http_code} (#{http_message})"
      if Periplus.verbose
        message << "\n  URL: #{@response.request.path}"
        message << "\n  Response:"
        message << "\n  #{PP.pp(@response.response.body, "")}"
      end
      message
    end
  end
end
