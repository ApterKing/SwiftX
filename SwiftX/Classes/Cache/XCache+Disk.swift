//
//  XCache+Disk.swift
//  SwiftX
//
//  Created by wangcong on 2018/12/10.
//  Copyright © 2018 wangcong. All rights reserved.
//

import Foundation

/**
 *  磁盘缓存，使用的NSKeyedArchiver存储数据：
 *      NSNumber/Dictionary/NSDictionary/Array/Data/NSData/UIImage/Int/UInt... 以及 T: Encodable
 
 *  - Usage:
 *
 *      - Initial:
 *
 *      let configuration = XCache.Configuration.Disk.defaultConfiguration
 *      // or
 *      let configuration = XCache.Configuration.Disk(name: "target")
 *      // or
 *      let configuration = XCache.Configuration.Disk(name: nil, directoryURL: saveFileURL, maxSize: 1024 * 1024 * 1024, fileProtection: nil, expiry: .never)
 *      let disk = XCache.Disk(configuration)
 *
 *      - Save:
 *      try? disk.setObject(leon, forKey: "person", from: Person.self, expiry: .never)
 
 *      - fetch:
 *      if let person = try? disk.object(forKey: "person", to: Person.self) {
 *          print(person.age)
 *      }
 
 *      // or
 *      if let entry = try? disk.entry(forKey: "person", to: Person.self) {
 *          print(entry.object)
 *          print(entry.expiry)
 *          print(entry.fileURL)
 *      }
 *
 *      ... for more @see CacheAware
 */
public extension XCache {
    
    final public class Disk: CacheAware {
        
        fileprivate let config: XCache.Configuration.Disk
        public init(_ config: XCache.Configuration.Disk) {
            self.config = config
        }
        
        // 存储
        public func setObject(_ object: Any, forKey key: String, expiry: XCache.Expiry?) throws {
            let sanitizedKey = self.sanitizedKey(key)
            let expiry = expiry ?? config.expiry
            
            var data = NSMutableData()
            let archiver = NSKeyedArchiver(forWritingWith: data)
            archiver.encode(object, forKey: sanitizedKey)
            archiver.finishEncoding()
            
            do {
                let filePath = config.cachedURL.appendingPathComponent(sanitizedKey).path
                try FileManager.default.createFile(atPath: filePath, contents: data as Data, attributes: [FileAttributeKey.modificationDate: expiry.date])
            } catch {
                throw XCache.CacheError.dataWriteFailed
            }
        }
        
        
        // 查询
        public func entry(forKey key: String) throws -> XCache.Entry {
            let sanitizedKey = self.sanitizedKey(key)
            let fileURL = config.cachedURL.appendingPathComponent(sanitizedKey)
            
            var fileData: Data?
            var expiryDate: Date?
            
            do {
                fileData = try Data(contentsOf: fileURL)
                expiryDate = try FileManager.default.attributesOfItem(atPath: fileURL.path)[.modificationDate] as? Date
            } catch {
                throw XCache.CacheError.dataReadFailed
            }
            guard let data = fileData, let date = expiryDate else {
                throw XCache.CacheError.notExists
            }
            
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            guard let object = unarchiver.decodeObject(forKey: sanitizedKey) else {
                throw XCache.CacheError.decodingFailed
            }
            unarchiver.finishDecoding()
            return Entry(object: object, expiry: .date(date), fileURL: fileURL)
        }
        
        
        // 删除
        public func removeObject(forKey key: String) throws {
            let fileURL = config.cachedURL.appendingPathComponent(sanitizedKey(key))
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            } else {
                throw XCache.CacheError.notExists
            }
        }
        
        public func removeObjectIfExpired(forKey key: String) throws {
            let entry = try self.entry(forKey: key)
            
            if entry.expired {
                try removeObject(forKey: key)
            }
        }
        
        public func removeAll() throws {
            try FileManager.default.removeItem(at: config.cachedURL)
            try FileManager.default.createDirectory(at: config.cachedURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        public func removeExpiredObjects() throws {
            let storageURL = config.cachedURL
            let resourceKeys: [URLResourceKey] = [
                .isDirectoryKey,
                .contentModificationDateKey,
                .totalFileAllocatedSizeKey
            ]
            var resourceObjects = [(url: Foundation.URL, resourceValues: URLResourceValues)]()
            var filesToDelete = [URL]()
            var totalSize: UInt = 0
            let fileEnumerator = FileManager.default.enumerator(
                at: storageURL,
                includingPropertiesForKeys: resourceKeys,
                options: .skipsHiddenFiles,
                errorHandler: nil
            )
            
            guard let urlArray = fileEnumerator?.allObjects as? [URL] else {
                return
            }
            
            for url in urlArray {
                let resourceValues = try url.resourceValues(forKeys: Set(resourceKeys))
                guard resourceValues.isDirectory != true else {
                    continue
                }
                
                if let date = resourceValues.contentModificationDate, date.timeIntervalSince(Date()) < 0 {
                    filesToDelete.append(url)
                    continue
                }
                
                if let fileSize = resourceValues.totalFileAllocatedSize {
                    totalSize += UInt(fileSize)
                    resourceObjects.append((url: url, resourceValues: resourceValues))
                }
            }
            
            for url in filesToDelete {
                try FileManager.default.removeItem(at: url)
            }
            
            try removeObjectsIfCacheSizeExceed(resourceObjects, totalSize: totalSize)
        }
        
        // 判定是否存在数据
        public func existObject(forKey key: String) -> Bool {
            let fileURL = config.cachedURL.appendingPathComponent(sanitizedKey(key))
            return FileManager.default.fileExists(atPath: fileURL.path)
        }
        
        ///  ------    private  -------
        private func sanitizedKey(_ key: String) -> String {
            return key.replacingOccurrences(of: "[^a-zA-Z0-9_]+", with: "-", options: .regularExpression, range: nil)
        }
        
        // 如果缓存数据大小超过了设置的最大值，则删除expire最旧的数据
        private func removeObjectsIfCacheSizeExceed(_ objects: [(url: Foundation.URL, resourceValues: URLResourceValues)], totalSize: UInt) throws {
            guard config.maxSize > 0 && totalSize > config.maxSize else {
                return
            }
            
            var totalSize = totalSize
            
            // 依据最大值的一般删除数据
            let targetSize = config.maxSize / 2
            
            let sortedFiles = objects.sorted {
                if let time1 = $0.resourceValues.contentModificationDate?.timeIntervalSinceReferenceDate,
                    let time2 = $1.resourceValues.contentModificationDate?.timeIntervalSinceReferenceDate {
                    return time1 > time2
                } else {
                    return false
                }
            }
            
            for file in sortedFiles {
                try FileManager.default.removeItem(at: file.url)
                
                if let fileSize = file.resourceValues.totalFileAllocatedSize {
                    totalSize -= UInt(fileSize)
                }
                
                if totalSize < targetSize {
                    break
                }
            }
        }
        
        private func totalSize() throws -> UInt64 {
            var size: UInt64 = 0
            let contents = try FileManager.default.contentsOfDirectory(atPath: config.cachedURL.path)
            for pathComponent in contents {
                let filePath = NSString(string: config.cachedURL.path).appendingPathComponent(pathComponent)
                let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
                if let fileSize = attributes[.size] as? UInt64 {
                    size += fileSize
                }
            }
            return size
        }
        
    }
    
}
