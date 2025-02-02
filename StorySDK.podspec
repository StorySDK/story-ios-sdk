#
# Be sure to run `pod lib lint StorySDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'StorySDK'
  s.version          = '0.9.24'
  s.summary          = 'Add stories in your app.'

  s.description      = <<-DESC
  A service for creating and adding stories to mobile apps and websites. Realtime, no code solution.
                       DESC

  s.homepage         = 'https://storysdk.com/'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'StorySDK' => 'info@storysdk.com' }
  s.source           = { :git => 'https://github.com/StorySDK/ios-sdk.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/StorySDK/**/*.swift'
  s.resource_bundles = {
    'StorySDK' => [
      'Sources/Resources/Images/*.png',
      'Sources/Resources/Fonts/**/*.otf',
      'Sources/PrivacyInfo.xcprivacy',
    ]
  }
end
