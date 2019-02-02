//
//  HttpResult.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

// 普通访问结果回调
public extension XHttp {
    
    public enum Result {
        
        case success(Any)
        
        case failure(Error)
        
    }
    
}

// MARK: 下载结果
public extension XHttp.Result {
    
    public enum Downloader {
        
        // 下载进度 (totalBytesWritten, totalBytesExpectedToWrite)
        case progress(Int64, Int64)
        
        // 成功（location为本地存储路径）
        case success(URL)
        
        // 失败
        case failure(Error)
    }
    
}

// MARK: 上传结果
public extension XHttp.Result {
    
    public enum Uploader {
        
        // 上传进度 (totalBytesSent, totalBytesExpectedToSend)
        case progress(Int64, Int64)
        
        // 成功
        case success()
        
        // 失败
        case failure(Error)
    }
    
}
