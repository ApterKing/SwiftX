//
//  XHttp.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

/**
 *  http 请求，暂时支持GET、POST 及 upload、download
 *  - Usage：
 *    - 配置：如果存在默认的相关配置，需设置相关默认配置，详见：XHttp.Configuration
 *      var configuration = XHttp.Configuration.defaultConfiguration
 *      configuration.host = "xxx"
 *      configuration.requestSerializer = .query
 *      configuration.responseSerializer = .json
 *      configuration.setValue("application/json", forHTTPHeaderField: "Content-Type")
 *      XHttp.Configuration.defaultConfiguration = configuration
 *    - 请求：
 *      XHttp.get("xx", .json, nil) { (data, error) in }
 *      XHttp.post("xx", .json, nil) { (data, error) in }
 */
public class XHttp {

    /// MARK: GET
    static public func get(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil, _ handler: ((_ result: XHttp.Result) -> Void)? = nil) -> URLSessionTask? {
        return request(path, XHttp.Method.GET, requestSerializer, params, configuration, handler)
    }

    /// MARK: HEAD
    static public func head(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil, _ handler: ((_ result: XHttp.Result) -> Void)? = nil) -> URLSessionTask? {
        return request(path, XHttp.Method.HEAD, requestSerializer, params, configuration, handler)
    }

    /// MARK: POST
    static public func post(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil, _ handler: ((_ result: XHttp.Result) -> Void)? = nil) -> URLSessionTask? {
        return request(path, XHttp.Method.POST, requestSerializer, params, configuration, handler)
    }

    /// MARK: PUT
    static public func put(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil, _ handler: ((_ result: XHttp.Result) -> Void)? = nil) -> URLSessionTask? {
        return request(path, XHttp.Method.PUT, requestSerializer, params, configuration, handler)
    }

    /// MARK: DELETE
    static public func delete(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil, _ handler: ((_ result: XHttp.Result) -> Void)? = nil) -> URLSessionTask? {
        return request(path, XHttp.Method.DELETE, requestSerializer, params, configuration, handler)
    }

    /// MARK: OPTIONS
    static public func options(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil, _ handler: ((_ result: XHttp.Result) -> Void)? = nil) -> URLSessionTask? {
        return request(path, XHttp.Method.OPTIONS, requestSerializer, params, configuration, handler)
    }

    /// MARK: TRACE
    static public func trace(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil, _ handler: ((_ result: XHttp.Result) -> Void)? = nil) -> URLSessionTask? {
        return request(path, XHttp.Method.TRACE, requestSerializer, params, configuration, handler)
    }

    /// MARK: PATCH
    static public func patch(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil, _ handler: ((_ result: XHttp.Result) -> Void)? = nil) -> URLSessionTask? {
        return request(path, XHttp.Method.PATCH, requestSerializer, params, configuration, handler)
    }

    /**
     *  网络请求
     *  - Parameter: path  请求地址（如果在configuration配置了host，那么此时可以是短链）
     *  - Parameter: method GET/POST
     *  - Parameter: requestSerializer  请求时参数需要序列化的格式
     *  - Parameter: params 参数
     *  - Parameter: configuration 请求配置
     *  - Parameter: handler 请求回调 for more @see XHttp.Result
     *  - Return: URLSessionTask
     */
    static public func request(_ path: String, _ method: XHttp.Method?, _ requestSerializer: XHttp.Serializer.Request?, _ params: Any?, _ configuration: XHttp.Configuration? = nil, _ handler: ((_ result: XHttp.Result) -> Void)? = nil) -> URLSessionTask? {
        
        let configuration = configuration ?? XHttp.Configuration.defaultConfiguration
        var newPath = path
        if !path.hasPrefix("http") {
            newPath = (configuration.host ?? "") + path
        }
        guard let url = URL(string: newPath) else { return nil }
        
        #if DEBUG
        NSLog("XHttp  request before path: \(url.absoluteString)     body: \(String(describing: params))")
        #endif
        
        /* -------------------  请求前配置 ---------------- */
        var request = URLRequest(url: url)
        request.httpMethod = method?.rawValue ?? configuration.method.rawValue
        request.cachePolicy = configuration.cachePolicy
        request.timeoutInterval = configuration.timeoutInterval
        request.allowsCellularAccess = configuration.allowsCellularAccess
        for (field, value) in configuration.allHTTPHeaderFields {
            request.setValue(value, forHTTPHeaderField: field)
        }
        
        let requestSerializer = requestSerializer ?? configuration.requestSerializer
        if let params = params {
            switch requestSerializer {
            case .json:
                do {
                    let data = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                    if method == XHttp.Method.GET, let ext = String(data: data, encoding: .utf8) {
                        request.url = URL(string: url.absoluteString + "?\(ext)")
                    } else {
                        request.httpBody = data
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    }
                } catch {
                    // 传递参数错误
                    _processOnMain {
                        handler?(.failure(XHttp.HttpError.requestSerializerError))
                    }
                    return nil
                }
            case .query:
                if let params = params as? [AnyHashable: Any] {
                    var paramString = params.reduce("", { (result, arg1) -> String in
                        let (key, value) = arg1
                        return "\(result)\(result == "" ? "" : "&")\(key)=\(String(describing: value))"
                    })
                    if method == XHttp.Method.GET {
                        request.url = URL(string: url.absoluteString + "?\(paramString)")
                    } else {
                        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
                        request.httpBody = paramString.data(using: .utf8)
                    }
                }
            default:
                if let paramString = params as? String {
                    if method == XHttp.Method.GET {
                        request.url = URL(string: url.absoluteString + "?\(paramString)")
                    } else {
                        request.httpBody = paramString.data(using: .utf8)
                    }
                }
            }
        }
        
        #if DEBUG
        NSLog("XHttp  request after path: \(url.absoluteString)    body: \(request.httpBody != nil ? String(data: request.httpBody!, encoding: .utf8) ?? "nil" : "nil")")
        #endif
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            #if DEBUG
            NSLog("XHttp  response:  \(String(describing: response?.url?.absoluteString))     success: \(String(describing: String(data: data ?? Data(), encoding: .utf8)))")
            #endif
            
            if error != nil {
                _processOnMain {
                    handler?(.failure(error!))
                }
            } else {
                let responseSerializer = configuration.responseSerializer
                switch responseSerializer {
                case .json:
                    do {
                        if let data = data {
                            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                            _processOnMain {
                                handler?(.success(jsonObject))
                            }
                        } else {
                            // 服务器返回参数错误
                            _processOnMain {
                                handler?(.failure(XHttp.HttpError.serverSystemError))
                            }
                        }
                    } catch {
                        // 解析数据错误
                        _processOnMain {
                            handler?(.failure(XHttp.HttpError.responseSerializerError))
                        }
                    }
                default:
                    _processOnMain {
                        handler?(.success(data))
                    }
                }
            }
        }
        task.resume()
        return task
    }
    
    static private func _processOnMain(_ block: @escaping (() -> Void)) {
        DispatchQueue.main.async {
            block()
        }
    }
    
}

