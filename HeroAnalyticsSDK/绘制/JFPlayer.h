//
//  JFPlayer.h
//  SCMusic
//
//  Created by feng on 2021/7/14.
//

#import <UIKit/UIKit.h>
#import "JFCommon.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFPlayer : NSObject

@property (nonatomic, assign) long base;
@property (nonatomic, assign) long roleId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic,strong) NSString *holdgunname;
@property (nonatomic, assign) int holdgun;
@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int maxHp;
@property (nonatomic, assign) int groupId;

@property (nonatomic, assign) bool offline;

@property (nonatomic, assign) PlayerType type;
@property (nonatomic) Vector3 worldPos;
@property (nonatomic, assign) CGRect box;

@property (nonatomic, assign) int distance;
@property (nonatomic, assign) bool isVisible;
@property (nonatomic, assign) bool 最佳目标;



@end

NS_ASSUME_NONNULL_END
