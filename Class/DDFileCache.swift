//
//  DDFileCache.swift
//  DDFileCache
//
//  Created by daniel on 16/9/2.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

@objc class DDFileCacheConfig: NSObject {
    let path: String
    let name: String
    
    var checkExpireInterval: NSTimeInterval = 3600   // a hour
    
    var createIfMissing = true
    var createIntermediateDirectories = true
    var errorIfExists = false
    var paranoidCheck = false
    var compression  = true
    var filterPolicy: Int32 = 0
    var cacheSize: size_t = 0
    
    init(path: String, name: String) {
        self.path = path
        self.name = name
    }
}

class DDFileCache<ObjectType: AnyObject, KeyType: AnyObject>: NSObject, DDExpireCache {

    private let config: DDFileCacheConfig
    private let db: LevelDB
    private let prefixKeyString = "__info__"
    private let expireCheckKey = "__expire_check_key"
    private var removingExpireData = false
    
    convenience init(name: String) {
        let path = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first
        if let path = path {
            self.init(path: "\(path)/DDFileCache", name: name)
        }
        else {
            self.init(path: "/", name: name)
        }
    }
    
    convenience init(path: String, name: String) {
        let config = DDFileCacheConfig(path: path, name: name);
        self.init(config: config)
    }
    
    init(config: DDFileCacheConfig) {
        self.config = config
        
        var dbOptions = LevelDBOptions()
        dbOptions.createIfMissing = ObjCBool(config.createIfMissing)
        dbOptions.createIntermediateDirectories = ObjCBool(config.createIntermediateDirectories)
        dbOptions.errorIfExists = ObjCBool(config.errorIfExists)
        dbOptions.paranoidCheck = ObjCBool(config.paranoidCheck)
        dbOptions.compression = ObjCBool(config.compression)
        dbOptions.filterPolicy = config.filterPolicy
        dbOptions.cacheSize = config.cacheSize
        
        db = LevelDB(path: config.path, name: config.name, andOptions: dbOptions)
    }
    
    func setObject(obj: ObjectType?, forKey key: KeyType, timeInterval: NSTimeInterval) {
        if let obj = obj {
            checkExpireObjects()
            
            db.setObject(obj, forKey: key)
            let info = DDFileCacheInfo(key: infoKeyFromOriginKey(key), timeInterval: timeInterval)
            let infoKey = infoKeyFromOriginKey(key)
            db.setObject(info, forKey: infoKey)
        }
        else {
            removeObjectForKey(key)
        }
    }
    
    func objectForKey(key: KeyType) -> ObjectType? {
        checkExpireObjects()
        
        let infoKey = infoKeyFromOriginKey(key)
        if let info = db.objectForKey(infoKey) as? DDFileCacheInfo {
            if info.expire.timeIntervalSinceNow > 0 {
                return db.objectForKey(key) as? ObjectType
            }
            else {
                removeObjectForKey(key)
            }
        }
        return nil;
    }
    
    func removeObjectForKey(key: KeyType) {
        let infoKey = infoKeyFromOriginKey(key)
        let batch = db.newWritebatch()
        batch.removeObjectForKey(key)
        batch.removeObjectForKey(infoKey)
        batch.apply()
        
        checkExpireObjects()
    }
    
    func removeAllObjects() {
        db.removeAllObjects()
    }
    
    func deleteDatabaseFromDisk() {
        db.deleteDatabaseFromDisk()
    }
    
    private func infoKeyFromOriginKey(key: KeyType) -> String {
        if key is String || key is NSValue {
            return "\(self.prefixKeyString)\(key)"
        }
        else {
            let keyData = NSKeyedArchiver.archivedDataWithRootObject(key)
            return "\(self.prefixKeyString)\(keyData)"
        }
    }
    
    private func removeExpireObjects() {
        let snap = db.newSnapshot()
        snap.enumerateKeysAndObjectsBackward(true, startingAtKey: nil, filteredByPrefix: self.prefixKeyString) { (key: UnsafeMutablePointer<LevelDBKey>, obj: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) in
            if let info = obj as? DDFileCacheInfo {
                if info.expire.timeIntervalSinceNow <= 0 {
                    let batch = self.db.newWritebatch()
                    batch.removeObjectForKey(NSStringFromLevelDBKey(key))
                    batch.removeObjectForKey(info.key)
                    batch.apply()
                }
            }
        }
    }
    
    private func checkExpireObjects() {
        if let time = db.objectForKey(expireCheckKey) as? NSDate {
            if time.timeIntervalSinceNow <= 0 {
                dispatch_async(dispatch_get_main_queue()) {
                    if !self.removingExpireData {
                        self.removingExpireData = true
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                            self.removeExpireObjects()
                            let time = NSDate(timeIntervalSinceNow: self.config.checkExpireInterval)
                            self.db.setObject(time, forKey: self.expireCheckKey)
                            self.removingExpireData = false
                        }
                    }
                }
            }
        }
        else {
            db.setObject(NSDate(timeIntervalSinceNow: config.checkExpireInterval), forKey: expireCheckKey)
        }
    }
}

private class DDFileCacheInfo: NSObject, NSCoding {
    let key: String
    let expire: NSDate
    let version: Int
    
    static let currentVersion = 1
    
    init(key: String, timeInterval: NSTimeInterval) {
        self.key = key
        self.expire = NSDate(timeIntervalSinceNow: timeInterval)
        self.version = DDFileCacheInfo.currentVersion
    }
    
    @objc required init?(coder aDecoder: NSCoder) {
        self.key = aDecoder.decodeObjectForKey("key") as? String ?? ""
        self.expire = aDecoder.decodeObjectForKey("expire") as? NSDate ?? NSDate()
        self.version = aDecoder.decodeIntegerForKey("version")  ?? DDFileCacheInfo.currentVersion
    }
    
    @objc func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.key, forKey: "key")
        aCoder.encodeObject(self.expire, forKey: "expire")
        aCoder.encodeInteger(self.version, forKey: "version")
    }
}
