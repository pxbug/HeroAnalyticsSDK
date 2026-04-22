


#import "ImGuiView.h"
#import <mach-o/dyld.h>
#import <mach/mach.h>
#import "JFCommon.h"
#import "JFPlayer.h"
#import "JFPlayerPool.h"
#import "utf.h"
#import <CydiaSubstrate/Substrate.h>
#include "offset.h"
#include "imgui.h"

#define 国服 @"com.lastdayrulessurvival.heroios"
#define 国际服 @"com.herogame.ios.lastdayrules"
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height

namespace Memory {
bool read(void *buffer, long addr, int len)
{
    vm_size_t size = 0;
    kern_return_t error = vm_read_overwrite(mach_task_self(), (vm_address_t)addr, len, (vm_address_t)buffer, &size);
    if(error != KERN_SUCCESS || size != len)
    {
        return false;
    }
    return true;
}

bool write(void *value, long addr, int len)
{
    kern_return_t error = vm_write(mach_task_self(), (vm_address_t)addr, (vm_offset_t)value, (mach_msg_type_number_t)len);
    if(error != KERN_SUCCESS)
    {
        return false;
    }
    return true;
}

/// 获取指定模块的基址
/// @param image_name 模块名称，/开头
long get_image_vmaddr_slide(const char * image_name)
{
    uint32_t count = _dyld_image_count();
    for (int i = 0; i < count; i++) {
        const char *path = _dyld_get_image_name(i);
        const char *name = strrchr(path, '/');
        
        if (name != NULL && strcmp(image_name, name) == 0) {
            return (long)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return -1;
}
};

#pragma mark - 启动
static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info)
{
    long base_addr = Memory::get_image_vmaddr_slide("/UnityFramework");
    [ImGuiView getInstance].module = base_addr;
    [[ImGuiView getInstance] entry2];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ImGuiView getInstance] entry];
    });
}

#pragma mark - ImGuiView
@interface ImGuiView ()

@property (nonatomic, strong) NSTimer *dataTimer;
@property (nonatomic, strong) NSTimer *aimTimer;
@property (nonatomic, strong) JFPlayerPool *playerPool;

@end

@implementation ImGuiView

- (instancetype)init
{
    if (self = [super init]) {
        self.playerList = [YYThreadSafeArray array];
        self.playerPool = [[JFPlayerPool alloc] init];
    }
    return self;
}

+(void)load{
    CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, NULL, CFNotificationSuspensionBehaviorDrop);
}



static ImGuiView *instance = nil;

+ (ImGuiView *)getInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

+ (id)allocWithZone:(struct _NSZone*)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

#pragma mark - 功能hook
// 初始化战斗场景，想要的大部分数据都在这下面
void (*Old_Battle__Init)(long thisPointer);
void Battle__Init(long thisPointer) {
    [ImGuiView getInstance].battle = thisPointer;
    Old_Battle__Init(thisPointer);
}


// 世界坐标转屏幕坐标
Vector3 (*Old_Camera__WorldToScreenPoint)(long thisPointer, long a2, Vector3 pos);
Vector3 Camera__WorldToScreenPoint(long thisPointer, long a2, Vector3 pos) {
    return Old_Camera__WorldToScreenPoint(thisPointer, a2, pos);
}

// 屏幕坐标转视角坐标
Vector3 (*Old_Camera__ScreenToViewportPoint)(long thisPointer, Vector3 pos);
Vector3 Camera__ScreenToViewportPoint(long thisPointer, Vector3 pos) {
    return Old_Camera__ScreenToViewportPoint(thisPointer, pos);
}

// Transform getter
Vector3 (*Old_UnityEngine_Transform__get_position)(long thisPointer);
Vector3 UnityEngine_Transform__get_position(long thisPointer) {
    return Old_UnityEngine_Transform__get_position(thisPointer);
}


// Transform setter
void (*Old_UnityEngine_Transform__set_position)(long thisPointer, Vector3 pos);
void UnityEngine_Transform__set_position(long thisPointer, Vector3 pos) {
    Old_UnityEngine_Transform__set_position(thisPointer, pos);
}

