# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{geoutm}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tallak Tveide"]
  s.date = %q{2009-02-13}
  s.description = %q{}
  s.email = ["tallak@tveide.net"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc"]
  s.files = ["History.txt", "lib/geoutm/.ellipsoid.rb.swp", "lib/geoutm/latlon.rb", "lib/geoutm/constants.rb", "lib/geoutm/utm.rb", "lib/geoutm/ellipsoid.rb", "lib/geoutm/.utm.rb.swp", "lib/geoutm/.latlon.rb.swp", "lib/geoutm.rb", "LICENCE", "Manifest.txt", "PostInstall.txt", "Rakefile", "README.rdoc", "script/console", "script/generate", "script/destroy", "spec/geoutm_spec.rb", "spec/spec.opts", "spec/testdata.yaml", "spec/spec_helper.rb", "spec/.geoutm_spec.rb.swp", "tasks/rspec.rake"]
  s.has_rdoc = true
  s.homepage = %q{The Mercator projection was first invented to help mariners. They needed to be able to take a course and know the distance traveled, and draw a line on the map which showed the day's journey. In order to do this, Mercator invented a projection which preserved length, by projecting the earth's surface onto a cylinder, sharing the same axis as the earth itself.}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{geoutm}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.0"])
    else
      s.add_dependency(%q<newgem>, [">= 1.2.3"])
      s.add_dependency(%q<hoe>, [">= 1.8.0"])
    end
  else
    s.add_dependency(%q<newgem>, [">= 1.2.3"])
    s.add_dependency(%q<hoe>, [">= 1.8.0"])
  end
end
