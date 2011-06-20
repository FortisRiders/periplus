require File.expand_path(File.dirname(__FILE__) + "/bing_response")

module Periplus
  class Route < BingResponse
    attr_accessor :response
    attr_accessor :distance
    attr_accessor :distance_unit
    attr_accessor :duration
    attr_accessor :route

    def parse
      super()

      @distance = @primary_resource["travelDistance"]
      @distance_unit = @primary_resource["distanceUnit"].downcase.to_sym
      @duration = @primary_resource["travelDuration"]
      @route = @primary_resource
    end
  end
end
