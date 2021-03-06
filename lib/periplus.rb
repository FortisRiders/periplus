require "httparty"
require File.expand_path(File.dirname(__FILE__) + "/periplus/bing_response")
require File.expand_path(File.dirname(__FILE__) + "/periplus/request")
require File.expand_path(File.dirname(__FILE__) + "/periplus/route")
require File.expand_path(File.dirname(__FILE__) + "/periplus/location")

module Periplus
  include HTTParty
  format :json

  @verbose = false
  
  def self.verbose=(value)
    @verbose = value
  end
  
  def self.verbose
    @verbose
  end
  
  def self.route_details(key, waypoints, options = {})
    request = Request.new key
    url = request.route_details_url waypoints, options
    Route.new (get url)
  end

  def self.location_details(key, address, options = {})
    request = Request.new key
    url = request.location_details_url address, options
    Location.new (get url)
  end

  def self.route_map_url(key, waypoints, pushpins = [], options = {})
    request = Request.new key
    request.route_map_url waypoints, pushpins, options
  end

  def self.address_map_url(key, address, pushpins = [], options = {})
    request = Request.new key
    request.address_map_url address, pushpins, options
  end
end
