//
//  UIImageView+kf.swift
//  SwiftX
//
//  Created by wangcong on 2019/2/16.
//

import UIKit
import Kingfisher

public extension UIImageView {
    
    public func kf_cancelImageRequest() {
        self.kf.cancelDownloadTask()
    }
    
    public func kf_setImageWithRoundCorner(
        urlString: String,
        placeholder: UIImage?,
        cornerRadius: CGFloat? = nil,
        size: CGSize? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: CompletionHandler? = nil) {
        
        let s = size ?? bounds.size
        let radius = cornerRadius ?? min(s.width, s.height) / 2
        let url = URL(string: urlString)
        kf_setImageWithRoundCorner(url: url, placeholder: placeholder, cornerRadius: radius, size: s, progressBlock: progressBlock, completionHandler: completionHandler)
    }
    
    public func kf_setImageWithRoundCorner(
        url: URL?,
        placeholder: UIImage?,
        cornerRadius: CGFloat? = nil,
        size: CGSize? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: CompletionHandler? = nil) {
        
        let s = size ?? bounds.size
        guard s.width != 0 && s.height != 0 else { // bug fix: 当size为0，导致kingfiser获取绘制图片上下文失败，crash
            return
        }
        
        let radius = cornerRadius ?? min(s.width, s.height) / 2
        let scale = UIScreen.main.scale
        let roundProcessor = RoundCornerImageProcessor(cornerRadius: radius * scale, targetSize: CGSize(width: s.width * scale, height: s.height * scale))
        kf_setImage(url: url, placeholder: placeholder, size: s, options: [.processor(roundProcessor), .cacheSerializer(RoundCornerImageCacheSerializer.default)], progressBlock: progressBlock, completionHandler: completionHandler)
    }
    
    public func kf_setImage(
        urlString: String?,
        placeholder: UIImage?,
        size: CGSize? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: CompletionHandler? = nil) {
        
        let s = size ?? CGSize(width: min(bounds.size.width, 1242), height: min(bounds.size.height, 2208))
        let url = URL(string: urlString ?? "")
        kf_setImage(url: url, placeholder: placeholder, size: s, options: options, progressBlock: progressBlock, completionHandler: completionHandler)
    }
    
    public func kf_setImage(
        url: URL?,
        placeholder: UIImage?,
        size: CGSize? = nil,
        options: KingfisherOptionsInfo? = nil,
        progressBlock: DownloadProgressBlock? = nil,
        completionHandler: CompletionHandler? = nil) {
        
        let s = size ?? CGSize(width: min(bounds.size.width, 1242), height: min(bounds.size.height, 2208))
        kf.setImage(with: url, placeholder: placeholder, options: options, progressBlock: progressBlock, completionHandler: completionHandler)
    }
    
}

private struct RoundCornerImageCacheSerializer: CacheSerializer {

    static let `default` = RoundCornerImageCacheSerializer()
    private init() {}
    
    func data(with image: Image, original: Data?) -> Data? {
        return image.kf.pngRepresentation()
    }
    
    func image(with data: Data, options: KingfisherParsedOptionsInfo) -> Image? {
        let options = options
        let image = Image(data: data, scale: options.scaleFactor)
        return image
    }
    
}
