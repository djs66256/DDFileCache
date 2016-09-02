//
//  DDLevelDB.h
//  DDFileCache
//
//  Created by daniel on 16/9/2.
//  Copyright © 2016年 Daniel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelDB.h"
#import "LDBSnapshot.h"

@interface LevelDB (DDLevelDB)

- (void)enumerateKeysAndObjectsBackward:(BOOL)backward startingAtKey:(id)key filteredByPrefix:(id)prefix usingBlock:(LevelDBKeyValueBlock)block;

@end

@interface LDBSnapshot (DDLevelDB)

- (void)enumerateKeysAndObjectsBackward:(BOOL)backward startingAtKey:(id)key filteredByPrefix:(id)prefix usingBlock:(LevelDBKeyValueBlock)block;

@end
