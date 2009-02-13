require File.dirname(__FILE__) + '/spec_helper.rb'

require 'yaml'

module GeoUtm
  # http://rspec.info/
  describe "UTM to Lat/lon conversion library - test samples" do
    before :each do
      @testdata = nil
      File.open(File.join(File.dirname(__FILE__), 'testdata.yaml')) {|f| @testdata = YAML::load f }
    end
    
    it "Should return an ellipsoid for every test sample" do
      @testdata.each do |sample|
        Ellipsoid::lookup(sample[:ellipsoid]).should be_a_kind_of Ellipsoid
      end
    end
    
    it "Should convert all test samples correctly from lat/lon to UTM" do
      @testdata.each do |sample|
        lat, lon, n, e = sample.values_at([:latitude, :longitude, :northing, :easting]).map {|n| n.to_f}
        latlon = LatLon.new sample[:latitude].to_f, sample[:longitude].to_f
        utm = latlon.to_utm Ellipsoid::lookup(sample[:ellipsoid])
        utm.n.should be_close(sample[:northing].to_f, 0.1)
        utm.e.should be_close(sample[:easting].to_f, 0.1)
        utm.zone.should be sample[:zone]
      end
    end

    it "Should convert all test samples correctly from UTM to lat/lon" do
      violated 'Not written'
    end
  end
end
