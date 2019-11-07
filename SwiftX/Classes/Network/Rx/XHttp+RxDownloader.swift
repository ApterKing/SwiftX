//
//  XHttp+RxDownloader.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation
import RxSwift

/**
 *  下载文件
 *  - Usage
 *      XHttp.Rx.Downloader.download...
 */
public extension XHttp.Rx {
    
    final public class Downloader {
        
        /**
         *  通过url 下载文件
         *  - Parameter: url 文件下载地址
         *  - Parameter: fileURL 文件在本地存放位置，如果此参数=nil那么文件将保存到临时位置
         *  - Return: Single<XHttp.Result.Downloader> for more @see XHttp.Result.Downloader，
         */
        static public func downloadTask(with url: URL, location fileURL: URL? = nil) -> Single<XHttp.Result.Downloader> {
            return Single<XHttp.Result.Downloader>.create(subscribe: { (observer) -> Disposable in
                let downloadTask = XHttp.Downloader.downloadTask(with: url, location: fileURL, handler: { (result) in
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
                    downloadTask.cancel()
                }
            })
        }
        
        /**
         *  通过request 下载文件
         *  - Parameter: request
         *  - Parameter: fileURL 文件在本地存放位置，如果此参数=nil那么文件将保存到临时位置
         *  - Return: Single<XHttp.Result.Downloader> for more @see XHttp.Result.Downloader，
         */
        static public func downloadTask(with request: URLRequest, location fileURL: URL? = nil) -> Single<XHttp.Result.Downloader> {
            return Single<XHttp.Result.Downloader>.create(subscribe: { (observer) -> Disposable in
                let downloadTask = XHttp.Downloader.downloadTask(with: request, location: fileURL, handler: { (result) in
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
                    downloadTask.cancel()
                }
            })
        }
        
        /**
         *  通过resumeData 下载文件
         *  - Parameter: resumeData 从上次取消的位置开始重新下载，注意-需要与：cancel(byProducingResumeData: completionHandler)配合使用
         *  - Parameter: fileURL 文件在本地存放位置，如果此参数=nil那么文件将保存到临时位置
         *  - Return: Single<XHttp.Result.Downloader> for more @see XHttp.Result.Downloader，
         */
        static public func downloadTask(withResumeData resumeData: Data, location fileURL: URL? = nil) -> Single<XHttp.Result.Downloader> {
            return Single<XHttp.Result.Downloader>.create(subscribe: { (observer) -> Disposable in
                let downloadTask = XHttp.Downloader.downloadTask(withResumeData: resumeData, location: fileURL, handler: { (result) in
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
                    downloadTask.cancel()
                }
            })
        }
        
    }
    
}


