Pod::Spec.new do |s|
  s.name             = "SGVSuperMessagingProxy"
  s.version          = "1.0.0"
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

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/NSObject+SGVSuperMessaging.{h,m}'

  s.subspec 'Core' do |ss|
  	ss.source_files = 'Pod/Classes/SGVSuperMessagingProxy.{h,m}'
  end
end
