module GeoUtm
  # This class represents the ellipsoid used to convert from latitude/longitude into UTM coordinates. All
  # operations default to using WGS-84. 
  class Ellipsoid
      ELLIPSOID_DATA = [
        [ "Airy", 6377563, 0.00667054],
        [ "Australian National", 6378160, 0.006694542],
        [ "Bessel 1841", 6377397, 0.006674372],
        [ "Bessel 1841 Nambia", 6377484, 0.006674372],
        [ "Clarke 1866", 6378206.4, 0.006768658],
        [ "Clarke 1880", 6378249, 0.006803511],
        [ "Everest 1830 India", 6377276, 0.006637847],
        [ "Fischer 1960 Mercury", 6378166, 0.006693422],
        [ "Fischer 1968", 6378150, 0.006693422],
        [ "GRS 1967", 6378160, 0.006694605],
        [ "GRS 1980", 6378137, 0.00669438],
        [ "Helmert 1906", 6378200, 0.006693422],
        [ "Hough", 6378270, 0.00672267],
        [ "International", 6378388, 0.00672267],
        [ "Krassovsky", 6378245, 0.006693422],
        [ "Modified Airy", 6377340, 0.00667054],
        [ "Modified Everest", 6377304, 0.006637847],
        [ "Modified Fischer 1960", 6378155, 0.006693422],
        [ "South American 1969", 6378160, 0.006694542],
        [ "WGS 60", 6378165, 0.006693422],
        [ "WGS 66", 6378145, 0.006694542],
        [ "WGS-72", 6378135, 0.006694318],
        [ "WGS-84", 6378137, 0.00669438 ],
        [ "Everest 1830 Malaysia", 6377299, 0.006637847],
        [ "Everest 1956 India", 6377301, 0.006637847],
        [ "Everest 1964 Malaysia and Singapore", 6377304, 0.006637847],
        [ "Everest 1969 Malaysia", 6377296, 0.006637847],
        [ "Everest Pakistan", 6377296, 0.006637534],
        [ "Indonesian 1974", 6378160, 0.006694609],
      ]
    attr_reader :name, :radius, :eccentricity


    def initialize(name, radius, eccentricity)
      @name, @radius, @eccentricity = name, radius, eccentricity
    end

    # Find a preconfigured ellipsoid
    # @param [String] the name of the ellipsoid. Spaces, case and `-` are ignored
    # @return [Ellipsoid]
    def Ellipsoid.lookup(name)
      result = List[normalize_name(name.to_s)]
			raise GeoUtmException, 'Ellipsoid not found: ' + name.to_s unless result
			result
    end


    # @see #lookup
		def Ellipsoid.[](name)
			lookup name
		end

    # Use this method when you get an ellipsoid-like as a parameter to convert to an ellipsoid
    # @param [Ellipsoid, String, Symbol]
    # @return [Ellipsoid]
		def Ellipsoid.clean_parameter(ellipsoid_or_name)
			case ellipsoid_or_name
			when Ellipsoid
				ellipsoid_or_name
			else
				lookup ellipsoid_or_name.to_s
			end
		end

    # @return [Array<String>] A list of all the available ellipsoid names
    def Ellipsoid.list_names
      List.keys.sort.map do |k|
        List[k].name
      end
    end

    # Iterate over the ellipsoid names
    def Ellipsoid.each
      List.keys.sort do |k|
        yield List[k]
      end
    end


    # :nodoc:
    def Ellipsoid.normalize_name(name)
      name.gsub(/[\s\-\(\)]/, '').upcase
    end

    # :nodoc:
    def Ellipsoid.generate_list
      result = {}
      ELLIPSOID_DATA.each do |item|
        el = Ellipsoid.new *item
        result[normalize_name(el.name)] = el
      end
      result
    end

    List = Ellipsoid::generate_list
    WGS84 = Ellipsoid[:wgs84]
  end

end
