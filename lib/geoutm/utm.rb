require 'geoutm/constants'
require 'geoutm/ellipsoid'
require 'geoutm/latlon'
require 'geoutm/zone'

module GeoUtm
  class UTM
    include Math

    attr_reader :n, :e, :zone, :ellipsoid

		SPECIAL_ZONES = {
			'31V' => {:lat => (56.0..64.0), :lon => (0.0..3.0)}, 
			'32V' => {:lat => (56.0..64.0), :lon => (3.0..12.0)}, 
			'31X' => {:lat => (72.0..84.0), :lon => (0.0..9.0)}, 
			'33X' => {:lat => (72.0..84.0), :lon => (9.0..21.0)}, 
			'35X' => {:lat => (72.0..84.0), :lon => (21.0..33.0)}, 
			'37X' => {:lat => (72.0..84.0), :lon => (33.0..42.0)}
		}
    
    def initialize(zone, e, n, ellipsoid = Ellipsoid[:wgs84])
      @n, @e, @zone, @ellipsoid = n, e, zone, Ellipsoid::clean_parameter(ellipsoid)
    end

		def zone_letter
      @zone_number, @zone_letter = UTM::split_zone @zone
			@zone_letter
		end

		def zone_number
      @zone_number, @zone_letter = UTM::split_zone @zone
			@zone_number
		end


    def to_s
      '%s %.2f %.2f' % [zone, e, n]
    end

    def to_lat_lon
      k0 = 0.9996
      x  = @e - 500000 # Remove Longitude offset
      y  = @n

      # Set hemisphere (1=Northern, 0=Southern)
      y    -= 10000000.0 unless northern_hemisphere?

      longorigin = Zone.longorigin(@zone_number, @zone_letter)

      ecc = @ellipsoid.eccentricity
      eccPrimeSquared = (ecc)/(1-ecc)
      m  = y / k0
      mu = m / (@ellipsoid.radius * (1 - ecc / 4 - 3 * ecc ** 2 / 64 - 5 * ecc ** 3 / 256))
      e1 = (1 - sqrt(1 - ecc)) / (1 + sqrt(1 - ecc))
      phi1rad = mu +
        (3 * e1 / 2 - 27 * e1 ** 3 / 32) * sin(2 * mu) +
        (21 * e1 ** 2 / 16 - 55 * e1 ** 4 / 32) * sin(4 * mu) +
        (151 * e1 ** 3 / 96) * sin(6 * mu)
      phi1 = phi1rad * Rad2Deg
      n1 = @ellipsoid.radius / sqrt(1 - ecc * sin(phi1rad) ** 2)
      t1 = tan(phi1rad) ** 2
      c1 = ecc * cos(phi1rad)**2
      r1(3.0..12.0) = @ellipsoid.radius * (1 - ecc) / ((1 - ecc * sin(phi1rad) ** 2) ** 1.5)
      d = x / (n1 * k0)
      latitude = phi1rad-
        (n1 * tan(phi1rad) / r1) * (d * d / 2 - 
                                    (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * eccPrimeSquared) * d ** 4 / 24 +
                                    (61 + 90 * t1 + 298 * c1 + 45 * t1 * t1 - 
                                     252 * eccPrimeSquared - 3 * c1 * c1) * d ** 6 / 720)
      latitude = latitude * Rad2Deg
      longitude = (d - (1 + 2 * t1 + c1) * d ** 3 / 6 +
                   (5 - 2 * c1 + 28 * t1 - 3 * c1 * c1 + 8 * eccPrimeSquared +
                    24 * t1 * t1) * d ** 5 / 120) / cos(phi1rad)
      longitude = longorigin + longitude * Rad2Deg
      LatLon.new latitude, longitude
    end

    def distance_to(other)
      if other.class == LatLon
        other = other.to_utm(@ellipsoid, @zone)
      end
      unless other.zone == @zone
        raise GeoUtmException, 'Cannot calc distance for points in different zones - convert first'
      end
      sqrt((@n - other.n) ** 2.0 + (@e - other.e) ** 2.0) 
    end

    def UTM.split_zone(zone_in)      
      m = zone_in.match /^(\d+)([CDEFGHJKLMNPQRSTUVWX])$/
      raise GeoUtmException, 'Illegal zone: ' + zone_in unless m
      zn, zl = m[1].to_i, m[2]
      raise GeoUtmException, 'Illegal zone: ' + zone_in unless (1..60).member? zn
      return zn, zl
    end

    def UTM.validate_zone(zone_in)
      UTM::split_zone zone_in # throw exception
      true
    end

    private

    def northern_hemisphere?
      @zone_letter.match /[NPQRSTUVWX]/
    end

		def lon_origin_for_zone(zone) 
		end
  end
end
