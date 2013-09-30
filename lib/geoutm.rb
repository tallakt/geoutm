$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'geoutm/utm'
require 'geoutm/latlon'

module GeoUtm
  VERSION = '1.0.2'
end
