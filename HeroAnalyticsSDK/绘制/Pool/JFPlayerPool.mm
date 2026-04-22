//
//  JFPlayerPool.m
//  SCMusic
//
//  Created by feng on 2021/7/17.
//

#import "JFPlayerPool.h"
#import "JFPlayer.h"

@implementation JFPlayerPool

- (instancetype)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (id)create
{
    JFPlayer *player = [[JFPlayer alloc] init];
    return player;
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
