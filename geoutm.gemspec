# -*- encoding: utf-8 -*-

require File.join(File.dirname(__FILE__), "lib", "geoutm.rb")

Gem::Specification.new do |s|
  s.name = "geoutm"
  s.version = GeoUtm::VERSION
	s.platform = Gem::Platform::RUBY
  s.authors = ["Tallak Tveide"]
  s.email = ["tallak@tveide.net"]
  s.extra_rdoc_files = ["README.rdoc"]
  s.has_rdoc = true
  s.homepage = %q{http://www.github.com/tallakt/geoutm}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_path = "lib"
  s.description = %q{Conversion between latitude and longitude coordinates and UTM coordiantes}
  s.summary = "Converting map coordinates"
	s.files = Dir.glob("{spec,lib}/**/*") + %w(LICENCE README.rdoc History.txt)
	s.add_development_dependency "rspec"
	s.rubyforge_project = "geoutm"
end
