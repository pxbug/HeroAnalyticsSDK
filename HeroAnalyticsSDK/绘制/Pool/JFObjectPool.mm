//
//  JFObjectPool.m
//  SCMusic
//
//  Created by feng on 2021/7/17.
//

#import "JFObjectPool.h"

@implementation JFObjectPool

- (id)init
{
    if(self = [super init]) {
        self.inUseList = [NSMutableArray array];
        self.availableList = [NSMutableArray array];
    }
    return self;
}

- (id)getObjFromPool
{
    __block id tmpObj;
    if (self.availableList.count > 0) {
        [self.availableList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* _Nonnull stop) {
            tmpObj = obj;
            if ([self validate:obj]) {
                [self.availableList removeObject:tmpObj];
                [self.inUseList addObject:tmpObj];
                *stop = YES;
            } else {
                [self.availableList removeObject:tmpObj];
                [self recycObj:tmpObj];
                *stop = true;
            }
            
        }];
    } else {
        tmpObj = [self create];
        [self.inUseList addObject:tmpObj];
    }
    return tmpObj;
}

- (void)putObj2Pool:(id)obj
{
    [self.inUseList removeObject:obj];
    if ([self validate:obj]) {
        [self.availableList addObject:obj];
    } else {
        [self recycObj:obj];
    }
}

- (id)create
{
    return [[NSObject alloc] init];
}

- (BOOL)validate:(id)obj
{
    return obj != nil;
}

- (void)recycObj:(id)obj
{
    obj = nil;
}

@end
