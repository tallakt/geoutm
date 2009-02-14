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
    end

    it "should calculate distance between points" do
      @p3.distance_to(@p4).should be_close(100434.575034537, 0.0001)
      @p4.distance_to(@p3).should be_close(100434.575034537, 0.0001)
      @p4.distance_to(@p4).should be_close(0.0, 0.0001)
    end
    
    it "should not calculate distances between different zones" do
      lambda {@p1.distance_to(@p4)}.should raise_error
    end

    it "should calculate distance to LatLon coordinate" do
      @p3.distance_to(@p4.to_lat_lon).should be_close(100434.575034537, 0.001)
    end

    it 'should format as string' do
      @p1.to_s.should == '60J 484713.79 7128217.22'
    end

    it 'should not accept invalid zone letters' do
      lambda {UTM::split_zone '56Y'}.should raise_error
      lambda {UTM::split_zone '56I'}.should raise_error
      lambda {UTM::split_zone '56O'}.should raise_error
      lambda {UTM::split_zone '56A'}.should raise_error
    end

    it 'should not accept invalid zone numbers' do 
      lambda {UTM::split_zone '00C'}.should raise_error
      lambda {UTM::split_zone '61C'}.should raise_error
    end

    it 'should accept valid UTM zones' do
      lambda {UTM::split_zone '51C'}.should_not raise_error
    end
  end
end
