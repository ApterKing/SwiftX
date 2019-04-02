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
         *  - Return: Observable<XHttp.Result.Uploader> for more @see XHttp.Result.Uploader，
         *              注意：这里onNext 只会返回.progress及.success, onError返回.failure中的error
         */
        static public func uploadTask(with request: URLRequest, fromFile fileURL: URL) -> Observable<XHttp.Result.Uploader> {
            return Observable<XHttp.Result.Uploader>.create({ (observer) -> Disposable in
                let uploadTask = XHttp.Uploader.uploadTask(with: request, fromFile: fileURL, handler: { (result) in
                    switch result {
                    case .progress(_, _):
                        observer.onNext(result)
                    case .success(_):
                        observer.onNext(result)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
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
         *  - Return: Observable<XHttp.Result.Uploader> for more @see XHttp.Result.Uploader，
         *              注意：这里onNext 只会返回.progress及.success, onError返回.failure中的error
         */
        static public func uploadTask(with request: URLRequest, from bodyData: Data) -> Observable<XHttp.Result.Uploader> {
            return Observable<XHttp.Result.Uploader>.create({ (observer) -> Disposable in
                let uploadTask = XHttp.Uploader.uploadTask(with: request, from: bodyData, handler: { (result) in
                    switch result {
                    case .progress(_, _):
                        observer.onNext(result)
                    case .success(_):
                        observer.onNext(result)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
                
                return Disposables.create {
                    uploadTask.cancel()
                }
            })
        }
        
        static public func uploadTask(withStreamedRequest request: URLRequest) -> Observable<XHttp.Result.Uploader> {
            return Observable<XHttp.Result.Uploader>.create({ (observer) -> Disposable in
                let uploadTask = XHttp.Uploader.uploadTask(withStreamedRequest: request, handler: { (result) in
                    switch result {
                    case .progress(_, _):
                        observer.onNext(result)
                    case .success(_):
                        observer.onNext(result)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                })
                
                return Disposables.create {
                    uploadTask.cancel()
                }
            })
        }
    }
    
}


