require 'periplus'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Route" do
  it "stores shortcut attributes properly" do
    http_ok = Net::HTTPOK.new "1_1", 200, "OK"
    parsed_response = {
      "resourceSets" => [{
                           "resources" => [{
                                             "travelDistance" => 50,
                                             "travelDuration" => 12345,
                                             "distanceUnit" => "Mile"
                                           }]
                         }]
    }

    response = mock HTTParty::Response, :response => http_ok, :parsed_response => parsed_response
    route = Periplus::Route.new response
    
    route.distance.should == 50
    route.duration.should == 12345
    route.distance_unit.should == :mile
    route.route.should == parsed_response["resourceSets"].first["resources"].first
  end
end
