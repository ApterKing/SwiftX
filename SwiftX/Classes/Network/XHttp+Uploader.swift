//
//  XHttp+Uploader.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

// MARK: 上传
public extension XHttp {
    
    final public class Uploader {
        
        /**
         *  通过fileURL 上传数据
         *  - Parameter: request
         *  - Parameter: fileURL 待上传文件地址
         *  - Parameter: handler 回调 for more @see: XHttp.Result.Uploader
         */
        static public func uploadTask(with request: URLRequest, fromFile fileURL: URL, handler: ((_ result: XHttp.Result.Uploader) -> Void)? = nil) -> URLSessionUploadTask {
            let configuration = URLSessionConfiguration.default
            let uploadTask = URLSession(configuration: configuration, delegate: XURLSessionUploadTaskDelegate(handler), delegateQueue: nil).uploadTask(with: request, fromFile: fileURL)
            uploadTask.resume()
            return uploadTask
        }
        
        /**
         *  通过bodyData 上传数据
         *  - Parameter: request
         *  - Parameter: bodyData 待上传数据
         *  - Parameter: handler 回调 for more @see: XHttp.Result.Uploader
         */
        static public func uploadTask(with request: URLRequest, from bodyData: Data, handler: ((_ result: XHttp.Result.Uploader) -> Void)? = nil) -> URLSessionUploadTask {
            let configuration = URLSessionConfiguration.default
            let uploadTask = URLSession(configuration: configuration, delegate: XURLSessionUploadTaskDelegate(handler), delegateQueue: nil).uploadTask(with: request, from: bodyData)
            uploadTask.resume()
            return uploadTask
        }
        
        static public func uploadTask(withStreamedRequest request: URLRequest, handler: ((_ result: XHttp.Result.Uploader) -> Void)? = nil) -> URLSessionUploadTask {
            let configuration = URLSessionConfiguration.default
            let uploadTask = URLSession(configuration: configuration, delegate: XURLSessionUploadTaskDelegate(handler), delegateQueue: nil).uploadTask(withStreamedRequest: request)
            uploadTask.resume()
            return uploadTask
        }
        
    }
    
}

/// MARK: 上传数据代理
fileprivate class XURLSessionUploadTaskDelegate: NSObject, URLSessionDataDelegate {
    
    private var handler: ((_ result: XHttp.Result.Uploader) -> Void)? = nil
    
    init(_ handler: ((_ result: XHttp.Result.Uploader) -> Void)?) {
        self.handler = handler
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        #if DEBUG
        NSLog("XHttpManagerUploader progress:  \(bytesSent)  \(totalBytesSent)  \(totalBytesExpectedToSend)")
        #endif
        handler?(.progress(totalBytesSent, totalBytesExpectedToSend))
    }
    
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        #if DEBUG
        NSLog("XHttpManagerUploader didCompleteWithError:  \(String(describing: error))")
        #endif
        if error != nil {
            handler?(.failure(error!))
        } else {
            handler?(.success())
        }
    }
}
