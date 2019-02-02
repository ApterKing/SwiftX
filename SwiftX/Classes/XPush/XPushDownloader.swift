//
//  XPushDownloader.swift
//  Pods-MedCRM
//
//  Created by wangcong on 2018/11/26.
//

import UIKit

/// MARK: 文件下载
class XPushDownloader: NSObject {
    typealias progressHandler = ((_ totalBytesWritten: Int64, _ totalBytesExpectedToWrite: Int64) -> Void)
    typealias completionHandler = ((_ path: String, _ error: Error?) -> Void)
    
    fileprivate var progressHandler: progressHandler?
    fileprivate var completionHandler: completionHandler?
    fileprivate var urlPath: String!
    fileprivate var filePath: String!
    
    fileprivate var task: URLSessionDownloadTask?
    
    static func download(urlPath: String, save filePath: String, progress: progressHandler?, completion: completionHandler?) {
        let downloader = XPushDownloader()
        downloader.urlPath = urlPath
        downloader.filePath = filePath
        downloader.progressHandler = progress
        downloader.completionHandler = completion
        
        downloader._download(urlPath)
    }
    
    private func _download(_ urlPath: String) {
        guard let url = URL(string: urlPath) else { return }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        XPushLog("XPushDownloader  download from: \(urlPath)")
        task = session.downloadTask(with: url)
        task?.resume()
    }
    
    deinit {
        let state = task?.state ?? .running
        if state == .running || state == .suspended {
            task?.cancel()
        }
    }
    
}

extension XPushDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        XPushLog("XPushDownloader progress:  \(bytesWritten)  \(totalBytesWritten)  \(totalBytesExpectedToWrite)")
        
        self.progressHandler?(totalBytesWritten, totalBytesExpectedToWrite)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            XPushLog("XPushDownloader didFinishDownloadingTo location:  \(location.path)   \(location.pathExtension)")
            
            let data = NSData(contentsOf: location)
            try data?.write(toFile: filePath, options: .atomicWrite)
            
            XPushLog("XPushDownloader  didFinishDownloadingTo save to:  \(filePath)")
        } catch let error {
            XPushLog("XPushDownloader  didFinishDownloadingTo fail")
            self.completionHandler?(filePath, error)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        XPushLog("XPushDownloader didCompleteWithError: \(String(describing: error))")
        self.completionHandler?(filePath, error)
    }
}