// 设置锁定视角
void (*Old_vThirdPersonCamera__SetLockAtPoint)(long thisPointer, Vector3 pos);
void vThirdPersonCamera__SetLockAtPoint(long thisPointer, Vector3 pos) {
    Old_vThirdPersonCamera__SetLockAtPoint(thisPointer, pos);
}

// 检测是否可见，倒地后检测也当不可见，所以这个函数里可以分析出倒地数据
bool (*Old_AimHelper__CheckTargetVisible)(long thisPointer, long target);
bool AimHelper__CheckTargetVisible(long thisPointer, long target) {
    return Old_AimHelper__CheckTargetVisible(thisPointer, target);
}

void (*Old_SC_UI_BattlePanel__OnDownFire)(long thisPointer, long go);
void SC_UI_BattlePanel__OnDownFire(long thisPointer, long go) {
    [ImGuiView getInstance].isFire = true;
    Old_SC_UI_BattlePanel__OnDownFire(thisPointer, go);
}

Vector3 (*Old_UnityEngine_Rigidbody__get_position)(long thisPointer);
Vector3 UnityEngine_Rigidbody__get_position(long thisPointer) {
    return Old_UnityEngine_Rigidbody__get_position(thisPointer);
}

void (*Old_SC_UI_BattlePanel__OnUpFire)(long thisPointer, long go);
void SC_UI_BattlePanel__OnUpFire(long thisPointer, long go) {
    [ImGuiView getInstance].isFire = false;
    Old_SC_UI_BattlePanel__OnUpFire(thisPointer, go);
}


long (*Old_Battle__GetNearOtherAndSelfPlayers)(long thisPointer, Vector3 pos, float checkRange);
long Battle__GetNearOtherAndSelfPlayers(long thisPointer, Vector3 pos, float checkRange) {
    return Old_Battle__GetNearOtherAndSelfPlayers(thisPointer, pos, checkRange);
}
void (*Old_Gun__BulletFire)(long thisPointer, long bulletControl, Vector3 pos);
void Gun__BulletFire(long thisPointer, long bulletControl, Vector3 pos) {
    long neckBoneTrans = 0;
    Vector3 lockPosition = pos;
    if ([ImGuiView getInstance].overlayView.追踪开关 &&
        [ImGuiView getInstance].lockPlayer &&
        Memory::read(&neckBoneTrans, [ImGuiView getInstance].lockPlayer.base + [ImGuiView getInstance].overlayView.追踪部位, sizeof(long))) {
        lockPosition = Old_UnityEngine_Transform__get_position(neckBoneTrans);
        Old_Gun__BulletFire(thisPointer, bulletControl, lockPosition);
    }else{
        Old_Gun__BulletFire(thisPointer, bulletControl, pos);
    }
}


//射击后坐力
void (*Old_DoOneShootRecoil)(long thisPointer);
void DoOneShootRecoil(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.无后开关) {
        Old_DoOneShootRecoil(thisPointer);
    }
}
//聚点
void (*Old_CaulateMoveAimRadius)(long thisPointer);
void CaulateMoveAimRadius(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.聚点开关) {
        Old_CaulateMoveAimRadius(thisPointer);
    }
}
void (*Old_CaulateShootAimRadius)(long thisPointer);
void CaulateShootAimRadius(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.聚点开关) {
        Old_CaulateShootAimRadius(thisPointer);
    }
}
//除草
void (*Old_GrassObject__AddToScene)(long thisPointer);
void GrassObject__AddToScene(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.除草开关) {
        Old_GrassObject__AddToScene(thisPointer);
    }
}
//除树
void (*Old_TreeObject__AddToScene)(long thisPointer);
void TreeObject__AddToScene(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.除树开关) {
        Old_TreeObject__AddToScene(thisPointer);
    }
}
//除石头与官方建筑
void (*Old_ThingsObject__AddToScene)(long thisPointer);
void ThingsObject__AddToScene(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.除石头与除建筑开关) {
        Old_ThingsObject__AddToScene(thisPointer);
    }
}
//水下行走
void (*Old_SwimState__CheckSwim)(long thisPointer);
void SwimState__CheckSwim(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.水下行走开关) {
        Old_SwimState__CheckSwim(thisPointer);
    }
}
void (*Old_SwimState__UpdatePlayerOxygen)(long thisPointer);
void SwimState__UpdatePlayerOxygen(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.水下行走开关) {
        Old_SwimState__UpdatePlayerOxygen(thisPointer);
    }
}
//无摔落伤害
void (*Old_FallState__Init)(long thisPointer);
void FallState__Init(long thisPointer) {}
void (*Old_FallState__CheckEnterFall)(long thisPointer);
void FallState__CheckEnterFall(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.不会摔伤开关) {
        Old_FallState__CheckEnterFall(thisPointer);
    }
}
void (*Old_FallState__DoHit)(long thisPointer);
void FallState__DoHit(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.不会摔伤开关) {
        Old_FallState__DoHit(thisPointer);
    }
}


