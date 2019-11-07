//
//  XHttp+RxUploader.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation
import RxSwift

/**
 *  上传数据
 *  - Usage
 *      XHttp.Rx.Uploader.upload...
 */
public extension XHttp.Rx {
    
    final public class Uploader {
        
        /**
         *  通过fileURL 上传数据
         *  - Parameter: request
         *  - Parameter: fileURL 待上传文件地址
         *  - Return: Single<XHttp.Result.Uploader> for more @see XHttp.Result.Uploader，
         */
        static public func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> Single<XHttp.Result.Uploader> {
            return Single<XHttp.Result.Uploader>.create(subscribe: { (observer) -> Disposable in
                let uploadTask = XHttp.Uploader.uploadTask(with: request, fromFile: fileURL, handler: { (result) in
                    switch result {
                    case .progress(_, _):
                        observer(.success(result))
                    case .success(_):
                        observer(.success(result))
                    case .failure(let error):
                        observer(.error(error))
                    }
                })
                
                return Disposables.create {
                    uploadTask.cancel()
                }
            })
        }
        
        /**
         *  通过bodyData 上传数据
         *  - Parameter: request
         *  - Parameter: bodyData 待上传数据
         *  - Return: Single<XHttp.Result.Uploader> for more @see XHttp.Result.Uploader，
         */
        static public func uploadTask(with request: URLRequest, from bodyData: Data) -> Single<XHttp.Result.Uploader> {
            return Single<XHttp.Result.Uploader>.create(subscribe: { (observer) -> Disposable in
                let uploadTask = XHttp.Uploader.uploadTask(with: request, from: bodyData, handler: { (result) in
                    switch result {
                    case .progress(_, _):
                        observer(.success(result))
                    case .success(_):
                        observer(.success(result))
                    case .failure(let error):
                        observer(.error(error))
                    }
                })
                
                return Disposables.create {
                    uploadTask.cancel()
                }
            })
        }
        
        static public func uploadTask(withStreamedRequest request: URLRequest) -> Single<XHttp.Result.Uploader> {
            return Single<XHttp.Result.Uploader>.create(subscribe: { (observer) -> Disposable in
                let uploadTask = XHttp.Uploader.uploadTask(withStreamedRequest: request, handler: { (result) in
                    switch result {
                    case .progress(_, _):
                        observer(.success(result))
                    case .success(_):
                        observer(.success(result))
                    case .failure(let error):
                        observer(.error(error))
                    }
                })
                
                return Disposables.create {
                    uploadTask.cancel()
                }
            })
        }
    }
    
}


