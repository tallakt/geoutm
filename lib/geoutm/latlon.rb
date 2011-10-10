require 'geoutm/constants'
require 'geoutm/ellipsoid'
require 'geoutm/utm'

module GeoUtm
  class LatLon
    include Math
    attr_reader :lat, :lon
    
    @@special_zone_offsets = {"32V" => 6}

    def initialize(lat, lon)
      throw RuntimeException.new("Invalid longitude #{lon}") unless (-180.0...180.0).member? lon
      @lat, @lon = lat, lon
    end
    
    def to_s
      north_south = if @lat >= 0.0 then 'N' else 'S' end
      east_west = if @lon >= 0.0 then 'E' else 'W' end
      '%0.6f%s %0.6f%s' % [@lat.abs, north_south, @lon.abs, east_west]
    end

    def to_utm(ellipsoid = Ellipsoid::lookup(:wgs84), zone = nil)
      lat_radian = Deg2Rad * @lat
      long_radian = Deg2Rad * long2

      k0 = 0.9996 # scale

      if zone
        zn, zl = UTM::split_zone zone
      else
        zn = calc_utm_zone_number
        zl = calc_utm_zone_letter
      end

      eccentricity = ellipsoid.eccentricity
      special_zone_offset = @@special_zone_offsets["#{zn}#{zl}"] || 0
      longorigin = (zn - 1) * 6 - 180 + 3 + special_zone_offset
      longoriginradian = Deg2Rad * longorigin
      eccentprime = ellipsoid.eccentricity/(1.0-eccentricity)

      n = ellipsoid.radius / sqrt(1 - eccentricity * sin(lat_radian)*sin(lat_radian))
      t = tan(lat_radian) * tan(lat_radian)
      c = eccentprime * cos(lat_radian)*cos(lat_radian)
      a = cos(lat_radian) * (long_radian - longoriginradian)
      m = ellipsoid.radius * (
        (1 - eccentricity/4 - 3 * eccentricity * eccentricity/64 - 
          5 * eccentricity * eccentricity * eccentricity/256) * lat_radian - 
        (3 * eccentricity/8 + 3 * eccentricity * eccentricity/32 + 
          45 * eccentricity * eccentricity * eccentricity/1024) * sin(2 * lat_radian) + 
        (15 * eccentricity * eccentricity/256 +
          45 * eccentricity * eccentricity * eccentricity/1024) * sin(4 * lat_radian) - 
        (35 * eccentricity * eccentricity * eccentricity/3072) * sin(6 * lat_radian)
      )

      utm_easting = k0*n*(a+(1-t+c)*a*a*a/6 + (5-18*t+t*t+72*c-58*eccentprime)*a*a*a*a*a/120) + 500000.0

      utm_northing = k0 * ( m + n*tan(lat_radian) * ( a*a/2+(5-t+9*c+4*c*c)*a*a*a*a/24 + 
                                   (61-58*t+t*t+600*c-330*eccentprime) * a*a*a*a*a*a/720))
      utm_northing += 10000000.0 if @lat < 0
 
      UTM.new '%d%s' % [zn, zl], utm_easting, utm_northing, ellipsoid
    end

    private 

    def calc_utm_zone_letter
      case @lat
        when 72.0..84.0
          'X'
        when 64.0..72.0
          'W'
        when 56.0..64.0
          'V'
        when 48.0..56.0
          'U'
        when 40.0..48.0
          'T'
        when 32.0..40.0
          'S'
        when 24.0..32.0
          'R'
        when 16.0..24.0
          'Q'
        when 8.0..16.0
          'P'
        when 0.0..8.0
          'N'
        when -8.0..0.0
          'M'
        when -16.0..-8.0
          'L'
        when -24.0..-16.0
          'K'
        when -32.0..-24.0
          'J'
        when -40.0..-32.0
          'H'
        when -48.0..-40.0
          'G'
        when -56.0..-48.0
          'F'
        when -64.0..-56.0
          'E'
        when -72.0..-64.0
          'D'
        when -80.0..-72.0
          'C'
        else
          throw RuntimeException.new("Latitude #{@lat} out of UTM range")
        end
    end

    def long2
      @lon - ((@lon + 180)/360).to_i * 360
    end

    def calc_utm_zone_number
      zone = ((long2 + 180)/6).to_i + 1;
      if (56.0..64.0).member?(@lat) && (3.0..12.0).member?(long2)
        zone = 32
      end

      if (72.0..84.0).member? @lat
        case long2
           when 0.0..9.0
             zone = 31
           when 9.0..21.0
             zone = 33
           when 21.0..33.0
             zone = 35
           when 33.0..42.0
             zone = 37
         end
      end
      zone
    end
  end
end
