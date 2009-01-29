# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{conditions_fu}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nathan Esquenazi", "Jeff Smick"]
  s.date = %q{2009-01-29}
  s.description = %q{README}
  s.email = %q{sprsquish@gmail.com}
  s.files = ["init.rb", "TODO.txt", "VERSION.yml", "lib/conditions_fu.rb", "test/conditions_fu_test.rb", "test/database.yml", "test/fixtures", "test/fixtures/people.yml", "test/schema.rb", "test/test_helper.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/sprsquish/conditions_fu}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{README}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
