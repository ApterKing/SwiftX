//
//  XHttp+Rx.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation
import RxSwift

/**
 *  MARK: 为XHttpManager增加Rx功能
 *
 *   - 请求：
 *      XHttp.Rx.get("xx", .json, nil) { (data, error) in }
 *      XHttp.Rx.post("xx", .json, nil) { (data, error) in }
 *
 */
public extension XHttp {
    
    final public class Rx {
        
        /**
         *  默认配置  convience post请求
         *  - Parameter: path  请求地址（如果在configuration配置了host，那么此时可以是短链）
         *  - Parameter: requestSerializer  请求时参数需要序列化的格式
         *  - Parameter: params 参数
         */
        static public func post(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.POST, requestSerializer, params)
        }
        
        /**
         *  特殊情况下的 convience post请求（如：与整个项目不一致的第三方网络请求）
         *  - Parameter: path  请求地址（如果在configuration配置了host，那么此时可以是短链）
         *  - Parameter: requestSerializer  请求时参数需要序列化的格式
         *  - Parameter: params 参数
         *  - Parameter: configuration 非默认配置其他特殊配置
         */
        static public func post(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.POST, requestSerializer, params, configuration)
        }
        
        /**
         *  默认配置 convience get请求
         *  - Parameter: path  请求地址（如果在configuration配置了host，那么此时可以是短链）
         *  - Parameter: requestSerializer  请求时参数需要序列化的格式
         *  - Parameter: params 参数
         */
        static public func get(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.GET, requestSerializer, params)
        }
        
        /**
         *  特殊情况下的 convience get请求（如：与整个项目不一致的第三方网络请求）
         *  - Parameter: path  请求地址（如果在configuration配置了host，那么此时可以是短链）
         *  - Parameter: requestSerializer  请求时参数需要序列化的格式
         *  - Parameter: params 参数
         *  - Parameter: configuration 非默认配置其他特殊配置
         */
        static public func get(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.GET, requestSerializer, params, configuration)
        }
        
        /**
         *  网络请求
         *  - Parameter: path  请求地址（如果在configuration配置了host，那么此时可以是短链）
         *  - Parameter: method GET/POST
         *  - Parameter: requestSerializer  请求时参数需要序列化的格式
         *  - Parameter: params 参数
         *  - Parameter: configuration 请求配置
         */
        static public func request(_ path: String, _ method: XHttp.Method?, _ requestSerializer: XHttp.Serializer.Request?, _ params: Any?, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return Observable<Any>.create({ (observer) -> Disposable in
                let task = XHttp.request(path, method, requestSerializer, params, configuration, { (result) in
                    switch result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
                return Disposables.create {
                    task?.cancel()
                }
            })
        }
        
    }
    
}
