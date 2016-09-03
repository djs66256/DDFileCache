//
//  DDExpireCache.swift
//  DDFileCache
//
//  Created by daniel on 16/9/2.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import UIKit

public protocol DDExpireCache: NSObjectProtocol {
    associatedtype ObjectType
    associatedtype KeyType
    func objectForKey(key: KeyType) -> ObjectType?
    func setObject(obj: ObjectType?, forKey key: KeyType, timeInterval: NSTimeInterval)
    func removeObjectForKey(key: KeyType)
    
    func removeAllObjects()
}
