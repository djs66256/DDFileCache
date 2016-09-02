//
//  DDLevelDB.m
//  DDFileCache
//
//  Created by daniel on 16/9/2.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import "DDLevelDB.h"

@implementation LevelDB (DDLevelDB)

- (void)enumerateKeysAndObjectsBackward:(BOOL)backward startingAtKey:(id)key filteredByPrefix:(id)prefix usingBlock:(LevelDBKeyValueBlock)block {
    [self enumerateKeysAndObjectsBackward:backward lazily:YES startingAtKey:key filteredByPredicate:nil andPrefix:prefix usingBlock:block];
}

@end

@implementation LDBSnapshot (DDLevelDB)

- (void)enumerateKeysAndObjectsBackward:(BOOL)backward startingAtKey:(id)key filteredByPrefix:(id)prefix usingBlock:(LevelDBKeyValueBlock)block {
    [self enumerateKeysAndObjectsBackward:backward lazily:YES startingAtKey:key filteredByPredicate:nil andPrefix:prefix usingBlock:block];
}

@end
