require 'periplus'

describe "Periplus" do
  it "should get route details" do
    request = mock Periplus::Request
    request.should_receive(:route_details_url).and_return("http://awesome")
    Periplus::Request.should_receive(:new).and_return(request)
    
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
    Periplus.should_receive(:get).and_return(response)

    route = Periplus.route_details "KEY", [], {}
    route.distance.should == 50
    route.duration.should == 12345
    route.distance_unit.should == :mile
    route.route.should == parsed_response["resourceSets"].first["resources"].first
    
  end
end