void (*Old_ACE)();
void ACE() {}

void (*Old_ACE1)(long thisPointer);
void ACE1(long thisPointer){}

void (*Old_ACE2)(long thisPointer);
void ACE2(long thisPointer){}


//绿名开关
int (*Old_UnionMgr__IsSameUnion)(long thisPointer, bool roleId);
int UnionMgr__IsSameUnion(long thisPointer, bool roleId) {
    if (![ImGuiView getInstance].overlayView.绿名开关) {
        return Old_UnionMgr__IsSameUnion(thisPointer, roleId);
    }
    return 1;
}







// 刚体组件 isKinematic setter
void (*Old_UnityEngine_Rigidbody__set_isKinematic)(long thisPointer, bool isKinematic);
void UnityEngine_Rigidbody__set_isKinematic(long thisPointer, bool isKinematic) {
    Old_UnityEngine_Rigidbody__set_isKinematic(thisPointer, isKinematic);
}


#pragma mark - 有没有效果未知
void (*Old_UnityEngine_Rigidbody__set_velocity)(long thisPointer, Vector3 value);
void UnityEngine_Rigidbody__set_velocity(long thisPointer, Vector3 value) {
    return Old_UnityEngine_Rigidbody__set_velocity(thisPointer, value);
}

void (*Old_UnityEngine_Rigidbody__set_detectCollisions)(long thisPointer, bool value);
void UnityEngine_Rigidbody__set_detectCollisions(long thisPointer, bool value) {
    return Old_UnityEngine_Rigidbody__set_detectCollisions(thisPointer, value);
}

void (*Old_UnityEngine_Rigidbody__MovePosition)(long thisPointer, Vector3 position);
void UnityEngine_Rigidbody__MovePosition(long thisPointer, Vector3 position) {
    return Old_UnityEngine_Rigidbody__MovePosition(thisPointer, position);
}

long (*Old_UnityEngine_Component__get_gameObject)(long thisPointer);
long UnityEngine_Component__get_gameObject(long thisPointer) {
    return Old_UnityEngine_Component__get_gameObject(thisPointer);
}

long (*Old_UnityEngine_GameObject__get_transform)(long thisPointer);
long UnityEngine_GameObject__get_transform(long thisPointer) {
    return Old_UnityEngine_GameObject__get_transform(thisPointer);
}

