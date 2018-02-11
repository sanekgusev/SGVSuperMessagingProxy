Pod::Spec.new do |s|
  s.name             = "SGVSuperMessagingProxy"
  s.version          = "3.0.0"
  s.cocoapods_version = '>= 1.0.0'
  s.summary          = "Invoke superclass method implementations of dynamically dispatched methods in Objective-C and Swift."
  s.description      = <<-DESC
                       This NSProxy/SwiftObject proxy allows one to invoke method implementations from any class in the inheritance hierarchy for any Objective-C object or invoke dynamically-dispatched method implementations for any Swift object.

                       On creation, the proxy is passed the object and optionally a class in that object's inheritance hierarchy.

                       Any message sent to the proxy will be executed as if it was invoked with the `super` keyword from within that object's class declaration.
                       DESC
  s.homepage         = "https://github.com/sanekgusev/SGVSuperMessagingProxy"
  s.license          = 'MIT'
  s.author           = { "Aleksandr Gusev" => "sanekgusev@gmail.com" }
  s.source           = { :git => "https://github.com/sanekgusev/SGVSuperMessagingProxy.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/sanekgusev'

  s.swift_version = '4.0'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.subspec 'Common' do |ss|
  	ss.source_files = 'Pod/Sources/Common/TrampolineMacros.h'
    ss.private_header_files = 'Pod/Sources/Common/TrampolineMacros.h'

    ss.ios.deployment_target = '7.0'
    ss.osx.deployment_target = '10.8'
    ss.watchos.deployment_target = '1.0'
    ss.tvos.deployment_target = '9.0'
  end

  s.subspec 'Objective-C' do |ss|
    ss.source_files = 'Pod/Sources/Objective-C/**/*.{h,c,m}'
    ss.private_header_files = 'Pod/Sources/Objective-C/ObjcTrampolines.h'
    ss.dependency 'SGVSuperMessagingProxy/Common'

    ss.ios.deployment_target = '7.0'
    ss.osx.deployment_target = '10.8'
    ss.watchos.deployment_target = '1.0'
    ss.tvos.deployment_target = '9.0'
  end

  s.subspec 'Swift' do |ss|
    ss.source_files = 'Pod/Sources/Swift/**/*.{h,c,swift}'
    ss.dependency 'SGVSuperMessagingProxy/Common'

    ss.ios.deployment_target = '8.0'
    ss.osx.deployment_target = '10.9'
    ss.watchos.deployment_target = '2.0'
    ss.tvos.deployment_target = '9.0'
  end

end
