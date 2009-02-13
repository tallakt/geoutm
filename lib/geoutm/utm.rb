require 'geoutm/constants'
require 'geoutm/ellipsoid'
require 'geoutm/latlon'

module GeoUtm
  class UTM
    attr_reader :n, :e, :zone, :zone_number, :zone_char

    def initialize(n, e, zone)
      throw RuntimeError.new 'Invalid zone: ' + zone unless valid_zone(zone)
      @n, @e, @z = n, e, zone
      tmp, @zone_char = @zone.match(/(\d+)([CDEFGHJKLMNPQRSTUVWX])/)[1..2]
      @zone_number = tmp.to_i
    end

    def to_lat_lon(ellipsoid = Ellipsoid::lookup(:wgs84))
      # todo: implement
      k0 = 0.9996
      x  = @e - 500000 # Remove Longitude offset
      y  = @n

      # Set hemisphere (1=Northern, 0=Southern)
      y    -= 10000000.0 unless northern_hemispehere?

      longorigin      = (@zone_number - 1)*6 - 180 + 3
      eccentricity = ellipsoid.eccentricity
      eccPrimeSquared = (eccentricity)/(1-eccentricity)
      m  = y/k0
      mu = m/(ellipsoid.radius*(1-eccentricity/4-3*eccentricity*eccentricity/64-5*eccentricity*eccentricity*eccentricity/256))

      e1 = (1-Math::sqrt(1-eccentricity))/(1+Math::sqrt(1-eccentricity))
      phi1rad = mu +
        (3*e1/2-27*e1*e1*e1/32)*Math::sin(2*mu) +
        (21*e1*e1/16-55*e1*e1*e1*e1/32)*Math::sin(4*mu) +
        (151*e1*e1*e1/96)*sin(6*mu)
      phi1 = phi1rad * Rad2Deg
      n1 = ellipsoid.radius/Math::sqrt(1-eccentricity*Math::sin(phi1rad)*Math::sin(phi1rad))
      t1 = Math::tan(phi1rad)*Math::tan(phi1rad)
      c1 = eccentricity*Math::cos($phi1rad)*Math::cos($phi1rad)
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

    private

    def northern_hemispehere?
      @zone_str.match /[NPQRSTUVWX]/
    end

    def valid_zone(zone)
      "CDEFGHJKLMNPQRSTUVWX".member? zone
    end
  end
end
