


#import <UIKit/UIKit.h>
#import "JFFloatingMenuView.h"

NS_ASSUME_NONNULL_BEGIN

@interface JFOverlayView : UIView


#define 跑定时器 0.04

@property (nonatomic, strong) NSString *过期时间;
@property (nonatomic, strong) NSString *蓝奏云;

@property (nonatomic, assign) bool 地图迷雾美化;
@property (nonatomic, assign) bool 滑翔翼开关;

@property (nonatomic, assign) bool 子弹加速;

@property (nonatomic, assign) bool 单车;
@property (nonatomic, assign) bool 上色;

@property (nonatomic, assign) float paxia;
@property (nonatomic, assign) float jiashi;
@property (nonatomic, assign) bool 男驾驶;
@property (nonatomic, assign) bool 女驾驶;
@property (nonatomic, assign) bool 男翻滚;
@property (nonatomic, assign) bool 女翻滚;
@property (nonatomic, assign) bool 男驾驶2;
@property (nonatomic, assign) bool 女驾驶2;
@property (nonatomic, assign) int 追踪部位;
@property (nonatomic, assign) bool 追踪头;
@property (nonatomic, assign) bool 追踪胸;
@property (nonatomic, assign) bool isOpenDoor;
@property (nonatomic, assign) bool 总开关;
@property (nonatomic, assign) bool 打开菜单;
@property (nonatomic, assign) int 绘制帧率;

@property (nonatomic, assign) bool 方框开关;
@property (nonatomic, assign) bool 基址强建开关;
@property (nonatomic, assign) bool 射线开关;
@property (nonatomic, assign) bool 血量开关;
@property (nonatomic, assign) bool 信息开关;
@property (nonatomic, assign) bool 离线开关;
@property (nonatomic, assign) bool 手持开关;
@property (nonatomic, assign) int 绘制距离;
@property (nonatomic, assign) bool 瞬击开关;
@property (nonatomic, assign) bool 自瞄开关;
@property (nonatomic, assign) bool 追踪开关;
@property (nonatomic, assign) int 自瞄追踪未开启;
@property (nonatomic, assign) int 自瞄追踪范围大小;
@property (nonatomic, assign) float 速度滑条;
@property (nonatomic, assign) bool 无后开关;
@property (nonatomic, assign) bool 聚点开关;
@property (nonatomic, assign) bool 穿山开关;
@property (nonatomic, assign) bool 自动换弹开关;
@property (nonatomic, assign) bool 男趴下;
@property (nonatomic, assign) bool 女趴下;
@property (nonatomic, assign) bool 绿名开关;

@property (nonatomic, assign) bool 灵魂判定;
@property (nonatomic, assign) bool 挥拳自杀开关;
@property (nonatomic, assign) bool 混家开关;
@property (nonatomic, assign) bool 踏空开关;
@property (nonatomic, assign) bool 加速开关;
@property (nonatomic, assign) bool 跳舞开关;
@property (nonatomic, assign) bool 循环货轮穿;
@property (nonatomic, assign) bool 挥拳货轮穿;
@property (nonatomic, assign) bool 地基飞天开关;
@property (nonatomic, assign) bool 屏幕升降按钮开关;
@property (nonatomic, assign) bool 屏幕升降按钮开关2;
@property (nonatomic, assign) bool 屏幕升降按钮锁定模式;
@property (nonatomic, assign) bool 假滑翔翼开关;
//@property (nonatomic, assign) bool 碰撞屏幕显示开关;
@property (nonatomic, assign) bool 屏幕货轮开关;
@property (nonatomic, assign) bool 屏幕跳舞按钮开关;


@property (nonatomic, assign) bool 魔法子弹开关;
@property (nonatomic, assign) bool 闪动开关;

@property (nonatomic, assign) bool 修改位置开关;
@property (nonatomic, assign) bool 锁定人物高度开关;
@property (nonatomic, assign) bool 无视爆炸遮挡开关;
@property (nonatomic, assign) int 飞天变化距离;
@property (nonatomic, assign) float 人物X坐标;
@property (nonatomic, assign) float 人物Y坐标;
@property (nonatomic, assign) float 人物Z坐标;

@property (nonatomic, assign) bool 建筑耐久清空;
//@property (nonatomic, assign) bool 碰撞检测开关;
@property (nonatomic, assign) bool 灵魂穿墙开关;
@property (nonatomic, assign) bool 穿卡房;
@property (nonatomic, assign) bool 灵魂穿墙开关2;
@property (nonatomic, assign) bool 强制上锁开关;
@property (nonatomic, assign) bool 身体范围;
@property (nonatomic, assign) bool 身体范围1;
@property (nonatomic, assign) bool 身体范围2;
@property (nonatomic, assign) bool 身体范围3;
@property (nonatomic, assign) bool 头部范围3;
@property (nonatomic, assign) bool 头部范围;
@property (nonatomic, assign) bool 头部范围1;
@property (nonatomic, assign) bool 头部范围2;

@property (nonatomic, assign) bool 定怪开关;
@property (nonatomic, assign) bool 定坦克直升机开关;
@property (nonatomic, assign) bool 定炮台开关;
@property (nonatomic, assign) bool 除树开关;
@property (nonatomic, assign) bool 除石头与除建筑开关;
@property (nonatomic, assign) bool 除草开关;
@property (nonatomic, assign) bool 碰撞检测开关;
@property (nonatomic, assign) bool 水下行走开关;
@property (nonatomic, assign) bool 不会摔伤开关;

@property (nonatomic, assign) bool 人物半遁;
@property (nonatomic, assign) bool 人物半遁2;
@property (nonatomic, assign) bool 人物防死;
@property (nonatomic, assign) bool 男假死;
@property (nonatomic, assign) bool 女假死;
@property (nonatomic, assign) bool 女倒地;
@property (nonatomic, assign) bool 男倒地;

@property (nonatomic, assign) bool 强制建筑;
@property (nonatomic, assign) bool 地基领地;
@property (nonatomic, assign) bool 下蹲视角;
@property (nonatomic, assign) bool 地下行走;
@property (nonatomic, assign) bool 机瞄八倍;
@property (nonatomic, assign) bool 子弹穿图;
@property (nonatomic, assign) bool 全枪秒换;
@property (nonatomic, assign) bool 锁定天气;
@property (nonatomic, assign) bool 昼夜交替;
@property (nonatomic, assign) bool 浮空地基;
@property (nonatomic, assign) bool 虚拟建筑;
@property (nonatomic, assign) bool 飞天船;
@property (nonatomic, assign) bool 飞天船2;

@property (nonatomic, assign) bool SMG瞬击;
@property (nonatomic, assign) bool FAMAS瞬击;
@property (nonatomic, assign) bool UZI瞬击;
@property (nonatomic, assign) bool M4瞬击;
@property (nonatomic, assign) bool AK瞬击;
@property (nonatomic, assign) bool QBZ瞬击;
@property (nonatomic, assign) bool M762瞬击;
@property (nonatomic, assign) bool 散弹一套;
@property (nonatomic, assign) bool RPG瞬爆;
@property (nonatomic, assign) bool 榴弹瞬爆;

@end
NS_ASSUME_NONNULL_END
