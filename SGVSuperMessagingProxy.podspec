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
    ss.source_files = 'Pod/Classes/NSObject+SGVSuperMessaging.{h,m}'
    ss.dependency 'SGVSuperMessagingProxy/Proxy'
  end

  s.subspec 'Swift' do |ss|
    ss.osx.deployment_target = '10.9'
    ss.source_files = 'Pod/Classes/SuperMessageable.swift'
    ss.dependency 'SGVSuperMessagingProxy/Proxy'
  end

  s.subspec 'Proxy' do |ss|
  	ss.source_files = 'Pod/Classes/SGVSuperMessagingProxy.{h,m}'
  end

  s.default_subspec = 'Swift'
end
