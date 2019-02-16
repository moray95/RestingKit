Pod::Spec.new do |s|
    s.name             = 'RestingKit'
    s.version          = '0.0.1'
    s.summary          = 'Networking made easy.'

    s.description      = File.read('README.md')
    s.homepage         = 'https://github.com/moray95/RestingKit'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Moray Baruh' => 'contact@moraybaruh.com' }
    s.source           = { :git => 'https://github.com/moray95/RestingKit.git', :tag => s.version.to_s }

    s.ios.deployment_target = '10.0'

    s.source_files = 'RestingKit/Classes/**/*'

    # s.resource_bundles = {
    #   'RestingKit' => ['RestingKit/Assets/*.png']
    # }

    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    s.dependency 'Alamofire', '~> 4.8'
    s.dependency 'GRMustache.swift4', '~> 3.0'
    s.dependency 'PromiseKit', '~> 6.8'
end
