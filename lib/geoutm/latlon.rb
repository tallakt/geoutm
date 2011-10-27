require 'geoutm/ellipsoid'
require 'geoutm/utm'
require 'geoutm/geo_utm_exception'

module GeoUtm
  class LatLon
    include Math
    attr_reader :lat, :lon
    
    def initialize(lat, lon)
      raise GeoUtmException, "Invalid longitude #{lon}" unless (-180.0...180.0).member? lon
      @lat, @lon = lat, lon
    end
    
    def to_s
      north_south = if @lat >= 0.0 then 'N' else 'S' end
      east_west = if @lon >= 0.0 then 'E' else 'W' end
      '%0.6f%s %0.6f%s' % [@lat.abs, north_south, @lon.abs, east_west]
    end

    def to_utm(ellipsoid = Ellipsoid::WGS84, options = {})
      UTM::latlon_to_utm self, options
    end
  end
end
