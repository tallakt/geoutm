require 'geoutm/ellipsoid'
require 'geoutm/utm'
require 'geoutm/geo_utm_exception'

module GeoUtm
  class LatLon
    include Math
    attr_reader :lat, :lon
    
    # Create a new coordinate instance based on latitude and longitude
    #
    # @param [Float] the coordinate latitude
    # @param [Float] the coordinate longitude
    def initialize(lat, lon)
      raise GeoUtmException, "Invalid longitude #{lon}" unless (-180.0...180.0).member? lon
      @lat, @lon = lat, lon
    end
    
    # Textual representation of the coordinate
    def to_s
      north_south = if @lat >= 0.0 then 'N' else 'S' end
      east_west = if @lon >= 0.0 then 'E' else 'W' end
      '%0.6f%s %0.6f%s' % [@lat.abs, north_south, @lon.abs, east_west]
    end

    # Convert the coordinate in latutude/longitude into the UTM coordinate system
    #
    # @option options [String,Symbol,Ellipsoid] :ellipsoid The ellipsoid to use
    # @option options [String] :zone Force the coordiante into another UTM zone than it belongs. Use this to compare two coordinates in different zones
    # @return [UTM] The converted UTM representation
    def to_utm(options = {})
      UTM::latlon_to_utm self, options
    end
  end
end
