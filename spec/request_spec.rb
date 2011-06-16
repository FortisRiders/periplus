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
end
