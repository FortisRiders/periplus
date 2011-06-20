require File.expand_path(File.dirname(__FILE__) + "/route")
require "cgi"

module Periplus
  class Request    
    def initialize(api_key)
      @api_key = api_key
    end
    
    BING_URL = "http://dev.virtualearth.net/REST/v1/"
    ROUTE_PATH = "Routes"
    LOCATION_PATH = "Locations"
    ROUTE_IMAGE_PATH = "Imagery/Map/Road/Routes/Driving"
    QUERY_IMAGE_PATH = "Imagery/Map/Road/"
    
    def route_details_url(waypoints, options = {})
      options = default_options(options).merge(hashify_waypoints(waypoints))
                                        .merge(:o => "json")

      "#{BING_URL}#{ROUTE_PATH}?#{options.to_params}"
    end

    def route_map_url(waypoints, options = {})
      options = options.merge(hashify_waypoints(waypoints))
                       .merge(:key => @api_key)
      "#{BING_URL}#{ROUTE_IMAGE_PATH}?#{options.to_params}"
    end

    def address_map_url(address, options = {})
      options = default_options(options)
      "#{BING_URL}#{QUERY_IMAGE_PATH}#{CGI.escape(format_waypoint(address))}?#{options.to_params}"
    end

    def location_details_url(address, options = {})
      options = default_options(options).merge(:o => "json")
                                        .merge(structure_address(address))
      "#{BING_URL}#{LOCATION_PATH}?#{options.to_params}"
    end

   private
    def default_options(given_options)
      given_options.merge(:key => @api_key)
    end

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
      if object.respond_to? :has_key?
        if object.has_key? key_or_attribute
          object[key_or_attribute]
        end
      elsif object.respond_to? key_or_attribute
        object.send key_or_attribute
      end
    end
    
    ADDRESS_STRUCTURE = {
      :street => :addressLine,
      :address => :addressLine,
      :city => :locality,
      :state => :adminDistrict,
      :province => :adminDistrict,
      :state_province => :adminDistrict,
      :country => :countryRegion,
      :postal_code => :postalCode,
      :zip_code => :postalCode,
      :zipcode => :postalCode,
      :zip => :postalCode
    }

    def structure_address(address)
      ADDRESS_STRUCTURE.inject({}) do |structured, key_val|
        unconverted, converted = key_val
        
        if has_key_or_attribute? address, converted
          structured[converted] = get_by_key_or_attribute address, converted
        elsif has_key_or_attribute? address, unconverted
          structured[converted] = get_by_key_or_attribute address, unconverted
        end
        structured
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
                       :postal_code,
                       :zipcode,
                       :zip_code,
                       :zip]

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
end
