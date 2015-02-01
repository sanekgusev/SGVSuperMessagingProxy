Pod::Spec.new do |s|
  s.name             = "SGVSuperMessagingProxy"
  s.version          = "1.0.0"
  s.summary          = "An NSProxy subclass for invoking superclass method implementations."
  s.description      = <<-DESC
                       An optional longer description of SGVSuperMessagingProxy

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/sanekgusev/SGVSuperMessagingProxy"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
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
