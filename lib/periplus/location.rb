module Periplus
  class Location < BingResponse
    attr_accessor :latitude
    attr_accessor :longitude
    attr_accessor :address
    attr_accessor :confidence
    attr_accessor :entity_type
    attr_accessor :name

    def parse
      super()

      point = @primary_resource["point"]
      @latitude, @longitude = point["coordinates"]
      @name = @primary_resource["name"]
      @address =  @primary_resource["address"]
      @confidence = @primary_resource["confidence"].downcase.to_sym
      @entity_type = @primary_resource["entityType"].downcase.to_sym
    end
  end
end
