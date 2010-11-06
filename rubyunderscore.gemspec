# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rubyunderscore}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Ribeiro"]
  s.date = %q{2010-11-06}
  s.description = %q{It allows you to create simple blocks by using underscore symbol}
  s.email = %q{danrbr+rubyunderscore@gmail.com}
  s.extra_rdoc_files = [
    "README.md",
     "TODO"
  ]
  s.files = [
    ".gitignore",
     "README.md",
     "Rakefile",
     "TODO",
     "VERSION",
     "example.rb",
     "lib/ruby_underscore.rb",
     "lib/tree_converters.rb",
     "spec/ruby_underscore_spec.rb",
     "spec/tree_converters_spec.rb"
  ]
  s.homepage = %q{http://github.com/danielribeiro/RubyUnderscore}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Simple way to create simple blocks}
  s.test_files = [
    "spec/tree_converters_spec.rb",
     "spec/ruby_underscore_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ParseTree>, ["= 3.0.5"])
      s.add_runtime_dependency(%q<ruby2ruby>, [">= 0"])
    else
      s.add_dependency(%q<ParseTree>, ["= 3.0.5"])
      s.add_dependency(%q<ruby2ruby>, [">= 0"])
    end
  else
    s.add_dependency(%q<ParseTree>, ["= 3.0.5"])
    s.add_dependency(%q<ruby2ruby>, [">= 0"])
  end
end
