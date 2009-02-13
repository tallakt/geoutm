require 'geoutm/constants'
require 'geoutm/ellipsoid'
require 'geoutm/latlon'

module GeoUtm
  class UTM
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

      longorigin      = (@zone_number - 1)*6 - 180 + 3
      eccentricity = ellipsoid.eccentricity
      eccPrimeSquared = (eccentricity)/(1-eccentricity)
      m  = y/k0
      mu = m/(ellipsoid.radius*(1-eccentricity/4-3*eccentricity*eccentricity/64-
                                5*eccentricity*eccentricity*eccentricity/256))

      e1 = (1-Math::sqrt(1-eccentricity))/(1+Math::sqrt(1-eccentricity))
      phi1rad = mu +
        (3*e1/2-27*e1*e1*e1/32)*Math::sin(2*mu) +
        (21*e1*e1/16-55*e1*e1*e1*e1/32)*Math::sin(4*mu) +
        (151*e1*e1*e1/96)*Math::sin(6*mu)
      phi1 = phi1rad * Rad2Deg
      n1 = ellipsoid.radius/Math::sqrt(1-eccentricity*Math::sin(phi1rad)*Math::sin(phi1rad))
      t1 = Math::tan(phi1rad)*Math::tan(phi1rad)
      c1 = eccentricity*Math::cos(phi1rad)*Math::cos(phi1rad)
      r1 = ellipsoid.radius * (1-eccentricity) / ((1-eccentricity*Math::sin(phi1rad)*Math::sin(phi1rad))**1.5)
      d = x/(n1*k0)

      latitude = phi1rad-
        (n1*Math::tan(phi1rad)/r1)*(d*d/2-(5+3*t1+10*c1-4*c1*c1-9*eccPrimeSquared)*d*d*d*d/24+
                                    (61+90*t1+298*c1+45*t1*t1-252*eccPrimeSquared-3*c1*c1)*d*d*d*d*d*d/720)
      latitude = latitude * Rad2Deg

      longitude = (d-(1+2*t1+c1)*d*d*d/6+
                   (5-2*c1+28*t1-3*c1*c1+8*eccPrimeSquared+24*t1*t1)*d*d*d*d*d/120)/Math::cos(phi1rad)
      longitude = longorigin + longitude * Rad2Deg;

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
