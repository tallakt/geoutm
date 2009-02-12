require 'geoutm/constants'

module GeoUtm
  class Utm
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
      M  = y/k0
      mu = M/(ellipsoid.radius*(1-eccentricity/4-3*eccentricity*eccentricity/64-5*eccentricity*eccentricity*eccentricity/256))

      e1 = (1-Math::sqrt(1-eccentricity))/(1+Math::sqrt(1-eccentricity))
      phi1rad = mu +
        (3*e1/2-27*e1*e1*e1/32)*Math::sin(2*mu) +
        (21*e1*e1/16-55*e1*e1*e1*e1/32)*Math::sin(4*mu) +
        (151*e1*e1*e1/96)*sin(6*mu)
      phi1 = phi1rad * Rad2Deg
      N1 = ellipsoid.radius/Math::sqrt(1-eccentricity*Math::sin(phi1rad)*Math::sin(phi1rad))
      T1 = Math::tan(phi1rad)*Math::tan(phi1rad)
      C1 = eccentricity*Math::cos($phi1rad)*Math::cos($phi1rad)
      R1 = ellipsoid.radius * (1-eccentricity) / ((1-eccentricity*Math::sin(phi1rad)*Math::sin(phi1rad))**1.5)
      D = x/(N1*k0)

      Latitude = phi1rad-
        (N1*Math::tan(phi1rad)/R1)*(D*D/2-(5+3*T1+10*C1-4*C1*C1-9*eccPrimeSquared)*D*D*D*D/24+
                                    (61+90*T1+298*C1+45*T1*T1-252*eccPrimeSquared-3*C1*C1)*D*D*D*D*D*D/720)
      Latitude = Latitude * Rad2Deg

      Longitude = (D-(1+2*T1+C1)*D*D*D/6+
                   (5-2*C1+28*T1-3*C1*C1+8*eccPrimeSquared+24*T1*T1)*D*D*D*D*D/120)/Math::cos(phi1rad)
      Longitude = longorigin + Longitude * Rad2Deg;

      LatLon.new Latitude, Longitude
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
