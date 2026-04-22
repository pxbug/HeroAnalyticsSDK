//
//  JFObjectPool.h
//  SCMusic
//
//  Created by feng on 2021/7/17.
//

#import <Foundation/Foundation.h>

@protocol ObjPoolListener<NSObject>
 
@required
- (id)create;

// 验证对象的有效性
- (BOOL)validate:(id)obj;

// 回收对象
- (void)recycObj:(id)obj;

// 获取对象
- (id)getObjFromPool;

// 将对象放回池中
- (void)putObj2Pool:(id)obj;

@end

@interface JFObjectPool : NSObject<ObjPoolListener>

@property (nonatomic, strong) NSMutableArray *inUseList;
@property (nonatomic, strong) NSMutableArray *availableList;

@end

