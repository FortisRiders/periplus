require 'periplus'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Location" do
  it "stores shortcut attibutes property" do
    http_ok = Net::HTTPOK.new "1_1", 200, "OK"
    parsed_response = {
      "resourceSets" => [{
                           "resources" => [{
                                             "point" => {
                                               "coordinates" => [5, -5]
                                             },
                                             "address" => {:my_address => "junk"},
                                             "confidence" => "High",
                                             "entityType" => "Address"
                                           }]
                         }]
    }

    response = mock HTTParty::Response, :response => http_ok, :parsed_response => parsed_response
    location = Periplus::Location.new response
    location.latitude.should == 5
    location.longitude.should == -5
    location.address.should == {:my_address => "junk"}
    location.confidence.should == :high
    location.entity_type.should == :address
  end
end
