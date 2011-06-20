module Periplus
  class BingResponse
    def initialize(httparty_response)
      @response = httparty_response

      if @response.response.kind_of? Net::HTTPClientError
        http_code = @response.response.code
        http_message = @response.response.message
        raise "An error has occurred communicating with the Bing Maps service. HTTP Status: #{http_code} (#{http_message})"
      end

      parse
    end

    def parse
      resource_sets = @response.parsed_response["resourceSets"]
      raise "Not found." if resource_sets == nil or resource_sets.length == 0

      resources = resource_sets.first["resources"]
      raise "Not found." if resources == nil or resources.length == 0

      @primary_resource = resources.first
    end
  end
end
