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

/// MARK: 多文件上传
public extension XHttp.Uploader {
    
    static public var boundary = "SwiftX_Http_Multiple_Boundary"
    
    /// MARK: 多数据格式
    public class MultiPart {
        public var name: String?
        public var filename: String?
        
        // data 与 fileURL 二选一
        public var data: Data?
        public var fileURL: URL?
        
        init(name: String?, filename: String, data: Data?, fileURL: URL?) {
            self.name = name
            self.filename = filename
            self.data = data
            self.fileURL = fileURL
        }
    }
    
    /**
     *  多数据上传
     *  - Parameter: request
     *  - Parameter: bodyData 待上传数据 [name, filename, data]
     *  - Parameter: fileURL 待上传数据 [name, filename, data]
     *  - Parameter: handler 回调 for more @see: XHttp.Result.Uploader
     */
    static public func multiUploadTask(with url: URL, formParams params: [AnyHashable: Any]? = nil, multiParts: [MultiPart]? = nil, handler: ((_ result: XHttp.Result.Uploader) -> Void)? = nil) -> URLSessionUploadTask {
        let configuration = URLSessionConfiguration.default
        var request = URLRequest(url: url)
        request.httpMethod = "post"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let data = enclose(formParams: params, multiParts: multiParts)
        request.httpBody = data
        let uploadTask = URLSession(configuration: configuration, delegate: XURLSessionUploadTaskDelegate(handler), delegateQueue: nil).uploadTask(with: request, from: data)
        uploadTask.resume()
        return uploadTask
    }
    
    static private func enclose(formParams: [AnyHashable: Any]?, multiParts: [MultiPart]?) -> Data {
        var enclosedData = Data()
        
        // 开始
        if let startData = "\r\n".data(using: .utf8) {
            enclosedData.append(startData)
        }
        
        // 普通数据
        if let params = formParams {
            for param in params {
                var paramString = String("\r\n--\(boundary)\r\n")
                paramString.append("Content-Disposition: form-data; name=\(param.key)\r\n")
                paramString.append("\r\n")
                paramString.append(String(format: "%@", param.value as! CVarArg))
                if let paramData = paramString.data(using: .utf8) {
                    enclosedData.append(paramData)
                }
            }
        }
        
        // data 数据
        if let parts = multiParts {
            for (index, part) in parts.enumerated() {
                let name = part.name ?? "name_\(index)"
                let filename = part.filename ?? (part.fileURL?.lastPathComponent ?? "filename_\(index)")
                var data = part.data
                if let url = part.fileURL, let fileData = try? Data(contentsOf: url) {
                    data = fileData
                }
                
                guard let formData = data else { continue }
                var paramString = String("--\(boundary)\r\n")
                paramString.append("Content-Disposition: form-data; name=\(name); filename=\(filename)\r\n")
                paramString.append("Content-Type: application/octet-stream\r\n")
                paramString.append("\r\n")
                if let paramData = paramString.data(using: .utf8) {
                    enclosedData.append(paramData)
                }
                enclosedData.append(formData)
            }
        }
        
        // 结束
        if let endData = "\r\n--\(boundary)--\r\n".data(using: .utf8) {
            enclosedData.append(endData)
        }
        return enclosedData
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
        NSLog("XHttp.Uploader progress:  \(bytesSent)  \(totalBytesSent)  \(totalBytesExpectedToSend)")
        #endif
        _processOnMain { [weak self] () in
            self?.handler?(.progress(totalBytesSent, totalBytesExpectedToSend))
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        #if DEBUG
        NSLog("XHttp.Uploader dataTask didReceive:  \(String(data: data, encoding: .utf8))")
        #endif
        _processOnMain { [weak self] () in
            self?.handler?(.success(data))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        #if DEBUG
        NSLog("XHttp.Uploader didCompleteWithError:  \(String(describing: error))")
        #endif
        if error != nil {
            _processOnMain { [weak self] () in
                self?.handler?(.failure(error!))
            }
        }
    }
    
    private func _processOnMain(_ block: @escaping (() -> Void)) {
        DispatchQueue.main.async {
            block()
        }
    }
    
}
