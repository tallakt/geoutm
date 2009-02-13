require 'geoutm/constants'
require 'geoutm/ellipsoid'
require 'geoutm/utm'

module GeoUtm
  class LatLon
    attr_reader :lat, :lon

    def initialize(lat, lon)
      throw RuntimeException.new "Invalid longitude #{lon}" if (lon < -180.0 || lon > 180.0)
      @lat, @lon = lat, lon
    end
    
    def to_utm(ellipsoid = Ellipsoid::lookup(:wgs84))
      long2 = @lon - ((@lon + 180)/360).to_i * 360;
      zone = ((long2 + 180)/6).to_i + 1;

      lat_radian = Deg2Rad * @lat
      long_radian = Deg2Rad * long2

      k0 = 0.9996 # scale

      if (56.0..64.0).member?(@lat) && (3.0..12.0).member?(long2)
        zone = 32
      end

      if (72.0..84.0).member? @lat
        zone = 
          case long2
             when 0.0..9.0
               31
             when 9.0..21.0
               33
             when 21.0..33.0
               35
             when 33.0..42.0
               37
             else
               zone
           end
      end

      eccentricity = ellipsoid.eccentricity
      longorigin = (zone - 1) * 6 - 180 + 3
      longoriginradian = Deg2Rad * longorigin
      eccentprime = ellipsoid.eccentricity/(1.0-eccentricity)

      n = ellipsoid.radius / Math::sqrt(1 - eccentricity * Math::sin(lat_radian)*Math::sin(lat_radian))
      t = Math::tan(lat_radian) * Math::tan(lat_radian)
      c = eccentprime * Math::cos(lat_radian)*Math::cos(lat_radian)
      a = Math::cos(lat_radian) * (long_radian - longoriginradian)
      m = ellipsoid.radius * (
        (1 - eccentricity/4 - 3 * eccentricity * eccentricity/64 - 
          5 * eccentricity * eccentricity * eccentricity/256) * lat_radian - 
        (3 * eccentricity/8 + 3 * eccentricity * eccentricity/32 + 
          45 * eccentricity * eccentricity * eccentricity/1024) * Math::sin(2 * lat_radian) + 
        (15 * eccentricity * eccentricity/256 +
          45 * eccentricity * eccentricity * eccentricity/1024) * Math::sin(4 * lat_radian) - 
        (35 * eccentricity * eccentricity * eccentricity/3072) * Math::sin(6 * lat_radian)
      )

      utm_easting = k0*n*(a+(1-t+c)*a*a*a/6 + (5-18*t+t*t+72*c-58*eccentprime)*a*a*a*a*a/120) + 500000.0

      utm_northing = k0 * ( m + n*Math::tan(lat_radian) * ( a*a/2+(5-t+9*c+4*c*c)*a*a*a*a/24 + 
                                   (61-58*t+t*t+600*c-330*eccentprime) * a*a*a*a*a*a/720))
      utm_northing += 10000000.0 if @lat < 0
 
      UTM.new utm_northing, utm_easting, calc_utm_zone
    end

    private 

    def calc_utm_zone
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
          throw RuntimeException.new "Latitude #{@lat} out of UTM range"
        end
    end
  end
end
