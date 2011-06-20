require "httparty"
require File.expand_path(File.dirname(__FILE__) + "/periplus/request")
require File.expand_path(File.dirname(__FILE__) + "/periplus/route")

module Periplus
  include HTTParty
  format :json

  def self.route_details(key, waypoints, options = {})
    request = Request.new key
    url = request.route_details_url waypoints, options
    Route.new (get url)
  end

  def self.route_map_url(key, waypoints, options = {})
    request = Request.new key
    request.route_map_url waypoints, options
  end

  def self.address_map_url(key, address, options = {})
    request = Request.new key
    request.address_map_url address, options
  end
end
