//
//  DDCache.swift
//  DDFileCache
//
//  Created by daniel on 16/9/2.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public class DDCache: NSObject, DDExpireCache {
    public typealias ObjectType = AnyObject
    public typealias KeyType = String
    private let memCache: NSCache
    private let fileCache: DDFileCache<ObjectType, NSString>
    
    convenience public init(name: String) {
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first ?? "/" as NSString
        self.init(path: path.stringByAppendingPathComponent("DDCache"), name: name)
    }
    
    public init(path: String, name: String) {
        memCache = NSCache()
        memCache.countLimit = 20
        fileCache = DDFileCache<ObjectType, NSString>(path: path, name: name)
    }
    
    public func setObject(obj: ObjectType?, forKey key: KeyType, timeInterval: NSTimeInterval) {
        if let obj = obj {
            fileCache.setObject(obj, forKey: key, timeInterval: timeInterval)
            let expireTime = NSDate(timeIntervalSinceNow: timeInterval)
            memCache.setObject(DDMemCacheInfo(data: obj, expire: expireTime), forKey: key)
        }
        else {
            removeObjectForKey(key)
        }
    }
    
    public func objectForKey(key: KeyType) -> ObjectType? {
        if let info = memCache.objectForKey(key) as? DDMemCacheInfo {
            if info.expire.timeIntervalSinceNow > 0 {
                return info.data
            }
            else {
                removeObjectForKey(key)
                return nil
            }
        }
        else {
            return fileCache.objectForKey(key)
        }
    }
    
    public func removeObjectForKey(key: KeyType) {
        memCache.removeObjectForKey(key)
        fileCache.removeObjectForKey(key)
    }
    
    public func removeAllObjects() {
        memCache.removeAllObjects()
        fileCache.removeAllObjects()
    }
    
    public func deleteDatabaseFromDisk() {
        fileCache.deleteDatabaseFromDisk()
        memCache.removeAllObjects()
    }
    
    private class DDMemCacheInfo {
        let data: ObjectType
        let expire: NSDate
        
        init(data: ObjectType, expire: NSDate) {
            self.data = data
            self.expire = expire
        }
    }
}
