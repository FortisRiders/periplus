require "httparty"

module Periplus
  class Request
    include HTTParty
    format :json
    
    def initialize(key)
      @key = key
    end
    
    def route(waypoints, options = {})
      base_url = "http://dev.virtualearth.net/REST/v1/Routes"
      options = options.merge hashify_waypoints(waypoints)
      options = options.merge :o => "json", :key => @key
      puts "sending options: #{options}"
      Route.new (self.class.get base_url, :query => options.merge(hashify_waypoints(waypoints)))
    end

    private
    def hashify_waypoints(waypoints)
      counter = 1
      waypoints.inject({}) do |hash, waypoint|
        hash["wp.#{counter}"] = format_waypoint(waypoint)
        counter = counter + 1
        hash
      end
    end

    def format_waypoint(waypoint)
      return waypoint if waypoint.instance_of? String
      
      location_elements = [:street, :address, :city, ",", :state, :province, :country, :postal_code]
      if location_elements.find_all { |el| el.instance_of? Symbol }.any? do |key|
          waypoint.respond_to? key or (waypoint.respond_to? :has_key? and waypoint.has_key? key)
        end
        
        q = location_elements.map do |attr|
          if attr.instance_of? String
            attr
          elsif waypoint.respond_to? :has_key? and waypoint.has_key? attr
            waypoint[attr]
          elsif waypoint.respond_to? attr
            waypoint.send attr
          end
        end.find_all { |el| el }
        
        q.inject('') do |query, el|
          if el =~ /^[.,!?]$/ or query.length == 0
            "#{query}#{el}"
          else
            "#{query} #{el}"
          end
        end.strip
      else
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

      raise "An error has occurred communicating with the Bing Maps service. HTTP Status: #{@response.response.code} : #{@response.response.message}" if @response.response.kind_of? Net::HTTPClientError

      parse_resource_sets
    end

    def parse_resource_sets      
      resource_sets = @response.parsed_response["resourceSets"]
      raise "No route found." if resource_sets == nil or resource_sets.length == 0
      raise "No route found." if resource_sets.first["resources"] == nil or resource_sets.first["resources"].length == 0

      primary_route = resource_sets.first["resources"].first
      
      @distance = primary_route["travelDistance"]
      @distance_unit = primary_route["distanceUnit"].downcase.to_sym

      @duration = primary_route["travelDuration"]

      @route = primary_route
    end
  end
end
