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

        /// MARK: GET
        static public func get(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.GET, requestSerializer, params, configuration)
        }

        /// MARK: HEAD
        static public func head(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.HEAD, requestSerializer, params, configuration)
        }

        /// MARK: POST
        static public func post(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.POST, requestSerializer, params, configuration)
        }

        /// MARK: PUT
        static public func put(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.PUT, requestSerializer, params, configuration)
        }

        /// MARK: DELETE
        static public func delete(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.DELETE, requestSerializer, params, configuration)
        }

        /// MARK: OPTIONS
        static public func options(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.OPTIONS, requestSerializer, params, configuration)
        }

        /// MARK: TRACE
        static public func trace(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.TRACE, requestSerializer, params, configuration)
        }

        /// MARK: PATCH
        static public func patch(_ path: String, _ requestSerializer: XHttp.Serializer.Request? = nil, _ params: Any? = nil, _ configuration: XHttp.Configuration? = nil) -> Observable<Any> {
            return request(path, XHttp.Method.PATCH, requestSerializer, params, configuration)
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
