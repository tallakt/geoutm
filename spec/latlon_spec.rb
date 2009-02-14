require File.dirname(__FILE__) + '/spec_helper.rb'

module GeoUtm
  # http://rspec.info/
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
  end
end
