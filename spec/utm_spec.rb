require File.dirname(__FILE__) + '/spec_helper.rb'

module GeoUtm
  # http://rspec.info/
  describe UTM do
    before :each do
      # some random points
      @p1 = UTM.new '60J', 484713.786930711, 7128217.21692427, Ellipsoid::lookup('Bessel 1841 Nambia')
      @p2 = UTM.new '27E', 646897.012158895, 3049077.01849759, Ellipsoid::lookup(:airy)
      @p3 = UTM.new '37T', 581477.812337138, 5020289.06897684, Ellipsoid::lookup('bessel 1841')
      @p4 = UTM.new '37T', 677938.186800496, 5048262.27080925, Ellipsoid::lookup('bessel 1841')
      @p5 = UTM.new '32V', 285505.3, 6557462.8
    end

    it "should report zone number" do
      @p1.zone_number.should == 60
      @p2.zone_number.should == 27
      @p3.zone_number.should == 37
      @p4.zone_number.should == 37
      @p5.zone_number.should == 32
    end


    it 'should report zone bands' do
      @p1.zone_band.should == 'J'
      @p2.zone_band.should == 'E'
      @p3.zone_band.should == 'T'
      @p4.zone_band.should == 'T'
      @p5.zone_band.should == 'V'
    end

    it "should calculate distance between points" do
      @p3.distance_to(@p4).should be_within(0.0001).of(100434.575034537)
      @p4.distance_to(@p3).should be_within(0.0001).of(100434.575034537)
      @p4.distance_to(@p4).should be_within(0.0001).of(0.0)
    end
    
    it "should not calculate distances between different zones" do
      lambda {@p1.distance_to(@p4)}.should raise_error
    end

    it "should calculate distance to LatLon coordinate" do
      @p3.distance_to(@p4.to_lat_lon).should be_within(0.001).of(100434.575034537)
    end
    
    it "should convert correctly for 32V" do
      @p5.to_lat_lon.to_s.should == "59.102298N 11.254186E"
    end

    it 'should format as string' do
      @p1.to_s.should == '60J 484713.79 7128217.22'
    end

    it 'should not accept invalid zone letters' do
      lambda {UTMZones::split_zone '56Y'}.should raise_error
      lambda {UTMZones::split_zone '56I'}.should raise_error
      lambda {UTMZones::split_zone '56O'}.should raise_error
      lambda {UTMZones::split_zone '56A'}.should raise_error
    end

    it 'should not accept invalid zone numbers' do 
      lambda {UTMZones::split_zone '00C'}.should raise_error
      lambda {UTMZones::split_zone '61C'}.should raise_error
    end

    it 'should accept valid UTM zones' do
      lambda {UTMZones::split_zone '51C'}.should_not raise_error
    end

    it 'should calculate correct longitude origin' do
      UTMZones::lon_origin('32U').should == 9
      UTMZones::lon_origin('32R').should == 9
      UTMZones::lon_origin('32W').should == 9
      UTMZones::lon_origin('32V').should == 15
      UTMZones::lon_origin('32X').should == 9
      UTMZones::lon_origin('40H').should == 57
    end
  end
end
