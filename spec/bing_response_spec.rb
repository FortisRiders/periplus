require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Periplus::BingResponse do
  it "throws an exception if the httparty response is HTTP status 4xx" do
    http_error = Net::HTTPUnauthorized.new "1_1", 401, "Unauthorized"
    response = mock HTTParty::Response, :response => http_error
    
    lambda do
      Periplus::BingResponse.new(response)
    end.should raise_error(RuntimeError, "An error has occurred communicating with the Bing Maps service. HTTP Status: 401 (Unauthorized)")
  end

  it "provides helpful debugging information for service failrues" do
    http_error = Net::HTTPNotFound.new("1_1", 404, "Not Found")
    http_error.stub!(:body).and_return(
      {:some_really_long_properties_that_extend => {:deeply_past_the_place_where => {:they_wrap => "stuff"}}}
    )
    http_request = HTTParty::Request.new "GET", "/API/cheese"
    response = mock HTTParty::Response, :response => http_error,
                                        :request => http_request
    
    Periplus.verbose = true
    
    lambda do
      begin
        Periplus::BingResponse.new(response)
      rescue RuntimeError => e
        e.message.should == <<-EOF
An error has occurred communicating with the Bing Maps service. HTTP Status: 404 (Not Found)
  URL: /API/cheese
  Response:
  {:some_really_long_properties_that_extend=>
  {:deeply_past_the_place_where=>{:they_wrap=>"stuff"}}}
        EOF
        raise e
      end
    end.should raise_error(RuntimeError)
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
