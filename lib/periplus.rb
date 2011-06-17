require "httparty"

module Periplus
  class Request
    include HTTParty
    format :json
    
    def initialize(api_key)
      @api_key = api_key
    end
    
    BING_URL = "http://dev.virtualearth.net/REST/v1/Routes"
    def route(waypoints, options = {})
      options = options.merge(hashify_waypoints(waypoints))
                       .merge(:o => "json", :key => @api_key)
      Route.new (self.class.get BING_URL, :query => options)
    end

   private
    # turns a list of waypoints into a bing-api-friendly "wp.1", "wp.2", etc...
    def hashify_waypoints(waypoints)
      counter = 1
      waypoints.inject({}) do |hash, waypoint|
        hash["wp.#{counter}"] = format_waypoint(waypoint)
        counter = counter + 1
        hash
      end
    end

    def has_key_or_attribute?(object, key_or_attribute)
      object.respond_to? key_or_attribute or 
        (object.respond_to? :has_key? and object.has_key? key_or_attribute)
    end

    def get_by_key_or_attribute(object, key_or_attribute)
      if object.respond_to? :has_key? and object.has_key? key_or_attribute
        object[key_or_attribute]
      elsif object.respond_to? key_or_attribute
        object.send key_or_attribute
      end
    end
    
    WAYPOINT_FORMAT = [:street, 
                       :address, 
                       :city, 
                       ",", 
                       :state, 
                       :province, 
                       :state_province, 
                       :country, 
                       :postal_code]

    def format_waypoint(waypoint)
      return waypoint if waypoint.instance_of? String
      
      if WAYPOINT_FORMAT
          .find_all { |el| el.instance_of? Symbol }
          .any? { |key| has_key_or_attribute?(waypoint, key) }
        
        # find all matching elements
        q = WAYPOINT_FORMAT.map do |attr|
          attr.instance_of?(String) ? attr : get_by_key_or_attribute(waypoint, attr)
        end.find_all { |el| el }
        
        q.inject('') do |query, el|
          # if it's punctuation or the first character, don't put a space before it
          if el =~ /^[.,!?]$/ or query.length == 0
            "#{query}#{el}"
          else
            "#{query} #{el}"
          end
        end
      else
        # we didn't have any elements matching
        waypoint.to_s
      end
    end
  end

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
      raise "No route found." if resources  == nil or resources.length == 0

      primary_route = resources.first
      
      @distance = primary_route["travelDistance"]
      @distance_unit = primary_route["distanceUnit"].downcase.to_sym

      @duration = primary_route["travelDuration"]

      @route = primary_route
    end
  end
end