// 子弹碰撞检测，在子弹快碰到目标后开启检测实现子弹穿墙，和子弹追踪配合食用
void (*Old_RaycastedDo)(long thisPointer);
void RaycastedDo(long thisPointer) {
    if ([ImGuiView getInstance].overlayView.穿山开关) {
        long Rigidbody = 0,neckBoneTrans = 0;;
        Memory::read(&Rigidbody, thisPointer + 0x20, sizeof(long)); // 刚体
        Vector3 rigdbody = Vector3(9999, 9999, 9999);
        Vector3 lockPosition_zm;
        if ([ImGuiView getInstance].lockPlayer &&
            Memory::read(&neckBoneTrans, [ImGuiView getInstance].lockPlayer.base + [ImGuiView getInstance].overlayView.追踪部位, sizeof(long))) {
            lockPosition_zm = Old_UnityEngine_Transform__get_position(neckBoneTrans);
        }
        Old_UnityEngine_Rigidbody__set_velocity(Rigidbody, rigdbody);
        Old_UnityEngine_Rigidbody__set_isKinematic(Rigidbody, true);
        Old_UnityEngine_Rigidbody__set_detectCollisions(Rigidbody, false);
        Old_UnityEngine_Rigidbody__MovePosition(Rigidbody, lockPosition_zm);
        
        long bullet_GameObject = Old_UnityEngine_Component__get_gameObject(Rigidbody);
        long bullet_transform = Old_UnityEngine_GameObject__get_transform(bullet_GameObject);
        Vector3 bullet_pos = Old_UnityEngine_Transform__get_position(bullet_transform);
        if (bullet_pos.distance(lockPosition_zm) < 1) {
            Old_RaycastedDo(thisPointer);
        }
    } else{
        Old_RaycastedDo(thisPointer);
    }
}

//灵魂穿墙
void (*Old_CheatLong__GetData)(long thisPointer);
void CheatLong__GetData(long thisPointer) {
    if (!([ImGuiView getInstance].overlayView.灵魂穿墙开关 || [ImGuiView getInstance].overlayView.灵魂穿墙开关2)) {
        Old_CheatLong__GetData(thisPointer);
    }
}
//锁定天气
void (*Old_DayNightSystem__Update)(long thisPointer);
void DayNightSystem__Update(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.锁定天气) {
        Old_DayNightSystem__Update(thisPointer);
    }
}
//踏空
void (*Old_Rigidbody__get_velocity)(long thisPointer);
void Rigidbody__get_velocity(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.踏空开关 ) {
        Old_Rigidbody__get_velocity(thisPointer);
    }
}
//定怪
void (*Old_dingguai__BBB)(long thisPointer);
void dingguai__BBB(long thisPointer) {}
//定炮台
void (*Old_dingpaotai__BBB)(long thisPointer);
void dingpaotai__BBB(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.定炮台开关) {
        Old_dingpaotai__BBB(thisPointer);
    }
}
//定坦克直升机战争机器
void (*Old_dingtk__BBB)(long thisPointer);
void dingtk__BBB(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.定坦克直升机开关) {
        Old_dingtk__BBB(thisPointer);
    }
}

void (*Old_hookshangsuo)(long thisPointer);
void hookshangsuo(long thisPointer) {
    if (![ImGuiView getInstance].overlayView.强制上锁开关) {
        Old_hookshangsuo(thisPointer);
    }
}

bool (*Old_CanOpenGlider)(long thisPointer);
bool CanOpenGlider(long thisPointer) {
    if([ImGuiView getInstance].overlayView.滑翔翼开关){
        return true;
    }else{
        return Old_CanOpenGlider(thisPointer);
    }
}
void (*Old_DoBeforeLeaving)(long thisPointer);
void DoBeforeLeaving(long thisPointer) {
    if(![ImGuiView getInstance].overlayView.滑翔翼开关){
        return Old_DoBeforeLeaving(thisPointer);
    }
}
void (*Old_TriggerUpFinish)(long thisPointer);
void TriggerUpFinish(long thisPointer) {
    if(![ImGuiView getInstance].overlayView.滑翔翼开关){
        return Old_TriggerUpFinish(thisPointer);
    }
}


