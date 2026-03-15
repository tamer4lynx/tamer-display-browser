package = JSON.parse(File.read(File.join(__dir__, "..", "..", "package.json")))

Pod::Spec.new do |s|
  s.name             = 'tamerdisplaybrowser'
  s.version          = package["version"]
  s.summary          = 'Display URLs in system browser for Lynx.'
  s.description      = package["description"]
  s.homepage         = "https://github.com/nanofuxion"
  s.license          = package["license"]
  s.authors          = package["author"]
  s.source           = { :path => '.' }
  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.0'
  s.source_files     = 'tamerdisplaybrowser/Classes/**/*.swift'
  s.frameworks       = 'SafariServices', 'AuthenticationServices'
  s.dependency "Lynx"
end
