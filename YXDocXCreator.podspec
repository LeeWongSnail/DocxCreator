#
# Be sure to run `pod lib lint YXDocXCreator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YXDocXCreator'
  s.version          = '0.1.0'
  s.summary          = 'A short description of YXDocXCreator.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/LeeWongSnail/DocxCreator'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LeeWong' => 'wangli_0632@163.com' }
  s.source           = { :git => 'git@github.com:LeeWongSnail/DocxCreator.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  
  s.subspec 'DocX' do |sp|
    sp.source_files = 'YXDocXCreator/Classes/DocX/**/*'
    sp.dependency 'YXDocXCreator/AEXML'
    sp.dependency 'YXDocXCreator/ZipFoundation'
  end
  
  s.subspec 'AEXML' do |sp|
    sp.source_files = 'YXDocXCreator/Classes/AEXML/**/*'
  end
  
  s.subspec 'ZipFoundation' do |sp|
    sp.source_files = 'YXDocXCreator/Classes/ZipFoundation/**/*'
  end

   s.resource_bundles = {
     'YXDocXCreator' => ['YXDocXCreateResource']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
