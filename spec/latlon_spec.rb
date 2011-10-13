require File.dirname(__FILE__) + '/spec_helper.rb'

module GeoUtm
  describe LatLon do
    before :each do
      # some random points
      @p1 = LatLon.new -25.9668774017417, 176.847283481794
      @p2 = LatLon.new 62.6643472980663, -18.1318011641218
    end

    it 'should format as string' do
      @p1.to_s.should == '25.966877S 176.847283E'
      @p2.to_s.should == '62.664347N 18.131801W'
    end

		it 'should raise an exception unless longitude is outside -180..180' do
			lambda { LatLon.new 0.0, -200.0 }.should raise_error(GeoUtm::GeoUtmException)
			lambda { LatLon.new 0.0, 200.0 }.should raise_error(GeoUtm::GeoUtmException)
		end

		it 'should raise an exception unless latitude is outside -80..84' do
			lambda { LatLon.new(-81.0, 0.0).to_utm }.should raise_error(GeoUtm::GeoUtmException)
			lambda { LatLon.new( 85.0, 0.0).to_utm }.should raise_error(GeoUtm::GeoUtmException)
		end

		it 'should accept an ellipsoid name in to_utm initializer' do
			lambda {@p1.to_utm :wgs84}.should_not raise_error
		end
  end
end
