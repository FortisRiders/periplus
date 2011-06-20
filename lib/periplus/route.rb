module Periplus
  class Route
    attr_accessor :response
    attr_accessor :distance
    attr_accessor :distance_unit
    attr_accessor :duration
    attr_accessor :route

    def initialize(httparty_response)
      @response = httparty_response

      if @response.response.kind_of? Net::HTTPClientError
        http_code = @response.response.code
        http_message = @response.response.message
        raise "An error has occurred communicating with the Bing Maps service. HTTP Status: #{http_code} (#{http_message})"
      end

      parse_resource_sets
    end

    def parse_resource_sets      
      resource_sets = @response.parsed_response["resourceSets"]
      raise "No route found." if resource_sets == nil or resource_sets.length == 0

      resources = resource_sets.first["resources"]
      raise "No route found." if resources == nil or resources.length == 0

      primary_route = resources.first
      
      @distance = primary_route["travelDistance"]
      @distance_unit = primary_route["distanceUnit"].downcase.to_sym

      @duration = primary_route["travelDuration"]

      @route = primary_route
    end
  end
end
