Pod::Spec.new do |s|
  s.name          = 'FlowGraphDotConverterCore'
  s.version       = '0.5.0'
  s.summary       = 'FlowGraph code to dot converter'
  s.homepage      = 'https://github.com/objective-audio/FlowGraphDotConverter'
  s.license       = { :type => 'MIT' }
  s.author        = { 'Yuki Yasoshima' => 'yukiyasos@gmail.com' }
  s.osx.deployment_target = '10.13'
  s.requires_arc  = true
  s.source        = { :git => 'https://github.com/objective-audio/FlowGraphDotConverter.git', :tag => s.version.to_s }
  s.source_files  = 'Sources/FlowGraphDotConverterCore/*.swift'
  s.swift_version = '4.2'
  s.platform      = :osx, '10.13'

  s.dependency 'SourceKittenFramework'
  s.dependency 'FlowGraph'
end
