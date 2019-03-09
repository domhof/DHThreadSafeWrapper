Pod::Spec.new do |spec|
  spec.name         = 'DHThreadSafeWrapper'
  spec.version      = '1.0.0'
  spec.summary      = 'Combines a value with a dispatch queue. The dispatch queue is used handle concurrent read/write access.'

  spec.homepage     = 'https://github.com/domhof/DHThreadSafeWrapper'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }

  spec.author             = { 'Dominik Hofer' => 'me@dominikhofer.com' }
  spec.social_media_url   = 'https://twitter.com/dominikhofer'

  spec.source       = { :git => 'https://github.com/domhof/DHThreadSafeWrapper.git', :tag => "#{spec.version}" }
  spec.source_files  = 'DHThreadSafeWrapper/**/*.swift'

  spec.ios.deployment_target = '9.0'
  spec.osx.deployment_target = '10.12'
  spec.tvos.deployment_target = '10.0'
  spec.watchos.deployment_target = '3.0'

  spec.swift_version = '4.2'
end
