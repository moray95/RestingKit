platform :ios, '10.0'

target 'RestingKit' do
  use_frameworks!
  pod 'Alamofire', '~> 4.8'
  pod 'GRMustache.swift4', '~> 3.0'
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
