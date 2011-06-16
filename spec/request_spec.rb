require 'periplus'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Request" do
  it "formats an address hash correctly" do
    req = Periplus::Request.new 'fake_key'
    address_hash = {
      :street      => "123 Maple Lane",
      :city        => "Beverly Hills",
      :state       => "California",
      :country     => "US",
      :postal_code => 90210
    }
    
    formatted = req.send :format_waypoint, address_hash
    
    formatted.should == "123 Maple Lane Beverly Hills, California US 90210"
  end

  it "hashifies a list of waypoints correctly for the HTTParty query" do
    req = Periplus::Request.new 'fake_key'
    
    waypoints = ["New York, NY", "Buffalo, NY", "Louisville, KY"]
    hash = req.send :hashify_waypoints, waypoints

    hash.should == {
      "wp.1" => "New York, NY",
      "wp.2" => "Buffalo, NY",
      "wp.3" => "Louisville, KY"
    }
  end

  it "formats an address object correctly" do
    class PeriplusAddress
      attr_accessor :address
      attr_accessor :city
      attr_accessor :state
      attr_accessor :country
      attr_accessor :postal_code
    end

    address = PeriplusAddress.new 
    address.address = "1600 Pennsylvania Ave"
    address.city = "Washington"
    address.state = "DC"
    address.country = "US"
    address.postal_code = 20500
    
    req = Periplus::Request.new 'fake key'
    formatted = req.send :format_waypoint, address

    formatted.should == "1600 Pennsylvania Ave Washington, DC US 20500"
  end
end
