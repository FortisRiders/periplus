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

  it "generates a route map url correctly" do
    req = Periplus::Request.new 'fake_key'
    
    waypoints = ["New York, NY", "Buffalo, NY", "Louisville, KY"]
    url = req.route_map_url waypoints
    url.should == "http://dev.virtualearth.net/REST/v1/Imagery/Map/Road/Routes/Driving?wp.1=New%20York%2C%20NY&wp.2=Buffalo%2C%20NY&wp.3=Louisville%2C%20KY&key=fake_key"
  end

  it "generates an address map url correctly" do
    req = Periplus::Request.new 'fake_key'
    address = "Anchorage, AK"
    url = req.address_map_url address
    url.should == "http://dev.virtualearth.net/REST/v1/Imagery/Map/Road/Anchorage,%20AK?key=fake_key"
  end

  it "formats an address object correctly" do
    class PeriplusAddress
      attr_accessor :address,
        :city,
        :state,
        :country,
        :postal_code
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

  it "formats an address object correctly with latitude/longitude" do
    class PeriplusAddress
      attr_accessor :address, 
        :city,
        :state,
        :country,
        :postal_code,
        :latitude,
        :longitude  
    end

    address = PeriplusAddress.new 
    address.address = "1600 Pennsylvania Ave"
    address.city = "Washington"
    address.state = "DC"
    address.country = "US"
    address.postal_code = 20500
    address.latitude = "40.32332"
    address.longitude = "-2.32142"
    
    req = Periplus::Request.new 'fake key'
    formatted = req.send :format_waypoint, address

    formatted.should == "40.32332,-2.32142"
  end

  it "builds a location details url correctly" do
    address = {
      :street => "1600 Pennsylvania Ave",
      :city => "Washington",
      :state => "DC",
      :country => "US",
      :zip => 20500
    }

    req = Periplus::Request.new 'fake key'
    url = req.location_details_url address
    url.should == "http://dev.virtualearth.net/REST/v1/Locations?key=fake%20key&o=json&addressLine=1600%20Pennsylvania%20Ave&locality=Washington&adminDistrict=DC&countryRegion=US&postalCode=20500"
  end

  it "builds a location details url from a query string correctly" do
    address = "1600 Pennsylvania Ave Washington, DC"
    req = Periplus::Request.new 'fake key'
    url = req.location_details_url address
    url.should == "http://dev.virtualearth.net/REST/v1/Locations?key=fake%20key&o=json&query=1600%20Pennsylvania%20Ave%20Washington%2C%20DC"
  end

  it "builds a location details url correctly with a place name" do
    address = {
      :name => "The White House",
      :city => "Washington",
      :state => "DC",
      :country => "US",
      :zip => 20500
    }

    req = Periplus::Request.new 'fake key'
    url = req.location_details_url address
    url.should == "http://dev.virtualearth.net/REST/v1/Locations?key=fake%20key&o=json&addressLine=The%20White%20House&locality=Washington&adminDistrict=DC&countryRegion=US&postalCode=20500"
  end

  it "builds a location details url correctly with a place name and an address" do
    address = {
      :name => "The White House",
      :street => "1600 Pennsylvania Ave",
      :city => "Washington",
      :state => "DC",
      :country => "US",
      :zip => 20500
    }

    req = Periplus::Request.new 'fake key'
    url = req.location_details_url address
    url.should == "http://dev.virtualearth.net/REST/v1/Locations?key=fake%20key&o=json&addressLine=1600%20Pennsylvania%20Ave&locality=Washington&adminDistrict=DC&countryRegion=US&postalCode=20500"
  end

  it "formats pushpins correctly" do
    req = Periplus::Request.new 'fake key'

    pushpin = {:latitude => 1337, :longitude => 42.24}
    formatted = req.send :format_pushpin, pushpin
    formatted.should == "1337,42.24;;"

    pushpin = {:latitude => 1337, :longitude => 42.24, :label => "pi"}
    formatted = req.send :format_pushpin, pushpin
    formatted.should == "1337,42.24;;pi"

    pushpin = {:latitude => 1337, :longitude => 42.24, :type => 3, :label => "pi"}
    formatted = req.send :format_pushpin, pushpin
    formatted.should == "1337,42.24;3;pi"
  end

  it "formats a route url correctly with pushpins" do
    req = Periplus::Request.new 'fake_key'
    
    waypoints = ["New York, NY", "Buffalo, NY", "Louisville, KY"]
    url = req.route_map_url waypoints, [{:latitude => 1337, :longitude => 42}, {:latitude => 42, :longitude => 1337, :label => "sw"}]
    url.should == "http://dev.virtualearth.net/REST/v1/Imagery/Map/Road/Routes/Driving?wp.1=New%20York%2C%20NY&wp.2=Buffalo%2C%20NY&wp.3=Louisville%2C%20KY&key=fake_key&pp=1337,42;;&pp=42,1337;;sw"
  end
end
