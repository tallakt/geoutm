module GeoUtm
  class Ellipsoid
    attr_reader :name, :radius, :eccentricity


    def initialize(name, radius, eccentricity)
      @name, @radius, @eccentricity = name, radius, eccentricity
    end

    def Ellipsoid.lookup(name)
      List[normalize_name name.to_s]
    end

    def Ellipsoid.list_names
      List.keys.sort.map do |k|
        List[k].name
      end
    end

    def Ellipsoid.each
      List.keys.sort do |k|
        yield List[k]
      end
    end

    private

    def Ellipsoid.normalize_name(name)
      name.gsub(/[\s\-\(\)]/, '').upcase
    end

    def Ellipsoid.generate_list
      result = {}
      data = [
              ["Airy", 6377563, 0.00667054],
              ["Australian National", 6378160, 0.006694542],
              ["Bessel 1841", 6377397, 0.006674372],
              ["Bessel 1841 (Nambia) ", 6377484, 0.006674372],
              ["Clarke 1866", 6378206, 0.006768658],
              ["Clarke 1880", 6378249, 0.006803511],
              ["Everest", 6377276, 0.006637847],
              ["Fischer 1960 (Mercury) ", 6378166, 0.006693422],
              ["Fischer 1968", 6378150, 0.006693422],
              ["GRS 1967", 6378160, 0.006694605],
              ["GRS 1980", 6378137, 0.00669438],
              ["Helmert 1906", 6378200, 0.006693422],
              ["Hough", 6378270, 0.00672267],
              ["International", 6378388, 0.00672267],
              ["Krassovsky", 6378245, 0.006693422],
              ["Modified Airy", 6377340, 0.00667054],
              ["Modified Everest", 6377304, 0.006637847],
              ["Modified Fischer 1960", 6378155, 0.006693422],
              ["South American 1969", 6378160, 0.006694542],
              ["WGS 60", 6378165, 0.006693422],
              ["WGS 66", 6378145, 0.006694542],
              ["WGS-72", 6378135, 0.006694318],
              ["WGS-84", 6378137, 0.00669438 ],
      ]
      data.each do |item|
        el = Ellipsoid.new *item
        result[normalize_name el.name] = el
      end
    end

    List = Ellipsoid::generate_list
  end

end
