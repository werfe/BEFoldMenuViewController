#
# Be sure to run `pod lib lint BEFoldMenuViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BEFoldMenuViewController'
  s.version          = '0.1.0'
  s.summary          = 'Easy way to create slide out menu for your Objective-C project'


  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/werfe/BEFoldMenuViewController'
  # s.screenshots     = 'https://github.com/werfe/BEFoldMenuViewController/raw/master/BEFoldMenuViewControllerDemo/images/captureAnimation.gif?raw=true'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GiangVT' => 'werfeee@gmail.com' }
  s.source           = { :git => 'https://github.com/werfe/BEFoldMenuViewController.git', :tag => s.version.to_s }
  # s.social_media_url = ''

  s.ios.deployment_target = '7.0'

  s.source_files = 'BEFoldMenuViewController/Classes/**/*'
  
  # s.resource_bundles = {
  #   'BEFoldMenuViewController' => ['BEFoldMenuViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'

end
