require File.dirname(__FILE__) + '/spec_helper.rb'

require 'yaml'

module GeoUtm
  # http://rspec.info/
  describe GeoUtm do
    before :each do
      @testdata = nil
      File.open(File.join(File.dirname(__FILE__), 'testdata.yaml')) {|f| @testdata = YAML::load f }
    end
    
    it "should return an ellipsoid for every test sample" do
      @testdata.each do |sample|
        Ellipsoid::lookup(sample[:ellipsoid]).should be_a_kind_of(Ellipsoid)
      end
    end
    
    it "should convert from lat/lon to UTM" do
      @testdata.each do |sample|
        latlon = LatLon.new sample[:latitude].to_f, sample[:longitude].to_f
        utm = latlon.to_utm :ellipsoid => sample[:ellipsoid]
        utm.n.should be_within(0.01).of(sample[:northing].to_f)
        utm.e.should be_within(0.01).of(sample[:easting].to_f)
        utm.zone.should == sample[:zone]
      end
    end
    
    it "should use the zone to determine if within the northern or southern emisphere" do
      latlon = LatLon.new(-0.001, -51.081063)
      utm = latlon.to_utm zone: '22N'
      utm.n.should be_within(1).of(-111)
      utm.zone.should == "22N"
    end

    it "should convert from UTM to lat/lon" do
      @testdata.each do |sample|
        utm = UTM.new sample[:zone], sample[:easting].to_f, sample[:northing].to_f, sample[:ellipsoid]
        latlon = utm.to_lat_lon
        latlon.lat.should be_within(0.01).of(sample[:latitude].to_f)
        latlon.lon.should be_within(0.01).of(sample[:longitude].to_f)
      end
    end
  end
end