- (void)entry
{
    if (!self.floatingMenuView.superview) {
        [[UIApplication sharedApplication].keyWindow addSubview:self.overlayView];
        [[UIApplication sharedApplication].keyWindow addSubview:self.floatingMenuView];
    }
}
// 入口
- (void)entry2
{
    if (self.module == 0) {
        return;
    }
    
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:国服]) {
#pragma mark - 国服
        MSHookFunction((void *)(self.module + 0x4D77528), (void *)&Camera__WorldToScreenPoint, (void **)&Old_Camera__WorldToScreenPoint);
        MSHookFunction((void *)(self.module + 0x4D778D8), (void *)&Camera__ScreenToViewportPoint, (void **)&Old_Camera__ScreenToViewportPoint);
        MSHookFunction((void *)(self.module + 0x4DEF5D8), (void *)&UnityEngine_Transform__get_position, (void **)&Old_UnityEngine_Transform__get_position);
        MSHookFunction((void *)(self.module + 0x4DEF688), (void *)&UnityEngine_Transform__set_position, (void **)&Old_UnityEngine_Transform__set_position);
        MSHookFunction((void *)(self.module + 0x4EAF4BC), (void *)&UnityEngine_Rigidbody__get_position, (void **)&Old_UnityEngine_Rigidbody__get_position);
        MSHookFunction((void *)(self.module + 0x4EAED14), (void *)&UnityEngine_Rigidbody__set_velocity, (void **)&Old_UnityEngine_Rigidbody__set_velocity);
        MSHookFunction((void *)(self.module + 0x4EAF1E4), (void *)&UnityEngine_Rigidbody__set_isKinematic, (void **)&Old_UnityEngine_Rigidbody__set_isKinematic);
        MSHookFunction((void *)(self.module + 0x4EAF46C), (void *)&UnityEngine_Rigidbody__set_detectCollisions, (void **)&Old_UnityEngine_Rigidbody__set_detectCollisions);
        MSHookFunction((void *)(self.module + 0x4EAF760), (void *)&UnityEngine_Rigidbody__MovePosition, (void **)&Old_UnityEngine_Rigidbody__MovePosition);
        MSHookFunction((void *)(self.module + 0x4DC123C), (void *)&UnityEngine_Component__get_gameObject, (void **)&Old_UnityEngine_Component__get_gameObject);
        MSHookFunction((void *)(self.module + 0x4DC2108), (void *)&UnityEngine_GameObject__get_transform, (void **)&Old_UnityEngine_GameObject__get_transform);
        // 游戏逻辑
        MSHookFunction((void *)(self.module + 0x2DE74CC), (void *)&Battle__Init, (void **)&Old_Battle__Init);
        MSHookFunction((void *)(self.module + 0x2E0AE00), (void *)&Battle__GetNearOtherAndSelfPlayers, (void **)&Old_Battle__GetNearOtherAndSelfPlayers);
        MSHookFunction((void *)(self.module + 0x2952E6C), (void *)&SC_UI_BattlePanel__OnUpFire, (void **)&Old_SC_UI_BattlePanel__OnUpFire);
        MSHookFunction((void *)(self.module + 0x2953410), (void *)&SC_UI_BattlePanel__OnDownFire, (void **)&Old_SC_UI_BattlePanel__OnDownFire);
        //无后
        MSHookFunction((void *)(self.module + 0x25F3458), (void *)&DoOneShootRecoil, (void **)&Old_DoOneShootRecoil);
        //聚点
        MSHookFunction((void *)(self.module + 0x25F83D0), (void *)&CaulateMoveAimRadius, (void **)&Old_CaulateMoveAimRadius);
        MSHookFunction((void *)(self.module + 0x25F8634), (void *)&CaulateShootAimRadius, (void **)&Old_CaulateShootAimRadius);
        //绿名
        MSHookFunction((void *)(self.module + 0x2F0D800), (void *)&UnionMgr__IsSameUnion, (void **)&Old_UnionMgr__IsSameUnion);
        MSHookFunction((void *)(self.module + 0x2BA703C), (void *)&ACE, (void **)&Old_ACE);
        MSHookFunction((void *)(self.module + 0x2BA3D8C), (void *)&ACE, (void **)&Old_ACE);
        
        MSHookFunction((void *)(self.module + 0x2BB034C), (void *)&ACE1, (void **)&Old_ACE1);
        MSHookFunction((void *)(self.module + 0x32BF89C), (void *)&ACE1, (void **)&Old_ACE1);
        MSHookFunction((void *)(self.module + 0x2D293C8), (void *)&ACE1, (void **)&Old_ACE1);
        MSHookFunction((void *)(self.module + 0x2BAF00C), (void *)&ACE1, (void **)&Old_ACE1);
        MSHookFunction((void *)(self.module + 0x2BB18D8), (void *)&ACE1, (void **)&Old_ACE1);
        MSHookFunction((void *)(self.module + 0x2BB19E4), (void *)&ACE1, (void **)&Old_ACE1);
        
    }
}


