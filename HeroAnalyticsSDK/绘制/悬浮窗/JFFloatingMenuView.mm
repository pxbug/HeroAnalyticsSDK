//
//  JFFloatingMenuView.m
//  SCMusic
//
//  Created by feng on 2021/7/13.
//

#import "JFFloatingMenuView.h"
#import "ImGuiView.h"
#import <AVFoundation/AVFoundation.h>

@interface JFFloatingMenuView()
@property (nonatomic, assign) float currentVolum;
@property (nonatomic) UIButton *btnConsole;
@property (strong, nonatomic) NSTimer * timer;
@end

@implementation JFFloatingMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://q2.qlogo.cn/headimg_dl?dst_uin=3494362309&spec=100"]];
        UIImage *image = [UIImage imageWithData:imageData];
        self.iconImageView.image = image;
        
        
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
//        tap.numberOfTapsRequired = 3;      // 连续敲击几次
//        tap.numberOfTouchesRequired = 3;   // 需要几根手指一起敲击
//        [[self getCurrentVC].view addGestureRecognizer:tap];
//        [tap addTarget:self action:@selector(didTapIconView)]; // 监听手势触发
    }
    return self;
}



#pragma mark - Event
- (void)didTapIconView
{
    [ImGuiView getInstance].overlayView.打开菜单 = ![ImGuiView getInstance].overlayView.打开菜单;
}

@end
