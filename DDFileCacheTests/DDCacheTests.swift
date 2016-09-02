//
//  DDCacheTests.swift
//  DDFileCache
//
//  Created by daniel on 16/9/2.
//  Copyright © 2016年 Daniel. All rights reserved.
//

import XCTest

@testable import DDFileCache

class DDCacheTests: XCTestCase {
    
    private var cache : DDCache?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.cache = DDCache(name: "test")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        self.cache?.deleteDatabaseFromDisk()
    }
    
    func testExists() {
        XCTAssert(self.cache != nil)
    }
    
    func testSetGet() {
        let str = "teardown code here. This method is called after中文 啊 😂"
        let key = "testSetGetKey"
        self.cache?.setObject(str, forKey: key, timeInterval: 10)
        let str2 = self.cache?.objectForKey(key) as? String
        XCTAssert(str == str2)
        
        let str3 = "de here. This method is c"
        self.cache?.setObject(str3, forKey: key, timeInterval: 10)
        let str4 = self.cache?.objectForKey(key) as? String
        XCTAssert(str3 == str4)
    }
    
    func testExpire() {
        let str = "teardown code here. This method is called after中文 啊 😂"
        let key = "testExpireKey"
        self.cache?.setObject(str, forKey: key, timeInterval: 1)
        sleep(3)
        let str2 = self.cache?.objectForKey(key)
        XCTAssert(str2 == nil)
    }
    
    func testExpire2() {
        let str = "teardown code here. This method is called after中文 啊 😂"
        let key = "testExpire2Key"
        self.cache?.setObject(str, forKey: key, timeInterval: 1)
        sleep(3)
        let str2 = "down code here. This metho"
        self.cache?.setObject(str2, forKey: key, timeInterval: 2)
        let str3 = self.cache?.objectForKey(key) as? String
        XCTAssert(str3 == str2)
    }
    
}
