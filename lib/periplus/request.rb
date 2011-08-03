require File.expand_path(File.dirname(__FILE__) + "/route")
require "uri"

module Periplus
  class Request    
    def initialize(api_key)
      @api_key = api_key
    end
    
    BING_MAPS_URL = "http://dev.virtualearth.net/REST/v1/"
    ROUTE_PATH = "Routes"
    LOCATION_PATH = "Locations"
    ROUTE_IMAGE_PATH = "Imagery/Map/Road/Routes/Driving"
    QUERY_IMAGE_PATH = "Imagery/Map/Road/"
    
    def route_details_url(waypoints, options = {})
      options = default_options(options).merge(hashify_waypoints(waypoints))
                                        .merge(:o => "json")

      "#{BING_MAPS_URL}#{ROUTE_PATH}?#{options.to_params}"
    end

    # Generate a URL for a routes map.
    #
    # * waypoints is a list of hashes or objects with properties or keys like
    #   street, address, city, state, province, etc.
    # * pushpins is an optional list of hashes with :latitude, :longitude, 
    #   :type (optional -- 1, 2, 3, etc. per the bing spec) or :label (optional -- no longer than 2 characters per bing spec)
    # * options is a hash that gets turned directly into url params for bing
    def route_map_url(waypoints, pushpins = [], options = {})
      options = options.merge(hashify_waypoints(waypoints))
                       .merge(:key => @api_key)
      base = "#{BING_MAPS_URL}#{ROUTE_IMAGE_PATH}?#{options.to_params}"
      if pushpins and pushpins.length > 0
        formatted_pins = pushpins.map {|p| "pp=#{format_pushpin(p)}" }.join '&'
        base = "#{base}&#{formatted_pins}" if pushpins
      end
      base
    end

    # Generate a URL for a location map
    #
    # * address is a hash or object with properties or keys like
    #   street, address, city, state, province, etc.
    # * pushpins is an optional list of hashes with :latitude, :longitude, 
    #   :type (optional -- 1, 2, 3, etc. per the bing spec) or :label (optional -- no longer than 2 characters per bing spec)
    # * options is a hash that gets turned directly into url params for bing
    def address_map_url(address, pushpins = [], options = {})
      options = default_options(options)
      base = "#{BING_MAPS_URL}#{QUERY_IMAGE_PATH}#{URI.escape(format_waypoint(address))}?#{options.to_params}"
      if pushpins and pushpins.length > 0
        formatted_pins = pushpins.map {|p| "pp=#{format_pushpin(p)}" }.join '&'
        base = "#{base}&#{formatted_pins}" if pushpins
      end
      base
    end

    def location_details_url(address, options = {})
      options = default_options(options).merge(:o => "json")
                                        .merge(structure_address(address))
      "#{BING_MAPS_URL}#{LOCATION_PATH}?#{options.to_params}"
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

    def format_pushpin(pushpin)
      "#{pushpin[:latitude]},#{pushpin[:longitude]};#{pushpin[:type] || ""};#{pushpin[:label] || ""}"
    end
    
    ADDRESS_STRUCTURE = {
      :street => :addressLine,
      :address => :addressLine,
      :name => :addressLine,
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
      return {:query => address} if address.kind_of? String

      ADDRESS_STRUCTURE.inject({}) do |structured, key_val|
        unconverted, converted = key_val
        
        if has_key_or_attribute? address, converted
          structured[converted] ||= get_by_key_or_attribute address, converted
        elsif has_key_or_attribute? address, unconverted
          structured[converted] ||= get_by_key_or_attribute address, unconverted
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
      
      # use lat/long if provided
      if has_key_or_attribute?(waypoint, :latitude) and
          has_key_or_attribute?(waypoint, :longitude)
        latitude = get_by_key_or_attribute waypoint, :latitude
        longitude = get_by_key_or_attribute waypoint, :longitude
        return "#{latitude},#{longitude}" if latitude and longitude
      end
      
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
