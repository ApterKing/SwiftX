#
# Be sure to run `pod lib lint Swift-X.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftX'
  s.version          = '0.1.3'
  s.summary          = 'Swift 相关扩展.'

  s.description      = <<-DESC
			Globals: 定义一些全局需要使用的方法
			Extensions: Foundation、UIKit、CoreGraphics
                       DESC

  s.homepage         = 'https://github.com/wangcong/SwiftX'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wangcong' => 'wangcccong@foxmail.com' }
  s.source           = { :git => 'https://github.com/wangcong/SwiftX.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  
  s.default_subspecs = 'Core'
  
  # ---------------  Core  -----------
  s.subspec 'Core' do |ss|
    ss.source_files = 'SwiftX/Classes/*.h'
    ss.public_header_files = 'SwiftX/Classes/SwiftX/*.h'
  end

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
      sss.dependency 'SwiftX/Extensions'
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
  
  # --------------  三方库  ----------------
  s.subspec 'ThirdParty' do |ss|
    
    # Realm
    ss.subspec 'Realm' do |sss|
      sss.source_files = 'SwiftX/Classes/ThirdParty/Realm/*.swift'
      sss.dependency 'RealmSwift', '~> 3.13.0'
    end
    
    # Kingfisher
    ss.subspec 'Kingfisher' do |sss|
      sss.source_files = 'SwiftX/Classes/ThirdParty/Kingfisher/*.swift'
      sss.dependency 'Kingfisher'
    end
    
    # Toaster
    ss.subspec 'Toaster' do |sss|
      sss.source_files = 'SwiftX/Classes/ThirdParty/Toaster/*.swift'
      sss.dependency 'Toaster'
    end
    
  end
  # --------------  OpenSDK 三方登录、支付工具  ----------------
  s.subspec 'OpenSDK' do |ss|
    
    ss.dependency 'SwiftX/Core'
    
    # Alipay: 15.6.0
    ss.subspec 'Alipay' do |sss|
      sss.source_files = 'SwiftX/Classes/OpenSDK/Alipay/*.{swift}', 'SwiftX/Classes/OpenSDK/Alipay/*.framework/Headers/**/*.h'
      sss.public_header_files = 'SwiftX/Classes/OpenSDK/Alipay/*.framework/Headers/**/*.h'
      sss.resources = 'SwiftX/Classes/OpenSDK/Alipay/*.bundle'
      sss.vendored_frameworks = 'SwiftX/Classes/OpenSDK/Alipay/*.framework'
      sss.frameworks = 'CoreMotion', 'SystemConfiguration', 'CoreTelephony', 'QuartzCore', 'CoreText', 'CoreGraphics', 'UIKit', 'Foundation', 'CFNetwork', 'Security'
      sss.libraries = 'z', 'c++'
    end

    # WeChat: 1.8.4 (含支付功能）
    ss.subspec 'WeChat' do |sss|
      sss.source_files = 'SwiftX/Classes/OpenSDK/WeChat/*.{swift,h,m}'
      sss.vendored_libraries = 'SwiftX/Classes/OpenSDK/WeChat/*.a'
      sss.dependency 'SwiftX/Network'
      sss.dependency 'SwiftX/JSON'
      sss.frameworks = 'SystemConfiguration', 'Security', 'CoreTelephony', 'CFNetwork', 'CoreGraphics'
      sss.libraries = 'sqlite3', 'z', 'c++'
      sss.pod_target_xcconfig = {
        'OTHER_LDFLAGS' => '-Objc -all_load',
      }
    end

    # QQ: 3.3.3.0
    ss.subspec 'QQ' do |sss|
      sss.source_files = 'SwiftX/Classes/OpenSDK/QQ/*.{swift}', 'SwiftX/Classes/OpenSDK/QQ/*.framework/Headers/**/*.h'
      sss.public_header_files = 'SwiftX/Classes/OpenSDK/QQ/*.framework/Headers/**/*.h'
      sss.vendored_frameworks = 'SwiftX/Classes/OpenSDK/QQ/*.framework'
    end

    # Weibo: 3.2.3
    ss.subspec 'Weibo' do |sss|
      sss.source_files = 'SwiftX/Classes/OpenSDK/Weibo/*.{swift,h,m}'
      sss.resources = 'SwiftX/Classes/OpenSDK/Weibo/*.bundle'
      sss.vendored_libraries = 'SwiftX/Classes/OpenSDK/Weibo/*.a'
      sss.frameworks = 'QuartzCore', 'ImageIO', 'SystemConfiguration', 'Security', 'CoreTelephony', 'CoreText', 'CoreGraphics', 'UIKit', 'Foundation', 'CFNetwork', 'Security'
      sss.libraries = 'sqlite3', 'z'
      sss.pod_target_xcconfig = {
        'OTHER_LDFLAGS' => '-Objc -all_load',
      }
    end
    
    # Weibo: 3.1.2
    ss.subspec 'JPush' do |sss|
        sss.source_files = 'SwiftX/Classes/OpenSDK/JPush/*.{swift,h,m}'
        sss.vendored_libraries = 'SwiftX/Classes/OpenSDK/JPush/*.a'
        sss.frameworks = 'CFNetwork', 'CoreFoundation', 'CoreTelephony', 'SystemConfiguration', 'CoreGraphics', 'Foundation', 'CoreGraphics', 'UIKit', 'Foundation', 'CFNetwork', 'Security', 'UserNotifications'
        sss.libraries = 'z', 'resolv'
#        sss.pod_target_xcconfig = {
#            'OTHER_LDFLAGS' => '-Objc -all_load',
#        }
    end
    
    # Baidu
    ss.subspec 'Baidu' do |sss|

      # 百度定位SDK  1.4
      sss.subspec 'Location' do |ssss|
        ssss.source_files = 'SwiftX/Classes/OpenSDK/Baidu/Location/*.{swift,h,m}', 'SwiftX/Classes/OpenSDK/Baidu/Location/*.framework/Headers/**/*.h'
        ssss.public_header_files = 'SwiftX/Classes/OpenSDK/Baidu/Location/*.framework/Headers/**/*.h'
        ssss.vendored_frameworks = 'SwiftX/Classes/OpenSDK/Baidu/Location/*.framework'
        ssss.frameworks = 'CoreLocation', 'SystemConfiguration', 'Security', 'Security', 'CoreTelephony', 'AdSupport'
        ssss.libraries = 'sqlite3'
        ssss.pod_target_xcconfig = {
          'OTHER_LDFLAGS' => '-Objc',
        }
      end
      
      # 百度地图  4.3.0
      sss.subspec 'Map' do |ssss|
        ssss.source_files = 'SwiftX/Classes/OpenSDK/Baidu/Map/*.{swift,h,m,mm}', 'SwiftX/Classes/OpenSDK/Baidu/Map/*.framework/Headers/**/*.h'
        ssss.public_header_files = 'SwiftX/Classes/OpenSDK/Baidu/Map/*.framework/Headers/**/*.h'
        ssss.resources = 'SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Map.framework/mapapi.bundle', 'SwiftX/Classes/OpenSDK/Baidu/Map/Assets/*.png'
        ssss.vendored_frameworks = 'SwiftX/Classes/OpenSDK/Baidu/Map/*.framework'
        ssss.vendored_libraries = 'SwiftX/Classes/OpenSDK/Baidu/Map/thirdlibs/*.a'
        ssss.frameworks = 'CoreGraphics', 'CoreLocation', 'OpenGLES', 'QuartzCore', 'Security', 'SystemConfiguration'
        ssss.libraries = 'sqlite3'
        ssss.pod_target_xcconfig = {
          'OTHER_LDFLAGS' => '-Objc',
        }
        
      end
      
      sss.dependency 'SwiftX/Extensions'
      sss.dependency 'SwiftX/View'
      sss.dependency 'SwiftX/Globals'
      
    end

  end
  
  s.prepare_command = <<-EOF
  # 创建BMKLocationKit
  rm -rf SwiftX/Classes/OpenSDK/Baidu/Location/BMKLocationKit.framework/Modules
  mkdir SwiftX/Classes/OpenSDK/Baidu/Location/BMKLocationKit.framework/Modules
  touch SwiftX/Classes/OpenSDK/Baidu/Location/BMKLocationKit.framework/Modules/module.modulemap
  cat <<-EOF > SwiftX/Classes/OpenSDK/Baidu/Location/BMKLocationKit.framework/Modules/module.modulemap
  framework module BMKLocationKit {
      umbrella header "BMKLocationComponent.h"
      export *
      link "sqlite3.0"
      link "stdc++.6.0.9"
  }
  \EOF
  # 创建BaiduMapAPI_Base
  rm -rf SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Base.framework/Modules
  mkdir SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Base.framework/Modules
  touch SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Base.framework/Modules/module.modulemap
  cat <<-EOF > SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Base.framework/Modules/module.modulemap
  framework module BaiduMapAPI_Base {
      umbrella header "BMKBaseComponent.h"
      export *
      link "sqlite3.0"
      link "stdc++.6.0.9"
  }
  \EOF
  
  # 创建BaiduMapAPI_Map
  rm -rf SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Map.framework/Modules
  mkdir SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Map.framework/Modules
  touch SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Map.framework/Modules/module.modulemap
  cat <<-EOF > SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Map.framework/Modules/module.modulemap
  framework module BaiduMapAPI_Map {
      umbrella header "BMKMapComponent.h"
      export *
      link "sqlite3.0"
      link "stdc++.6.0.9"
  }
  \EOF

  # 创建BaiduMapAPI_Search
  rm -rf SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Search.framework/Modules
  mkdir SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Search.framework/Modules
  touch SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Search.framework/Modules/module.modulemap
  cat <<-EOF > SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Search.framework/Modules/module.modulemap
  framework module BaiduMapAPI_Search {
      umbrella header "BMKSearchComponent.h"
      export *
      link "sqlite3.0"
      link "stdc++.6.0.9"
  }
  \EOF
  
  # 创建BaiduMapAPI_Utils
  rm -rf SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Utils.framework/Modules
  mkdir SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Utils.framework/Modules
  touch SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Utils.framework/Modules/module.modulemap
  cat <<-EOF > SwiftX/Classes/OpenSDK/Baidu/Map/BaiduMapAPI_Utils.framework/Modules/module.modulemap
  framework module BaiduMapAPI_Utils {
      umbrella header "BMKUtilsComponent.h"
      export *
      link "sqlite3.0"
      link "stdc++.6.0.9"
  }
  \EOF
  EOF

end
