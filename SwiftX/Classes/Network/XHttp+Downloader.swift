//
//  XHttp+Downloader.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

// MARK: 下载
public extension XHttp {
    
    final public class Downloader {
        
        /**
         *  通过url 下载文件
         *  - Parameter: url 文件下载地址
         *  - Parameter: fileURL 文件在本地存放位置，如果此参数=nil那么文件将保存到临时位置
         *  - Parameter: handler 回调 for more @see: XHttp.Result.Downloader
         */
        static public func downloadTask(with url: URL, location fileURL: URL? = nil, handler: ((_ result: XHttp.Result.Downloader) -> Void)? = nil) -> URLSessionDownloadTask {
            return downloadTask(with: URLRequest(url: url), location: fileURL, handler: handler)
        }
        
        /**
         *  通过request 下载文件
         *  - Parameter: request
         *  - Parameter: fileURL 文件在本地存放位置，如果此参数=nil那么文件将保存到临时位置
         *  - Parameter: handler 回调 for more @see: XHttp.Result.Downloader
         */
        static public func downloadTask(with request: URLRequest, location fileURL: URL? = nil, handler: ((_ result: XHttp.Result.Downloader) -> Void)? = nil) -> URLSessionDownloadTask {
            let configuration = URLSessionConfiguration.default
            let downloadTask = URLSession(configuration: configuration, delegate: XURLSessionDownloaderTaskDelegate(fileURL, handler), delegateQueue: nil).downloadTask(with: request)
            downloadTask.resume()
            return downloadTask
        }
        
        /**
         *  通过resumeData 下载文件
         *  - Parameter: resumeData 从上次取消的位置开始重新下载，注意-需要与：cancel(byProducingResumeData: handler)配合使用
         *  - Parameter: fileURL 文件在本地存放位置，如果此参数=nil那么文件将保存到临时位置
         *  - Parameter: handler 回调 for more @see: XHttp.Result.Downloader
         */
        static public func downloadTask(withResumeData resumeData: Data, location fileURL: URL? = nil, handler: ((_ result: XHttp.Result.Downloader) -> Void)? = nil) -> URLSessionDownloadTask {
            let configuration = URLSessionConfiguration.default
            let downloadTask = URLSession(configuration: configuration, delegate: XURLSessionDownloaderTaskDelegate(fileURL, handler), delegateQueue: nil).downloadTask(withResumeData: resumeData)
            downloadTask.resume()
            return downloadTask
        }
        
    }
    
}

/// MARK: 下载文件代理
fileprivate class XURLSessionDownloaderTaskDelegate: NSObject, URLSessionDownloadDelegate {
    
    private var fileURL: URL?
    private var handler: ((_ result: XHttp.Result.Downloader) -> Void)? = nil
    
    init(_ fileURL: URL?, _ handler: ((_ result: XHttp.Result.Downloader) -> Void)?) {
        self.fileURL = fileURL
        self.handler = handler
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            #if DEBUG
            NSLog("XHttpManagerDownloader didFinishDownloadingTo tmp location:  \(location.path)   \(location.pathExtension)")
            #endif
            if let fileURL = fileURL {
                let data = NSData(contentsOf: location)
                try data?.write(to: fileURL, options: .atomicWrite)
            } else {
                fileURL = location
            }
        } catch let error {
            #if DEBUG
            NSLog("XHttpManagerDownloader  didFinishDownloadingTo fail")
            #endif
            handler?(.failure(error))
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        #if DEBUG
        NSLog("XHttpManagerDownloader progress:  \(bytesWritten)  \(totalBytesWritten)  \(totalBytesExpectedToWrite)")
        #endif
        handler?(.progress(totalBytesWritten, totalBytesExpectedToWrite))
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        #if DEBUG
        NSLog("XHttpManagerDownloader didResumeAtOffset:  \(fileOffset)  \(expectedTotalBytes)")
        #endif
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        #if DEBUG
        NSLog("XHttpManagerDownloader didCompleteWithError: \(String(describing: error))")
        #endif
        if error != nil {
            handler?(.failure(error!))
        } else {
            handler?(.success(fileURL!))
        }
    }
}
