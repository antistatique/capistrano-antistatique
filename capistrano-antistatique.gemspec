lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'capistrano-antistatique'
  spec.version       = '0.1.0'
  spec.authors       = ['Kevin Wenger', 'Yann Lugrin']
  spec.email         = ['dev@antistatique.net']

  spec.summary       = %q{Antistaique capistrano receipes.}
  spec.homepage      = 'http://antistatique.net'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata['allowed_push_host'] = 'NOT ALLOWED'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'capistrano', '~> 3.5.0'
  spec.add_dependency 'capistrano-composer', '~> 0.0.6'
  spec.add_dependency 'slackistrano', '~> 3.1.1'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake'
end
