require 'periplus'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BingResponse" do
  it "throws an exception if the httparty response is HTTP status 4xx" do
    http_error = Net::HTTPUnauthorized.new "1_1", 401, "Unauthorized"
    response = mock HTTParty::Response, :response => http_error
    
    begin
      Periplus::BingResponse.new(response)
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
        Periplus::BingResponse.new(response)
      rescue Exception => e
        e.message.should == "Not found."
      end
    end
  end
end
