platform :ios, :deployment_target => "7.0"

pod 'Facebook-iOS-SDK', '~>3.16.0'
pod 'SVProgressHUD', :git => 'git@github.com:EverestOpenSource/SVProgressHUD.git'
pod 'SVPullToRefresh', :git => 'git@github.com:EverestOpenSource/SVPullToRefresh.git'
pod 'ECSlidingViewController', :git => 'git@github.com:EverestOpenSource/ECSlidingViewController.git' # Waiting for https://github.com/ECSlidingViewController/ECSlidingViewController/pull/305 and another PR for notifications
pod 'AFNetworking', :git => 'git@github.com:EverestOpenSource/AFNetworking.git', :branch => '1.3.3-everest' # Changes for UIImageView download progress
pod 'RestKit', '~>0.22.0'
pod 'SSKeychain', '~>1.2.1'
pod 'AFOAuth1Client', '~>0.3.3'
pod 'Reachability', '~>3.1.1'
pod 'ios-image-editor', :git => 'git@github.com:EverestOpenSource/ios-image-editor.git'
pod 'TTTAttributedLabel', :git => 'git@github.com:EverestOpenSource/TTTAttributedLabel.git', :branch => 'everest' # Waiting for https://github.com/mattt/TTTAttributedLabel/pull/331 & fix for https://github.com/mattt/TTTAttributedLabel/issues/402
pod 'JDStatusBarNotification', '~>1.4.8'
pod 'SwipeView', '~>1.3'
pod 'Masonry', '~>0.5.3'
pod 'DACircularProgress', '~>2.2.0'
pod 'DZNPhotoPickerController', :git => 'git@github.com:EverestOpenSource/DZNPhotoPickerController.git'
pod 'PBWebViewController', '~>0.1'
pod 'Mixpanel', '~> 2.3'
pod 'uservoice-iphone-sdk', '~> 3.0'
pod 'SDWebImage', '~> 3.6'

target 'KIFTestsWithMocks', :exclusive => true do
 pod 'OHHTTPStubs'
 pod 'KIF', '~>3.0.8'
end

target 'KIFTestsStaging', :exclusive => true do
 pod 'KIF', '~>3.0.8'
end

pod 'VTAcknowledgementsViewController', :git => 'git@github.com:EverestOpenSource/VTAcknowledgementsViewController.git'
post_install do | installer |
  require 'fileutils'
  FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-Acknowledgements.plist', 'Everest/View Controllers/Settings/Pods-acknowledgements.plist', :remove_destination => true)
end