Pod::Spec.new do |s|
    s.name             = 'RestingKit'
    s.version          = '0.0.5'
    s.summary          = 'Networking made easy.'

    s.description      = File.read('README.md')
    s.homepage         = 'https://github.com/moray95/RestingKit'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Moray Baruh' => 'contact@moraybaruh.com' }
    s.source           = { :git => 'https://github.com/moray95/RestingKit.git', :tag => s.version.to_s }

    s.ios.deployment_target = '10.0'

    s.source_files = 'RestingKit/*.swift', 'RestingKit/**/*.swift'
    s.swift_versions = ['5.0']

    s.dependency 'Alamofire', '~> 4.8'
    s.dependency 'GRMustache.swift', '~> 4.0'
    s.dependency 'PromiseKit', '~> 6.8'
end
