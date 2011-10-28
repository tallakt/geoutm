require 'geoutm/geo_utm_exception'

module GeoUtm
  # This module is used by the UTM class and is generally never used directly
  module UTMZones 
    # :nodoc:
		SPECIAL_ZONES = {
			'31V' => {:lat => (56.0..64.0), :lon => (0.0..3.0), :lon_origin => 3.0}, 
			'32V' => {:lat => (56.0..64.0), :lon => (3.0..12.0), :lon_origin => 15.0}, 
			'31X' => {:lat => (72.0..84.0), :lon => (0.0..9.0), :lon_origin => 3.0}, 
			'33X' => {:lat => (72.0..84.0), :lon => (9.0..21.0), :lon_origin => 15.0}, 
			'35X' => {:lat => (72.0..84.0), :lon => (21.0..33.0), :lon_origin => 27.0}, 
			'37X' => {:lat => (72.0..84.0), :lon => (33.0..42.0), :lon_origin => 39.0}
		}

    BANDS = {
        'X' => 72.0..84.0,
        'W' => 64.0..72.0,
        'V' => 56.0..64.0,
        'U' => 48.0..56.0,
        'T' => 40.0..48.0,
        'S' => 32.0..40.0,
        'R' => 24.0..32.0,
        'Q' => 16.0..24.0,
        'P' => 8.0..16.0,
        'N' => 0.0..8.0,
        'M' => -8.0..0.0,
        'L' => -16.0..-8.0,
        'K' => -24.0..-16.0,
        'J' => -32.0..-24.0,
        'H' => -40.0..-32.0,
        'G' => -48.0..-40.0,
        'F' => -56.0..-48.0,
        'E' => -64.0..-56.0,
        'D' => -72.0..-64.0,
        'C' => -80.0..-72.0,
    }

    # :nodoc:
		def UTMZones.calc_utm_zone(lat, lon)
      search_for_special_zones(lat, lon) || calc_utm_default_zone(lat, lon)
		end

    # :nodoc:
    def UTMZones.search_for_special_zones(lat, lon)
      result = SPECIAL_ZONES.find {|k, v| v[:lat].member?(lat) && v[:lon].member?(lon)}
      result && result.first
    end

    # :nodoc:
		def UTMZones.calc_utm_default_zone(lat, lon)
      '%d%s' % [((clean_longitude(lon) + 180)/6).to_i + 1, calc_utm_default_letter(lat)]
		end

    # :nodoc:
    def UTMZones.lon_origin(zone)
      sp = SPECIAL_ZONES[zone]
      (sp && sp[:lon_origin]) || (zone_number_from_zone(zone) - 1) * 6 - 180 + 3
    end

    # :nodoc:
		def UTMZones.calc_utm_default_letter(lat)
      result = BANDS.find {|letter, lats| lats.member?(lat) }
      raise GeoUtmException, "Latitude #{lat} out of UTM range" unless result
      result.first
		end

    # :nodoc:
    def UTMZones.zone_number_from_zone(zone)
      UTMZones.split_zone(zone).first.to_i
    end

    # :nodoc:
    def UTMZones.split_zone(zone_in)      
      m = zone_in.match /^(\d+)([CDEFGHJKLMNPQRSTUVWX])$/
      raise GeoUtmException, 'Illegal zone: ' + zone_in unless m
      zn, zl = m[1].to_i, m[2]
      raise GeoUtmException, 'Illegal zone: ' + zone_in unless (1..60).member? zn
      return zn, zl
    end

    # :nodoc:
    def UTMZones.validate_zone(zone_in)
      UTMZones.split_zone zone_in # throw exception
      true
    end

    # :nodoc:
    def UTMZones.northern_hemisphere?(zone)
      zone.match /[NPQRSTUVWX]$/
    end

    # :nodoc:
    def UTMZones.clean_longitude(lon)
      lon - ((lon + 180)/360).to_i * 360
    end

  end
end