/// 开始干你
- (void)startFuckYou
{
    [self cancelTimer];
    self.dataTimer = [NSTimer timerWithTimeInterval:1.0f/60 target:self selector:@selector(readData) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.dataTimer forMode:NSRunLoopCommonModes];
    
    self.aimTimer = [NSTimer timerWithTimeInterval:1.0f/60 target:self selector:@selector(aimbot) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.aimTimer forMode:NSRunLoopCommonModes];
}

/// 取消定时器
- (void)cancelTimer
{
    if (self.dataTimer) {
        [self.dataTimer invalidate];
        self.dataTimer = nil;
    }
    if (self.aimTimer) {
        [self.aimTimer invalidate];
        self.aimTimer = nil;
    }
    [self recyclePlayer];
}

/// 回收玩家对象
- (void)recyclePlayer
{
    if (self.localPlayer) {
        [self.playerPool putObj2Pool:self.localPlayer];
        self.localPlayer = nil;
    }
    for (JFPlayer *player in self.playerList) {
        [self.playerPool putObj2Pool:player];
    }
    [self.playerList removeAllObjects];
    
}

#pragma mark - 飞天
- (void)fly
{
    long rigidbody = 0;
    if (!Memory::read(&rigidbody, self.localPlayer.base + Offset::Rigidbody, sizeof(long)) || rigidbody < ADDRESS_MIN) {
        return;
    }
    Old_UnityEngine_Rigidbody__set_isKinematic(rigidbody, self.overlayView.锁定人物高度开关);
}

- (void)modifyLocalPlayerPosX:(float)x y:(float)y z:(float)z
{
    long playerTransform = 0;
    if (!Memory::read(&playerTransform, self.localPlayer.base + Offset::PlayerTransform, sizeof(long)) || playerTransform < ADDRESS_MIN) {
        return;
    }
    Vector3 position = Old_UnityEngine_Transform__get_position(playerTransform);
    position.x += x * MAX(self.overlayView.飞天变化距离, 6);
    position.y += y * self.overlayView.飞天变化距离;
    position.z += z * MAX(self.overlayView.飞天变化距离, 6);
    
    Old_UnityEngine_Transform__set_position(playerTransform, position);
    
    self.overlayView.人物X坐标 = position.x;
    self.overlayView.人物Y坐标 = position.y;
    self.overlayView.人物Z坐标 = position.z;
}


#pragma mark - 自瞄
- (void)aimbot
{
    if (!self.overlayView.总开关) {
        return;
    }
    [self filterBestAimPlayer];
    if (self.lockPlayer && self.overlayView.自瞄开关 && !self.lockPlayer.offline ){
        if (self.isFire ) {
            long neckBoneTrans = 0;
            if (Memory::read(&neckBoneTrans, self.lockPlayer.base + [ImGuiView getInstance].overlayView.追踪部位, sizeof(long))) {
                Vector3 lockPosition = Old_UnityEngine_Transform__get_position(neckBoneTrans);
                if (self.vThirdPersonCamera) {
                    Old_vThirdPersonCamera__SetLockAtPoint(self.vThirdPersonCamera, lockPosition);
                }
            }
        }
    }
}

