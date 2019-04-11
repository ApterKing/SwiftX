//
//  AppVersion.swift
//  SwiftX
//
//  Created by wangcong on 2019/4/11.
//

public class AppVersion: NSObject {
    
    static public func check(bundleId: String, delay: TimeInterval = 10, showEmbedAlertViewController: Bool = true, _ complection: ((_ info: AppVersion.Info?, _ error: Error?) -> Void)?) {
        let params: [AnyHashable: Any] = ["bundleId": bundleId]
        XHttp.get("http://itunes.apple.com/lookup", .query, params, nil, { (result) in
            switch result {
            case .success(let data):
                if let infos = try? JSONDecoder.decode([AppVersion.Info].self, from: data, forKeyPath: "results") {
                    var hasNewVersionInfo = false
                    for info in infos {
                        if info.bundleId == bundleId {
                            hasNewVersionInfo = true
                            complection?(info, nil)
                            
                            if showEmbedAlertViewController {
                                showAllertController(with: info)
                            }
                            break
                        }
                    }
                    if !hasNewVersionInfo {
                        complection?(nil, NSError(domain: "com.SwiftX.AppVersion", code: -1, description: "未查找到相关应用"))
                    }
                    
                }
            case .failure(let error):
                complection?(nil, error)
            }
        })

    }
    
    static private func showAllertController(with info: Info) {
        guard let currentBundleId = Bundle.bundleIdentifier, info.version > currentBundleId else { return }
        AppVersionAlertController.show(info: info)
    }

}

extension AppVersion {
    
    public class Info: Codable {
        public var bundleId: String = ""        // bundle identifier
        public var version: String = ""         // short version ex: 1.0.0
        public var releaseNotes: String = ""    // 更新内容
        
        public var trackId: String = ""         // App id
        public var trackViewUrl: String = ""         // Appstore 地址
        public var trackCensoredName: String = ""    //
        
        public var sellerName: String = ""              // 开发商
        
        public var screenshotUrls: [String]     // 截屏
        
        public var currentVersionReleaseDate: String = ""    // 更新时间 "2019-04-06T14:15:31Z",
    }

}
