#
# Be sure to run `pod lib lint UIDesignKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'UIDesignKit'
  s.version          = '5.0.6'
  s.summary          = 'Remotely tweak and change colours, fonts, style and design parameters without recompiling your app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
UIDesignKit fills the need for allowing users to change things like the background colour of a label or the font of text on a button from a remote website in realtime. This means that developers can concentrate on the application logic and layout of the app rather than the precise design values. This also works well for multitennanted application support for different designs per tennant.
                       DESC

  s.homepage         = 'https://github.com/willpowell8/UIDesignKit_iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Will Powell' => 'willpowell8@gmail.com' }
  s.source           = { :git => 'https://github.com/willpowell8/UIDesignKit_iOS.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/willpowelluk'

    s.swift_version = '5.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'UIDesignKit/Classes/**/*'
  
   s.resource_bundles = {
       'UIDesignKit' => ['UIDesignKit/Assets/{*.png,*.storyboard}']
   }

    s.frameworks = 'UIKit'
    s.dependency 'Socket.IO-Client-Swift', '~> 15.0.0'
    s.dependency 'SDWebImage'

end