- (void)filterBestAimPlayer
{
    if (!((self.overlayView.自瞄开关 || self.overlayView.追踪开关))) {
        return;
    }
    
    JFPlayer *bestAimPlayer = nil;
    self.lockPlayer = nil;
    float minCrossCenter = 100000;
    
    for (JFPlayer *player in self.playerList) {
        player.最佳目标 = false;
        if (player.type == PlayerTypeEnemy && player.hp > 0) {
            float crossCenter = Vector2(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5).distance(Vector2(CGRectGetMidX(player.box), CGRectGetMidY(player.box)));
            if (crossCenter < self.overlayView.自瞄追踪范围大小 && crossCenter < minCrossCenter) {
                minCrossCenter = crossCenter;
                bestAimPlayer = player;
            }
        }
    }
    if (bestAimPlayer) {
        self.lockPlayer = bestAimPlayer;
        self.lockPlayer.最佳目标 = true;
    }
}

#pragma mark - 读取数据
- (void)readData
{
    if (!self.overlayView.总开关) {
        return;
    }
    
    long aimHelper = 0;
    if (!Memory::read(&aimHelper, self.battle + Offset::AimHelp, sizeof(long)) || aimHelper < ADDRESS_MIN) {
        return;
    }
    self.aimHelper = aimHelper;
    
    long vThirdPersonCamera = 0;
    if (!Memory::read(&vThirdPersonCamera, self.battle + Offset::vThirdPersonCamera, sizeof(long)) || vThirdPersonCamera < ADDRESS_MIN) {
        return;
    }
    self.vThirdPersonCamera = vThirdPersonCamera;
    
    long camera = 0;
    if (!Memory::read(&camera, vThirdPersonCamera + Offset::Camera, sizeof(long)) || camera < ADDRESS_MIN) {
        return;
    }
    self.camera = camera;
    
    [self recyclePlayer];
    [self readLocalPlayer];
    [self readEmemyPlayerList];
}

- (void)readLocalPlayer
{
    long playerController = 0;
    if (!Memory::read(&playerController, self.battle + Offset::PlayerController, sizeof(long)) || playerController < ADDRESS_MIN) {
        return;
    }
    
    JFPlayer *player = [self.playerPool getObjFromPool];
    player.type = PlayerTypeMyself;
    player.base = playerController;
    
    [self readPlayerInfo:player];
    if (player.roleId != 0) {
        self.localPlayer = player;
    }
    
}

