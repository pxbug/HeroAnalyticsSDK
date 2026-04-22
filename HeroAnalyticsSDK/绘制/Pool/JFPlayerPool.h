//
//  JFPlayerPool.h
//  SCMusic
//
//  Created by feng on 2021/7/17.
//

#import "JFObjectPool.h"
@class JFPlayer;

NS_ASSUME_NONNULL_BEGIN

@interface JFPlayerPool : JFObjectPool

@property (nonatomic, strong) JFPlayer *player;

@end

NS_ASSUME_NONNULL_END
