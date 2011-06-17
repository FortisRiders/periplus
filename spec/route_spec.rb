require 'periplus'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Route" do
  it "throws an exception if the httparty response is HTTP status 4xx" do
    http_error = Net::HTTPUnauthorized.new "1_1", 401, "Unauthorized"
    response = mock HTTParty::Response, :response => http_error
    
    begin
      Periplus::Route.new(response)
    rescue Exception => e
      e.message.should == "An error has occurred communicating with the Bing Maps service. HTTP Status: 401 (Unauthorized)"
    end
  end

  it "throws an exception if the httparty response contains no routes" do
    http_ok = Net::HTTPOK.new "1_1", 200, "OK"
    empty_resource_sets = {
      "resourceSets" => []
    }

    empty_single_resource_set = {
      "resourceSets" => [{"resources" => []}]
    }

    [empty_resource_sets, empty_single_resource_set].each do |parsed_response|
      response = mock HTTParty::Response, :response => http_ok, :parsed_response => parsed_response
      
      begin
        Periplus::Route.new(response)
      rescue Exception => e
        e.message.should == "No route found."
      end
    end
  end

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
