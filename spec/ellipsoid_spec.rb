require File.dirname(__FILE__) + '/spec_helper.rb'

module GeoUtm
  # http://rspec.info/
  describe Ellipsoid do
    before :each do
      @wgs84 = Ellipsoid::lookup('WGS-84')
    end

    it 'should perform lookup with different case' do
      Ellipsoid::lookup('Wgs-84').should be(@wgs84)
      Ellipsoid::lookup('wgs-84').should be(@wgs84)
    end

    it 'should perform lookup ignoring space and -' do
      Ellipsoid::lookup('WGS84').should be(@wgs84)
      Ellipsoid::lookup('wGS 84').should be(@wgs84)
    end

    it 'should lookup with symbol names' do
      Ellipsoid::lookup(:wgs84).should be(@wgs84)
    end
  end
end
