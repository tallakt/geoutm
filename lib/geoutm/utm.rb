require 'geoutm/ellipsoid'
require 'geoutm/latlon'
require 'enumerator'
require 'geoutm/geo_utm_exception'
require 'geoutm/utm_zones'

module GeoUtm
  class UTM
    attr_reader :n, :e, :zone, :ellipsoid
    
    def initialize(zone, e, n, ellipsoid = Ellipsoid::WGS84)
      @n, @e, @zone, @ellipsoid = n, e, zone, Ellipsoid::clean_parameter(ellipsoid)
    end

    def UTM.latlon_to_utm(latlon, options = {})
			ellipsoid = (options[:ellipsoid] && Ellipsoid::clean_parameter(options[:ellipsoid])) || Ellipsoid::WGS84

      lat_rad = Math::PI / 180.0 * latlon.lat
      k0 = 0.9996 # scale
      zone = options[:zone] || UTMZones::calc_utm_zone(latlon.lat, latlon.lon)

      eccentricity = ellipsoid.eccentricity
      eccentprime = ellipsoid.eccentricity/(1.0-eccentricity)

      n = ellipsoid.radius / Math::sqrt(1 - eccentricity * Math::sin(lat_rad)*Math::sin(lat_rad))
      t = Math::tan(lat_rad) * Math::tan(lat_rad)
      c = eccentprime * Math::cos(lat_rad)*Math::cos(lat_rad)
      a = Math::cos(lat_rad) * Math::PI / 180.0 * (UTMZones::clean_longitude(latlon.lon) - UTMZones::lon_origin(zone))
      m = ellipsoid.radius * (
          (1 - eccentricity/4 - 3 * eccentricity * eccentricity/64 - 
            5 * eccentricity * eccentricity * eccentricity/256) * lat_rad - 
          (3 * eccentricity/8 + 3 * eccentricity * eccentricity/32 + 
            45 * eccentricity * eccentricity * eccentricity/1024) * Math::sin(2 * lat_rad) + 
          (15 * eccentricity * eccentricity/256 +
            45 * eccentricity * eccentricity * eccentricity/1024) * Math::sin(4 * lat_rad) - 
          (35 * eccentricity * eccentricity * eccentricity/3072) * Math::sin(6 * lat_rad)
        )
      utm_easting = k0*n*(a+(1-t+c)*a*a*a/6 + (5-18*t+t*t+72*c-58*eccentprime)*a*a*a*a*a/120) + 500000.0
      utm_northing = k0 * ( m + n*Math::tan(lat_rad) * ( a*a/2+(5-t+9*c+4*c*c)*a*a*a*a/24 + 
                                   (61-58*t+t*t+600*c-330*eccentprime) * a*a*a*a*a*a/720))
      utm_northing += 10000000.0 if latlon.lat < 0
      UTM.new zone, utm_easting, utm_northing, ellipsoid
    end

		def zone_letter
      UTMZones::split_zone(@zone).last
		end

    alias :zone_band :zone_letter

		def zone_number
      UTMZones::split_zone(@zone).first.to_i
		end


    def to_s
      '%s %.2f %.2f' % [zone, e, n]
    end

    def to_lat_lon
      k0 = 0.9996
      x  = @e - 500000 # Remove Longitude offset
      y  = @n

      # Set hemisphere (1=Northern, 0=Southern)
      y    -= 10000000.0 unless UTMZones::northern_hemisphere? @zone

      ecc = @ellipsoid.eccentricity
      eccPrimeSquared = (ecc)/(1-ecc)
      m  = y / k0
      mu = m / (@ellipsoid.radius * (1 - ecc / 4 - 3 * ecc ** 2 / 64 - 5 * ecc ** 3 / 256))
      e1 = (1 - Math::sqrt(1 - ecc)) / (1 + Math::sqrt(1 - ecc))
      phi1rad = mu +
        (3 * e1 / 2 - 27 * e1 ** 3 / 32) * Math::sin(2 * mu) +
        (21 * e1 ** 2 / 16 - 55 * e1 ** 4 / 32) * Math::sin(4 * mu) +
        (151 * e1 ** 3 / 96) * Math::sin(6 * mu)
      n1 = @ellipsoid.radius / Math::sqrt(1 - ecc * Math::sin(phi1rad) ** 2)
      t1 = Math::tan(phi1rad) ** 2
      c1 = ecc * Math::cos(phi1rad)**2
      r1 = @ellipsoid.radius * (1 - ecc) / ((1 - ecc * Math::sin(phi1rad) ** 2) ** 1.5)
      d = x / (n1 * k0)
      latitude_rad = phi1rad-
        (n1 * Math::tan(phi1rad) / r1) * (d * d / 2 - 
                                    (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * eccPrimeSquared) * d ** 4 / 24 +
                                    (61 + 90 * t1 + 298 * c1 + 45 * t1 * t1 - 
                                     252 * eccPrimeSquared - 3 * c1 * c1) * d ** 6 / 720)
      latitude_deg = latitude_rad * 180.0 * Math::PI
      lon_tmp = (d - (1 + 2 * t1 + c1) * d ** 3 / 6 +
                   (5 - 2 * c1 + 28 * t1 - 3 * c1 * c1 + 8 * eccPrimeSquared +
                    24 * t1 * t1) * d ** 5 / 120) / Math::cos(phi1rad)
      longitude_deg = UTMZones::lon_origin(@zone) + lon_tmp * 180.0 * Math::PI
      LatLon.new latitude_deg, longitude_deg
    end

    def distance_to(other)
      if other.class == LatLon
        other = UTM::latlon_to_utm other, :ellipsoid => @ellipsoid, :zone => @zone
      end
      unless other.zone == @zone
        raise GeoUtmException, 'Cannot calc distance for points in different zones - convert first'
      end
      Math::sqrt((@n - other.n) ** 2.0 + (@e - other.e) ** 2.0) 
    end

  end
end
