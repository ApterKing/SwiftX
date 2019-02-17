#
# Be sure to run `pod lib lint Swift-X.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftX'
  s.version          = '0.1.0'
  s.summary          = 'Swift 相关扩展.'

  s.description      = <<-DESC
			Globals: 定义一些全局需要使用的方法
			Extensions: Foundation、UIKit、CoreGraphics
                       DESC

  s.homepage         = 'https://github.com/wangcong/Swift-X'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wangcong' => 'wangcccong@foxmail.com' }
  s.source           = { :git => 'https://github.com/wangcong/Swift-X.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.default_subspecs = 'Base'

  # ---------------  Globals  -----------
  s.subspec 'Globals' do |ss|
    ss.source_files = 'SwiftX/Classes/Globals/**/*.swift'

    ss.frameworks = 'Foundation'
  end

  # ---------------  Extensions常用扩展  -----------
  s.subspec 'Extensions' do |ss|
    ss.source_files = 'SwiftX/Classes/Extensions/**/*.swift'

    ss.frameworks = 'UIKit', 'Foundation', 'CoreGraphics'
  end

  # --------------  Network网络请求、下载、上传 ----------------
  s.subspec 'Network' do |ss|
    ss.source_files = 'SwiftX/Classes/Network/*.swift', 'SwiftX/Classes/Network/Core/*.swift'

    ss.frameworks = 'Foundation'
  end

  # --------------  NetworkRx对网络请求Rx的封装 ----------------
  s.subspec 'NetworkRx' do |ss|
    ss.source_files = 'SwiftX/Classes/Network/Rx/*.swift'

    ss.frameworks = 'Foundation'
    ss.dependency 'SwiftX/Network'
    ss.dependency 'RxSwift'
  end

  # --------------  Cache 数据缓存 ----------------
  s.subspec 'Cache' do |ss|
    ss.source_files = 'SwiftX/Classes/Cache/**/*.swift'

    ss.frameworks = 'Foundation'
  end

  # ---------------  JSON 数据解析 -----------
  s.subspec 'JSON' do |ss|
    ss.source_files = 'SwiftX/Classes/JSON/**/*.swift'

    ss.frameworks = 'Foundation'
  end

  # ---------------  View ---------------
  s.subspec 'View' do |ss|

    ss.subspec 'Base' do |sss|
    	sss.source_files = 'SwiftX/Classes/View/Base/*.swift'
		sss.resources = ['SwiftX/Assets/Base/*.png']

        sss.frameworks = 'UIKit', 'Foundation'
    end

    ss.subspec 'Custom' do |sss|
    	sss.source_files = 'SwiftX/Classes/View/Custom/*.swift'
	sss.resources = ['SwiftX/Assets/Custom/*.png']

        sss.frameworks = 'UIKit', 'Foundation'
    end
	
    ss.subspec 'QRCode' do |sss|
    	sss.source_files = 'SwiftX/Classes/View/QRCode/*.swift'
	sss.resources = ['SwiftX/Assets/QRCode/*.png']

        sss.frameworks = 'UIKit', 'Foundation', 'Photos', 'AssetsLibrary'
    	ss.dependency 'SwiftX/Extensions'
    end

    ss.subspec 'Hybird' do |sss|
    	sss.source_files = 'SwiftX/Classes/View/Hybird/*.swift'

        sss.frameworks = 'UIKit', 'Foundation'
    end
  end

  # ---------------  Bluetooth  -----------
  s.subspec 'Bluetooth' do |ss|
    ss.source_files = 'SwiftX/Classes/Bluetooth/*.swift'

    ss.frameworks = 'CoreBluetooth', 'Foundation'
  end

  # ---------------  Realm --------------
  s.subspec 'Realm' do |ss|
    ss.source_files = 'SwiftX/Classes/Realm/*.swift'

    ss.dependency 'RealmSwift', '~> 3.13.0'
  end

  # --------------  Cache  ----------------
  s.subspec 'Cache' do |ss|
    ss.source_files = 'SwiftX/Classes/Cache/*.swift'

    ss.frameworks = 'Foundation'
  end

  # -------------- RN HotUpdate ---------------
  s.subspec 'XPush' do |ss|
    ss.source_files = 'SwiftX/Classes/XPush/*.{swift,h,m}'
    
    ss.dependency 'SSZipArchive', '~> 2.1.4'
    ss.dependency 'SwiftX/Extensions'
  end

  # --------------  OpenSDK 三方登录、支付工具  ----------------
  s.subspec 'OpenSDK' do |ss|
    ss.source_files = 'SwiftX/Classes/OpenSDK/*.{swift,h,m}'

    # Alipay: 2.0
    ss.subspec 'Alipay' do |sss|

      sss.resources = 'SwiftX/Classes/OpenSDK/Vendors/Alipay/*.bundle'

      sss.vendored_frameworks = 'SwiftX/Classes/OpenSDK/Vendors/Alipay/*.framework'
      sss.vendored_libraries = 'SwiftX/Classes/OpenSDK/Vendors/Alipay/*.a'
      
    end

    # WeChat: 1.8.4
    ss.subspec 'WeChat' do |sss|

      sss.source_files = 'SwiftX/Classes/OpenSDK/Vendors/WeChat/*.{h,m}'

      sss.vendored_libraries = 'SwiftX/Classes/OpenSDK/Vendors/WeChat/*.a'
      
    end

    # QQ: 3.3.3.0
    ss.subspec 'QQ' do |sss|

      sss.vendored_frameworks = 'SwiftX/Classes/OpenSDK/Vendors/QQ/*.framework'

    end

    # Weibo: 3.2.3
    ss.subspec 'Weibo' do |sss|

      sss.source_files = 'SwiftX/Classes/OpenSDK/Vendors/Weibo/*.{h,m}'

      sss.resources = 'SwiftX/Classes/OpenSDK/Vendors/Weibo/*.bundle'
      sss.vendored_libraries = 'SwiftX/Classes/OpenSDK/Vendors/Weibo/*.a'
      
    end

    s.frameworks = 'Photos', 'ImageIO', 'SystemConfiguration', 'CoreText', 'QuartzCore', 'Security', 'UIKit', 'Foundation', 'CoreGraphics','CoreTelephony'
    s.libraries = 'sqlite3', 'z'
    
  end

end
