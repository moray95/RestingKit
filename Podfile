platform :ios, '10.0'

inhibit_all_warnings!

target 'RestingKit' do
  use_frameworks!
  pod 'Alamofire', '~> 4.8'
  pod 'GRMustache.swift', '~> 4.0'
  pod 'PromiseKit', '~> 6.8'
  pod 'SwiftLint'

  target 'RestingKitTests' do
    inherit! :search_paths
  end

end

target 'RestingKit-iOS-Example' do
  use_frameworks!
  pod 'RestingKit', path: '.'
end