- (void)readEmemyPlayerList
{
    // 超过了300-400米就检测不到玩家，具体数值游戏决定了
    self.playerListAddr = Old_Battle__GetNearOtherAndSelfPlayers(self.battle, self.lockPlayer.worldPos, self.overlayView.绘制距离 * 10);
    long array = 0;
    if (!Memory::read(&array, self.playerListAddr + 0x10, sizeof(long))) {
        return;
    }
    
    int count = 0;
    if (!Memory::read(&count, self.playerListAddr + 0x18, sizeof(int))) {
        return;
    }
    
    for (int i = 0; i < count; i++) {
        long playerController = 0;
        Memory::read(&playerController, array + 0x20 + i * 0x8, sizeof(long));
        
        JFPlayer *player = [JFPlayer new];
        player.type = PlayerTypeEnemy;
        player.base = playerController;
        
        [self readPlayerInfo:player];
        if (!(!(self.overlayView.离线开关) && player.offline)) {
            [self addPlayer:player];
        }
    }
}
- (void)readPlayerInfo:(JFPlayer *)player
{
    long playerInfo = 0;
    if (!Memory::read(&playerInfo, player.base + 0x150, sizeof(long))) {
        return;
    }
    
    long roleId = 0;
    if (Memory::read(&roleId, playerInfo + 0x18, sizeof(long))) {
        player.roleId = roleId;
    }
    
    int CurrentWeaponInsId = 0;
    if (Memory::read(&CurrentWeaponInsId, player.base + 0x338, sizeof(long))) {
        if (CurrentWeaponInsId == -1) {
            player.holdgunname=@"拳头";
        }else{
            player.holdgunname=@"未知";
        }
        
        player.holdgun = CurrentWeaponInsId;
    }
    
    long nameAddr = 0;
    if (Memory::read(&nameAddr, playerInfo + 0x28, sizeof(long))) {
        nameAddr += 0x14;
        UTF8 name[32] = "";
        UTF16 buf16[16] = {0};
        if (Memory::read(&buf16, nameAddr, 28)) {
            Utf16_To_Utf8(buf16, name, 28, strictConversion);
            player.name = [NSString stringWithUTF8String:(const char *)name];
        }
    }
    
    int hp = 0;
    if (Memory::read(&hp, player.base + 0x110, sizeof(int))) {
        player.hp = hp;
    }
    
    int maxHp = 0;
    if (Memory::read(&maxHp, playerInfo + 0x68, sizeof(int))) {
        player.maxHp = maxHp;
    }
    
    int groupId = 0;
    if (Memory::read(&groupId, playerInfo + 0x3C, sizeof(int))) {
        if (groupId < 0) {
            player.groupId = (groupId %100) * (-1);
        } else {
            player.groupId = groupId % 100;
        }
    }
    
    bool offline = 0;
    if (Memory::read(&offline, playerInfo + 0xBA, sizeof(bool))) {
        player.offline = offline;
    }
    
    long playerTransform = 0;
    if (!Memory::read(&playerTransform, player.base + Offset::PlayerTransform, sizeof(long))) {
        return;
    }
    
    player.isVisible = Old_AimHelper__CheckTargetVisible(self.aimHelper, player.base);
    
    Vector3 position = Old_UnityEngine_Transform__get_position(playerTransform);
    player.worldPos = position;
    
    Vector3 topScreenPos = Old_Camera__WorldToScreenPoint(self.camera, 2, Vector3(position.x, position.y + 2, position.z));
    Vector3 bottomScreenPos = Old_Camera__WorldToScreenPoint(self.camera, 2, position);
    
    if (self.localPlayer && bottomScreenPos.z > 0) {
        player.distance = player.worldPos.distance(self.localPlayer.worldPos);
    } else {
        player.distance = 0;
    }
    Vector3 topViewportPos = Old_Camera__ScreenToViewportPoint(self.camera, topScreenPos);
    Vector3 bottomViewportPos = Old_Camera__ScreenToViewportPoint(self.camera, bottomScreenPos);
    
    topViewportPos.y = 1 - topViewportPos.y;
    topViewportPos.x *= SCREEN_WIDTH;
    topViewportPos.y *= SCREEN_HEIGHT;
    
    bottomViewportPos.y = 1 - bottomViewportPos.y;
    bottomViewportPos.x *= SCREEN_WIDTH;
    bottomViewportPos.y *= SCREEN_HEIGHT;
    
    CGFloat height = bottomViewportPos.y - topViewportPos.y;
    height = MAX(height, 10);
    CGFloat width = height * 0.5;
    CGFloat x = topViewportPos.x - width * 0.5;
    CGFloat y = topViewportPos.y;
    player.box = CGRectMake(x, y, width, height);
    
}

// 添加玩家到集合
- (void)addPlayer:(JFPlayer *)player
{
    if (player.roleId == 0 || player.roleId == self.localPlayer.roleId) {
        return;
    }
    
    BOOL isExists = NO;
    for (JFPlayer *p in self.playerList) {
        if (p.roleId == player.roleId) {
            isExists = YES;
        }
    }
    if (!isExists) {
        [self.playerList addObject:player];
    } else {
        [self.playerPool putObj2Pool:player];
    }
}


#pragma mark - battle
- (void)setBattle:(long)battle
{
    _battle = battle;
    if (!self.battle) {
        [self cancelTimer];
        return;
    }
    
    [self startFuckYou];
}

- (JFFloatingMenuView *)floatingMenuView
{
    if (!_floatingMenuView) {
        _floatingMenuView = [[JFFloatingMenuView alloc] initWithFrame:CGRectMake(kWidth-kWidth/3, 0, 35, 35)];
    }
    return _floatingMenuView;
}


- (JFOverlayView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[JFOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _overlayView;
}




@end
