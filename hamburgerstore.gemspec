require 'rake'

spec = Gem::Specification.new do |s|
  s.name          = 'hamburgerstore'
  s.executables  << 'hamburgerstore.rb'
  s.license       = 'MIT'
  s.version       = '0.1.1'
  s.author        = [ "Jonny Sywulak", "Stelligent" ]
  s.email         = 'jonny@stelligent.com'
  s.homepage      = 'http://www.stelligent.com'
  s.summary       = "Data store for pipeline instance metadata. Nothing to do with hamburgers. Sorry."
  s.description   = "Hambuger Store is an easy, lightweight way to store data about your pipeline instances. As you go through your pipeline, you're going to produce a lot of information that's relevant to your pipeline instance, and having to store that in a text file or pass parameters between jobs can get very unwieldy very quickly. Hamburger Store utilizes two AWS services (Dyanmo DB and Key Management Service) to provide an easy way to securely store the data your pipeline needs, without the bother of having to set it up yourself."
  s.files       = ["lib/hamburgerstore.rb"]
  s.require_paths << 'lib'
  s.require_paths << 'bin'
  s.required_ruby_version = '>= 2.2.1'
  s.add_dependency('aws-sdk', '~> 2.1')
  s.add_dependency('trollop', '~> 2.1')
end
