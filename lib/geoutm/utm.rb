require 'geoutm/constants'
require 'geoutm/ellipsoid'
require 'geoutm/latlon'

module GeoUtm
  class UTM
    include Math

    attr_reader :n, :e, :zone, :zone_number, :zone_letter

    def initialize(zone, e, n)
      @n, @e, @zone = n, e, zone
      @zone_number, @zone_letter = UTM::split_zone @zone
    end

    def to_s
      '%s %d %d' % [zone, e, n]
    end

    def to_lat_lon(ellipsoid = Ellipsoid::lookup(:wgs84))
      k0 = 0.9996
      x  = @e - 500000 # Remove Longitude offset
      y  = @n

      # Set hemisphere (1=Northern, 0=Southern)
      y    -= 10000000.0 unless northern_hemisphere?

      longorigin = (@zone_number - 1)*6 - 180 + 3
      ecc = ellipsoid.eccentricity
      eccPrimeSquared = (ecc)/(1-ecc)
      m  = y / k0
      mu = m / (ellipsoid.radius * (1 - ecc / 4 - 3 * ecc ** 2 / 64 - 5 * ecc ** 3 / 256))
      e1 = (1 - sqrt(1 - ecc)) / (1 + sqrt(1 - ecc))
      phi1rad = mu +
        (3 * e1 / 2 - 27 * e1 ** 3 / 32) * sin(2 * mu) +
        (21 * e1 ** 2 / 16 - 55 * e1 ** 4 / 32) * sin(4 * mu) +
        (151 * e1 ** 3 / 96) * sin(6 * mu)
      phi1 = phi1rad * Rad2Deg
      n1 = ellipsoid.radius / sqrt(1 - ecc * sin(phi1rad) ** 2)
      t1 = tan(phi1rad) ** 2
      c1 = ecc * cos(phi1rad)**2
      r1 = ellipsoid.radius * (1 - ecc) / ((1 - ecc * sin(phi1rad) ** 2) ** 1.5)
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

    def UTM.split_zone(zone_in)      
      m = zone_in.match /^(\d+)([CDEFGHJKLMNPQRSTUVWX])$/
      throw RuntimeException.new('Illegal zone: ' + zone_in) unless m
      return m[1].to_i, m[2]
    end

    def UTM.validate_zone(zone_in)
      UTM::split_zone zone_in # throw exception
      true
    end

    private

    def northern_hemisphere?
      @zone_letter.match /[NPQRSTUVWX]/
    end
  end
end
