


#import <UIKit/UIKit.h>
#import "YYThreadSafeArray.h"
#import "JFOverlayView.h"
#import "imgui.h"


@class JFFloatingLogView, JFPlayer;

@interface ImGuiView : NSObject

@property (nonatomic, assign) long module;
@property (nonatomic, assign) long battle;
@property (nonatomic, assign) long monster;

@property (nonatomic, assign) long vThirdPersonCamera;
@property (nonatomic, assign) long camera;
@property (nonatomic, assign) long aimHelper;
@property (nonatomic, assign) long playerListAddr;

@property (nonatomic, assign) bool isFire;
@property (nonatomic, assign) bool isJiMiao;

@property (nonatomic, strong) JFPlayer *localPlayer;
@property (nonatomic, strong) YYThreadSafeArray *playerList;
@property (nonatomic, strong) JFPlayer *lockPlayer;

@property (nonatomic, strong) JFOverlayView *overlayView;
@property (nonatomic, strong) JFFloatingLogView *floatingLogView;
@property (nonatomic, strong) JFFloatingMenuView *floatingMenuView;

@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *buildPartList;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *doorInfoList;
@property (nonatomic, assign) long doorMgr;
@property (nonatomic, assign) NSMutableArray<NSNumber *> *BagGun;
+ (ImGuiView *)getInstance;
/// 辅助逻辑入口
- (void)entry;
- (void)entry2;

/// 取消定时器
- (void)cancelTimer;

- (void)fly;
- (void)modifyLocalPlayerPosX:(float)x y:(float)y z:(float)z;

@end
