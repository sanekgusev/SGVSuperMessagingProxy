Pod::Spec.new do |s|
  s.name             = "SGVSuperMessagingProxy"
  s.version          = "2.0.0"
  s.cocoapods_version = '>= 1.0.0'
  s.summary          = "An NSProxy subclass for invoking superclass method implementations."
  s.description      = <<-DESC
                       This proxy allows one to invoke method implementations from any class in the inheritance hierarchy for any Objective-C object.

                       On creation, the proxy is passed the object and optionally a class in that object's inheritance hierarchy.

                       Any message send to a proxy will be executed as if it was invoked with a super keyword from inside that object's class declaration.
                       DESC
  s.homepage         = "https://github.com/sanekgusev/SGVSuperMessagingProxy"
  s.license          = 'MIT'
  s.author           = { "Alexander Gusev" => "sanekgusev@gmail.com" }
  s.source           = { :git => "https://github.com/sanekgusev/SGVSuperMessagingProxy.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sanekgusev'

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.8'
  s.watchos.deployment_target = '1.0'
  s.tvos.deployment_target = '9.0'

  s.subspec 'Objective-C' do |ss|
    ss.source_files = 'Pod/Sources/Objective-C/**/*.{h,c,m}'
    ss.private_header_files = 'Pod/Sources/Objective-C/ObjcTrampolines.h'
    ss.dependency 'SGVSuperMessagingProxy/Common'
  end

  s.subspec 'Swift' do |ss|
    ss.source_files = 'Pod/Sources/Swift/**/*.{h,c,swift}'
    ss.private_header_files = 'Pod/Sources/Swift/SwiftTrampolines.h'
    ss.dependency 'SGVSuperMessagingProxy/Common'
    ss.osx.deployment_target = '10.9'
    ss.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => "\"#{File.join(File.dirname(__FILE__), 'Pod', 'Sources', 'Swift', 'PrivateModulemap')}\"" }
    ss.preserve_paths = 'Pod/Sources/Swift/PrivateModulemap/module.map'
  end

  s.subspec 'Common' do |ss|
  	ss.source_files = 'Pod/Sources/Common/TrampolineMacros.h'
    ss.private_header_files = 'Pod/Sources/Common/TrampolineMacros.h'
  end

  s.default_subspec = 'Swift'
end
